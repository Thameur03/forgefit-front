import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/onboarding_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (authProvider.errorMessage != null &&
        authProvider.errorMessage!.contains('verify your email')) {
      // Redirect to verification screen
      Navigator.pushNamed(
        context,
        '/verify-email',
        arguments: _emailController.text.trim(),
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
                const SizedBox(height: 36),

                // ── App icon ──────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: OnboardingTheme.gradientStart,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // ── ATHLETELAB title ──────────────────────────────────────
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                    children: [
                      TextSpan(
                        text: 'ATHLETE',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'LAB',
                        style: TextStyle(color: OnboardingTheme.gradientStart),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // ── Sub-title ─────────────────────────────────────────────
                const Text(
                  'ELEVATE YOUR PERFORMANCE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11.5,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Daily Challenge banner card ───────────────────────────
                _DailyChallengeCard(),
                const SizedBox(height: 28),

                // ── Email field ───────────────────────────────────────────
                _buildTextField(
                  controller: _emailController,
                  hint: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your email';
                    if (!v.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ── Password field ────────────────────────────────────────
                _buildTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white38,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your password';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                // ── Error banner ──────────────────────────────────────────
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // ── Forgot Password ───────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Log In button ─────────────────────────────────────────
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [OnboardingTheme.gradientStart, OnboardingTheme.gradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: OnboardingTheme.gradientStart.withAlpha(80),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),


                const SizedBox(height: 28),

                // ── Sign Up link ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white54, fontSize: 13.5),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: OnboardingTheme.gradientStart,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: OnboardingTheme.field,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
          borderSide: const BorderSide(color: OnboardingTheme.gradientStart, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }


}

// ── Daily Challenge Card ─────────────────────────────────────────────────────
class _DailyChallengeCard extends StatelessWidget {
  static const Color accentBlue = OnboardingTheme.gradientStart;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Dark background with a subtle gradient to mimic gym photo
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  OnboardingTheme.cardAlt,
                  OnboardingTheme.bg,
                  OnboardingTheme.cardDark,
                ],
              ),
            ),
          ),
          // Decorative silhouette-like shapes to suggest a gym photo
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.18,
              child: Image.network(
                'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&q=60&fit=crop',
                height: 160,
                width: 130,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const SizedBox(),
              ),
            ),
          ),
          // Content overlay
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    'DAILY CHALLENGE',
                    style: TextStyle(
                      color: accentBlue,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Headline
                  const Text(
                    'Push your limits today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


