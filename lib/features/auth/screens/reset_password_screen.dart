import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/onboarding_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _success = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a new password';
    if (v.length < 8) return 'Must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Must include an uppercase letter';
    if (!v.contains(RegExp(r'[a-z]'))) return 'Must include a lowercase letter';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Must include a digit';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    auth.clearError();

    final success = await auth.resetPassword(
      widget.email,
      _codeCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!mounted) return;

    if (success) {
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully. Please log in.'),
          backgroundColor: OnboardingTheme.accent,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // ── Back button ────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: OnboardingTheme.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: OnboardingTheme.border),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Icon ───────────────────────────────────────────
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: OnboardingTheme.accent.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: OnboardingTheme.accent.withAlpha(60),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.password_outlined,
                      color: OnboardingTheme.accent,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Heading ────────────────────────────────────────
                const Text(
                  'Reset Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter the code sent to\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // ── OTP Code ───────────────────────────────────────
                const OnboardingFieldLabel('Reset Code'),
                const SizedBox(height: 6),
                OnboardingTextField(
                  controller: _codeCtrl,
                  hint: '6-digit code',
                  prefixIcon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter the reset code';
                    }
                    if (v.trim().length != 6) return 'Code must be 6 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // ── New password ───────────────────────────────────
                const OnboardingFieldLabel('New Password'),
                const SizedBox(height: 6),
                OnboardingTextField(
                  controller: _passwordCtrl,
                  hint: 'Min 8 chars, uppercase, digit',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePass,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white38,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 18),

                // ── Confirm password ───────────────────────────────
                const OnboardingFieldLabel('Confirm Password'),
                const SizedBox(height: 6),
                OnboardingTextField(
                  controller: _confirmCtrl,
                  hint: 'Re-enter new password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white38,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: _validateConfirm,
                ),
                const SizedBox(height: 16),

                // ── Error ──────────────────────────────────────────
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // ── Submit button ──────────────────────────────────
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return OnboardingPulseButton(
                      label: 'Reset Password',
                      showArrow: false,
                      isLoading: auth.isLoading,
                      isSuccess: _success,
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ── Back to login ──────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (r) => false),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
