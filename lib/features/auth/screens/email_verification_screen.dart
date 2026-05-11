import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/onboarding_widgets.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _success = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendCooldown = 0);
      } else {
        if (mounted) setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _verify() async {
    final code = _otpCode;
    if (code.length != 6) return;

    final auth = context.read<AuthProvider>();
    auth.clearError();

    final success = await auth.verifyEmail(widget.email, code);
    if (!mounted) return;

    if (success) {
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully. Please log in.'),
          backgroundColor: OnboardingTheme.accent,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;

    final auth = context.read<AuthProvider>();
    auth.clearError();

    final success = await auth.resendVerificationCode(widget.email);
    if (!mounted) return;

    if (success) {
      _startCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new verification code has been sent.'),
          backgroundColor: OnboardingTheme.accent,
          duration: Duration(seconds: 2),
        ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 36),

              // ── Icon ─────────────────────────────────────────────
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
                    Icons.mark_email_read_outlined,
                    color: OnboardingTheme.accent,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Heading ──────────────────────────────────────────
              const Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a 6-digit code to\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // ── OTP Fields ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) => _buildOtpField(i)),
              ),
              const SizedBox(height: 16),

              // ── Error ────────────────────────────────────────────
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

              // ── Verify Button ────────────────────────────────────
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return OnboardingPulseButton(
                    label: 'Verify Email',
                    showArrow: false,
                    isLoading: auth.isLoading,
                    isSuccess: _success,
                    onPressed: _verify,
                  );
                },
              ),
              const SizedBox(height: 20),

              // ── Resend ───────────────────────────────────────────
              Center(
                child: TextButton(
                  onPressed: _resendCooldown > 0 ? null : _resend,
                  child: Text(
                    _resendCooldown > 0
                        ? 'Resend code in ${_resendCooldown}s'
                        : 'Resend verification code',
                    style: TextStyle(
                      color: _resendCooldown > 0
                          ? Colors.white30
                          : OnboardingTheme.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Back to login ────────────────────────────────────
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
    );
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 46,
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: OnboardingTheme.field,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: OnboardingTheme.accent, width: 1.5),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (v.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          // Auto-verify when all 6 digits entered
          if (_otpCode.length == 6) {
            _verify();
          }
        },
      ),
    );
  }
}
