import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';

class EmailPasswordScreen extends StatefulWidget {
  const EmailPasswordScreen({super.key});

  @override
  State<EmailPasswordScreen> createState() => _EmailPasswordScreenState();
}

class _EmailPasswordScreenState extends State<EmailPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    // Pre-populate from provider if navigating back
    final op = context.read<OnboardingProvider>();
    _emailCtrl.text = op.email;
    _passCtrl.text = op.password;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w\-.]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (v.length < 8) return 'Must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Must include an uppercase letter';
    if (!v.contains(RegExp(r'[a-z]'))) return 'Must include a lowercase letter';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Must include a digit';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passCtrl.text) return 'Passwords do not match';
    return null;
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    final op = context.read<OnboardingProvider>();
    op.email = _emailCtrl.text.trim();
    op.password = _passCtrl.text;
    Navigator.pushNamed(context, '/personal-info');
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

                // ── Header ───────────────────────────────────────────────
                OnboardingHeader(
                  current: 1,
                  total: 5,
                  onBack: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                ),
                const SizedBox(height: 16),

                OnboardingProgressBar(current: 1, total: 5),
                const SizedBox(height: 36),

                // ── Icon ─────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: OnboardingTheme.cardAlt,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: OnboardingTheme.accent.withAlpha(60),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(Icons.bolt,
                        color: OnboardingTheme.accent, size: 30),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Heading ──────────────────────────────────────────────
                const Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your credentials are encrypted\nand never shared.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13.5,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 30),

                // ── Email ────────────────────────────────────────────────
                const OnboardingFieldLabel('Email Address'),
                const SizedBox(height: 6),
                OnboardingTextField(
                  controller: _emailCtrl,
                  hint: 'you@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 18),

                // ── Password ─────────────────────────────────────────────
                const OnboardingFieldLabel('Password'),
                const SizedBox(height: 6),
                OnboardingTextField(
                  controller: _passCtrl,
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

                // ── Confirm password ─────────────────────────────────────
                const OnboardingFieldLabel('Confirm Password'),
                const SizedBox(height: 6),
                OnboardingTextField(
                  controller: _confirmCtrl,
                  hint: 'Re-enter your password',
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
                const SizedBox(height: 32),

                OnboardingPulseButton(
                  label: 'Next',
                  onPressed: _next,
                ),
                const SizedBox(height: 18),

                // ── Already have account ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style:
                          TextStyle(color: Colors.white54, fontSize: 13.5),
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
