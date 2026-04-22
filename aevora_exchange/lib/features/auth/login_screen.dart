import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_client.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passcodeCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberUsername = true;
  bool _rememberPassword = false;
  bool _hasSavedHash = false;   // true when stored hash is loaded
  bool _passwordDirty = false;  // true when user edits the password field
  String? _savedHash;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final remUser  = prefs.getBool('pref_remember_username') ?? true;
    final remPass  = prefs.getBool('pref_remember_password') ?? false;
    final savedUsr = prefs.getString('saved_username') ?? '';
    final savedHash = prefs.getString('saved_passcode_hash');

    setState(() {
      _rememberUsername = remUser;
      _rememberPassword = remPass;
      if (remUser && savedUsr.isNotEmpty) {
        _usernameCtrl.text = savedUsr;
      }
      if (remPass && savedHash != null) {
        _savedHash = savedHash;
        _hasSavedHash = true;
        _passcodeCtrl.text = '●●●●●●●●'; // placeholder
      }
    });
  }

  /// Must match auth_controller.dart in pokemon_generations:
  ///   sha256('username::passcode::rosteriq')
  String _hashPasscode(String username, String raw) =>
      sha256.convert(utf8.encode('$username::$raw::rosteriq')).toString();

  Future<void> _login() async {
    final username = _usernameCtrl.text.trim().toLowerCase();
    if (username.isEmpty) {
      setState(() => _error = 'TRAINER_ID required.');
      return;
    }

    // Determine hash to use
    String passcodeHash;
    if (_hasSavedHash && !_passwordDirty) {
      // Use stored hash
      passcodeHash = _savedHash!;
    } else {
      final raw = _passcodeCtrl.text.trim();
      if (raw.isEmpty) {
        setState(() => _error = 'PASSCODE required.');
        return;
      }
      passcodeHash = _hashPasscode(username, raw);
    }

    setState(() { _loading = true; _error = null; });

    try {
      final client = ref.read(apiClientProvider);
      await client.login(username, passcodeHash);

      // Persist credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pref_remember_username', _rememberUsername);
      await prefs.setBool('pref_remember_password', _rememberPassword);

      if (_rememberUsername) {
        await prefs.setString('saved_username', username);
      } else {
        await prefs.remove('saved_username');
      }

      if (_rememberPassword) {
        await prefs.setString('saved_passcode_hash', passcodeHash);
      } else {
        await prefs.remove('saved_passcode_hash');
      }

      // Set session → triggers navigation via sessionProvider
      await ref.read(sessionProvider.notifier).login(username);

    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        setState(() => _error = 'ACCESS_DENIED: Invalid username or passcode.');
      } else if (e.type == DioExceptionType.connectionError ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.connectionTimeout) {
        setState(() => _error = 'NETWORK_ERROR: Cannot reach server.\nCheck your internet connection.');
      } else {
        setState(() => _error = 'SERVER_ERROR: ${e.message ?? 'Unknown'}');
      }
    } catch (e) {
      setState(() => _error = 'ERROR: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Icon(Icons.bolt, color: AppColors.primary, size: 48),
              const SizedBox(height: 12),
              const Text('AEVORA EXCHANGE',
                  style: TextStyle(color: AppColors.primary, fontSize: 18,
                      fontWeight: FontWeight.bold, letterSpacing: 4)),
              const SizedBox(height: 4),
              const Text('SECURE TERMINAL ACCESS',
                  style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 48),

              // Login card
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username
                    const Text('TRAINER_ID:', style: TextStyle(
                        color: AppColors.primary, fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _usernameCtrl,
                      style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                      decoration: _inputDec('username'),
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 24),

                    // Password
                    const Text('PASSCODE:', style: TextStyle(
                        color: AppColors.primary, fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passcodeCtrl,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                      decoration: _inputDec('••••••').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white24, size: 18,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onChanged: (val) {
                        // If user changes the password field, mark it dirty
                        // (so we don't use the stored hash)
                        if (_hasSavedHash) {
                          setState(() => _passwordDirty = true);
                        }
                      },
                      onSubmitted: (_) => _login(),
                    ),

                    const SizedBox(height: 20),

                    // Remember toggles
                    const Divider(color: Colors.white10, height: 28),
                    _buildToggle(
                      label: 'Remember Username',
                      value: _rememberUsername,
                      onChanged: (v) => setState(() => _rememberUsername = v),
                    ),
                    const SizedBox(height: 20),
                    _buildToggle(
                      label: 'Remember Password',
                      value: _rememberPassword,
                      onChanged: (v) => setState(() => _rememberPassword = v),
                      subtitle: 'Saves encrypted hash locally',
                    ),
                    const Divider(color: Colors.white10, height: 28),

                    // Error
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Authenticate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                        ),
                        child: _loading
                            ? const SizedBox(height: 16, width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.black))
                            : const Text('AUTHENTICATE',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text('AEVORA_TERMINAL v2.0 // ENCRYPTED',
                  style: TextStyle(color: Colors.white12, fontSize: 8, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 20,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
              if (subtitle != null)
                Text(subtitle, style: const TextStyle(color: Colors.white24, fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white24, fontFamily: 'monospace'),
    enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white12)),
    focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary)),
  );
}
