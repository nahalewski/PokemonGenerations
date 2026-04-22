import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/providers.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../data/services/api_client.dart';
import 'auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passcodeController = TextEditingController();
  final _confirmPasscodeController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePasscode = true;
  bool _isLoginMode = true; // Default to login if we have a state
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Initialize mode based on whether a profile exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasProfile = ref.read(authControllerProvider).hasProfile;
      setState(() {
        _isLoginMode = hasProfile;
      });
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passcodeController.dispose();
    _confirmPasscodeController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthState authState) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      if (!_isLoginMode) {
        await ref
            .read(authControllerProvider.notifier)
            .register(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              username: _usernameController.text,
              passcode: _passcodeController.text,
            );
      } else {
        final success = await ref
            .read(authControllerProvider.notifier)
            .login(
              username: _usernameController.text,
              passcode: _passcodeController.text,
            );

        if (success && mounted) {
          context.go('/');
        } else if (!success && mounted) {
          setState(() {
            _errorText = 'Username or passcode did not match.';
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profile = authState.profile;
    final isCreateMode = !_isLoginMode;

    if (!authState.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!isCreateMode && _usernameController.text.isEmpty && profile != null) {
      _usernameController.text = profile.username;
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POKEMON',
                  style: AppTypography.displayLarge.copyWith(height: 0.8),
                ),
                Text(
                  'GENERATIONS',
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.primary,
                    height: 0.8,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isCreateMode ? 'CREATE YOUR ACCOUNT' : 'WELCOME BACK',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  isCreateMode
                      ? 'Set up a local profile with your name, username, and a 6-digit passcode.'
                      : 'Sign in with your username and 6-digit passcode to continue.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isCreateMode) ...[
                          _buildTextField(
                            controller: _firstNameController,
                            label: 'FIRST NAME',
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Enter a first name.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _lastNameController,
                            label: 'LAST NAME',
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Enter a last name.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildTextField(
                          controller: _usernameController,
                          label: 'USERNAME',
                          autocorrect: false,
                          validator: (value) {
                            final trimmed = (value ?? '').trim();
                            if (trimmed.isEmpty) {
                              return 'Enter a username.';
                            }
                            if (trimmed.length < 3) {
                              return 'Use at least 3 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passcodeController,
                          label: '6-DIGIT PASSCODE',
                          keyboardType: TextInputType.number,
                          obscureText: _obscurePasscode,
                          maxLength: 6,
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (!RegExp(r'^\d{6}$').hasMatch(text)) {
                              return 'Enter exactly 6 digits.';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePasscode = !_obscurePasscode;
                              });
                            },
                            icon: Icon(
                              _obscurePasscode
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        if (isCreateMode) ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _confirmPasscodeController,
                            label: 'CONFIRM PASSCODE',
                            keyboardType: TextInputType.number,
                            obscureText: _obscurePasscode,
                            maxLength: 6,
                            validator: (value) {
                              if ((value ?? '').trim() !=
                                  _passcodeController.text.trim()) {
                                return 'Passcodes do not match.';
                              }
                              return null;
                            },
                          ),
                        ],
                        if (profile != null && !isCreateMode) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Signed-in profile: ${profile.displayName}',
                              style: AppTypography.bodySmall,
                            ),
                          ),
                        ],
                        if (_errorText != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorText!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _isSubmitting
                                ? null
                                : () => _submit(authState),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isCreateMode
                                        ? 'Create Account'
                                        : 'Unlock Pokemon Generations',
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoginMode = !_isLoginMode;
                                _errorText = null;
                              });
                            },
                            child: Text(
                              isCreateMode
                                  ? 'ALREADY HAVE AN ACCOUNT? LOG IN'
                                  : 'NEED AN ACCOUNT? CREATE ONE',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        if (_isLoginMode) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: () => _showForgotPasscodeDialog(),
                              child: Text(
                                'FORGOT PASSCODE?',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.outline,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    bool enabled = true,
    bool autocorrect = true,
    int? maxLength,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          enabled: enabled,
          autocorrect: autocorrect,
          maxLength: maxLength,
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
  void _showForgotPasscodeDialog() {
    final resetUsernameController = TextEditingController(text: _usernameController.text);
    bool isRequesting = false;
    String? resetError;
    bool requestSuccess = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('FORGOT PASSCODE?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'To reset your passcode, enter your username below to send a request to the admin.',
                  style: TextStyle(fontSize: 13, color: AppColors.outline),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: resetUsernameController,
                  decoration: InputDecoration(
                    labelText: 'USERNAME',
                    errorText: resetError,
                    labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                  ),
                ),
                if (requestSuccess) ...[
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Request sent! The admin will flag your account for reset.',
                          style: TextStyle(color: Colors.green, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(requestSuccess ? 'CLOSE' : 'CANCEL'),
              ),
              if (!requestSuccess)
                ElevatedButton(
                  onPressed: isRequesting
                      ? null
                      : () async {
                          final username = resetUsernameController.text.trim();
                          if (username.isEmpty) {
                            setDialogState(() => resetError = 'Username required');
                            return;
                          }

                          setDialogState(() {
                            isRequesting = true;
                            resetError = null;
                          });

                          try {
                            final baseUrl = ref.read(backendBaseUrlProvider);
                            final success = await ref
                                .read(apiClientProvider.notifier)
                                .requestPasscodeReset(baseUrl, username);

                            if (success) {
                              setDialogState(() {
                                requestSuccess = true;
                                isRequesting = false;
                              });
                            } else {
                              setDialogState(() {
                                resetError = 'User not found or server error.';
                                isRequesting = false;
                              });
                            }
                          } catch (e) {
                            setDialogState(() {
                              resetError = 'Failed to send request.';
                              isRequesting = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isRequesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('SEND REQUEST'),
                ),
            ],
          );
        },
      ),
    );
  }
}
