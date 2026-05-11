import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/onboarding_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    auth.clearError();

    final success = await auth.forgotPassword(_emailCtrl.text.trim());
    if (!mounted) return;

    if (success) {
      setState(() => _sent = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/reset-password',
        arguments: _emailCtrl.text.trim(),
      );
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
                      Icons.lock_reset_outlined,
                      color: OnboardingTheme.accent,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Heading ────────────────────────────────────────
                const Text(
                  'Forgot Password?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter your email address and we'll\nsend you a code to reset your password.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Email field ────────────────────────────────────
                const OnboardingFieldLabel('Email Address'),
                const SizedBox(height: 6),
                OnboardingTextField(
                  controller: _emailCtrl,
                  hint: 'you@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!v.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
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
                      label: 'Send Reset Code',
                      showArrow: false,
                      isLoading: auth.isLoading,
                      isSuccess: _sent,
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ── Back to login ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Remember your password? ',
                      style: TextStyle(color: Colors.white54, fontSize: 13.5),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: OnboardingTheme.accent,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
