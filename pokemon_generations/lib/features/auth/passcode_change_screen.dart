import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import 'auth_controller.dart';

class PasscodeChangeScreen extends ConsumerStatefulWidget {
  const PasscodeChangeScreen({super.key});

  @override
  ConsumerState<PasscodeChangeScreen> createState() => _PasscodeChangeScreenState();
}

class _PasscodeChangeScreenState extends ConsumerState<PasscodeChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passcodeController = TextEditingController();
  final _confirmPasscodeController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePasscode = true;
  String? _errorText;

  @override
  void dispose() {
    _passcodeController.dispose();
    _confirmPasscodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final success = await ref
          .read(authControllerProvider.notifier)
          .resetPasscode(_passcodeController.text);

      if (success && mounted) {
        // Router will automatically redirect to / because isAuthenticated becomes true
      } else if (mounted) {
        setState(() {
          _errorText = 'Failed to update passcode. Please try again.';
        });
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
    final profile = ref.watch(authControllerProvider).profile;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.security_rounded, size: 48, color: AppColors.primary),
                const SizedBox(height: 24),
                Text(
                  'SECURITY UPDATE REQUIRED',
                  style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'An administrator has requested a mandatory passcode reset for account @${profile?.username ?? "user"}.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.outline),
                ),
                const SizedBox(height: 32),
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: _passcodeController,
                          label: 'NEW 6-DIGIT PASSCODE',
                          keyboardType: TextInputType.number,
                          obscureText: _obscurePasscode,
                          maxLength: 6,
                          validator: (value) {
                            if (!RegExp(r'^\d{6}$').hasMatch(value ?? '')) {
                              return 'Enter exactly 6 digits.';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePasscode ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePasscode = !_obscurePasscode),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _confirmPasscodeController,
                          label: 'CONFIRM NEW PASSCODE',
                          keyboardType: TextInputType.number,
                          obscureText: _obscurePasscode,
                          maxLength: 6,
                          validator: (value) {
                            if (value != _passcodeController.text) {
                              return 'Passcodes do not match.';
                            }
                            return null;
                          },
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 16),
                          Text(_errorText!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                        ],
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('UPDATE PASSCODE'),
                          ),
                        ),
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
    bool obscureText = false,
    int? maxLength,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 4),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
