// ── Beta: ForgotPasswordScreen ────────────────────────────────────────────────
//
// During beta, password reset via email OTP is not available because email
// delivery is not yet configured for production.
//
// This screen replaces the full OTP reset flow with a simple informational
// page that instructs the user to contact the developer.
//
// The ResetPasswordScreen and backend /auth/forgot-password endpoint are
// intentionally left intact for future use.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../widgets/onboarding_widgets.dart';

/// Edit this constant to update the contact info shown to beta testers.
const String kDeveloperContact = 'Contact the developer to reset your account.';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
              const SizedBox(height: 16),

              // ── Back button ──────────────────────────────────────
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
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ── Lock icon ────────────────────────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: OnboardingTheme.accent.withAlpha(20),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: OnboardingTheme.accent.withAlpha(50),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: OnboardingTheme.accent,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Title ────────────────────────────────────────────
              const Text(
                'Forgot Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ── Beta notice card ─────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: OnboardingTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: OnboardingTheme.border),
                ),
                child: Column(
                  children: [
                    // Beta badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Colors.amber.withAlpha(80)),
                      ),
                      child: const Text(
                        'BETA',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Forgot password is not implemented during the beta.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please contact the developer to recover your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Contact info line
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: OnboardingTheme.accent.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: OnboardingTheme.accent.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.mail_outline,
                            color: OnboardingTheme.accent,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              kDeveloperContact,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Back to Login button ─────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OnboardingTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
}
