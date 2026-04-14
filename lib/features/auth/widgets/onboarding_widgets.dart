import 'package:flutter/material.dart';

// ── Shared colour palette ──────────────────────────────────────────────────────
class OnboardingTheme {
  static const Color accent = Color(0xFF3B82F6);
  static const Color bg = Color(0xFF0B1220);
  static const Color card = Color(0xFF111827);
  static const Color border = Color(0xFF1F2937);
  static const Color field = Color(0xFF1F2937);

  // Semantic action colors
  static const Color success = Color(0xFF00C853);
  static const Color danger = Color(0xFFEF4444);

  // Card depth variants
  static const Color cardDark = Color(0xFF131D30);
  static const Color cardMid = Color(0xFF1E2E48);
  static const Color cardAlt = Color(0xFF1A2540);

  // Data ring colors
  static const Color ringOrange = Color(0xFFFF9800);
  static const Color ringBlue = Color(0xFF2196F3);
  static const Color ringGreen = Color(0xFF00C853);

  // Gradient colors (buttons, shimmer)
  static const Color gradientStart = Color(0xFF3D6FFF);
  static const Color gradientEnd = Color(0xFF5B8BFF);

  OnboardingTheme._();
}

// ── Slide page route (right-to-left push, left-to-right pop) ──────────────────
PageRoute<T> buildSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (ctx, anim1, anim2) => page,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideIn = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

      // Parallax: outgoing page drifts slightly left
      final slideOut = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.25, 0.0),
      ).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn));

      return SlideTransition(
        position: slideIn,
        child: SlideTransition(position: slideOut, child: child),
      );
    },
  );
}

// ── Animated progress bar (TweenAnimationBuilder for 400 ms smoothness) ────────
class OnboardingProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const OnboardingProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final targetProgress = current / total;
    final fromProgress = (current - 1) / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PROGRESS',
              style: TextStyle(
                color: OnboardingTheme.accent,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '${(targetProgress * 100).round()}%',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: fromProgress, end: targetProgress),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white10,
                valueColor:
                    AlwaysStoppedAnimation<Color>(OnboardingTheme.accent),
                minHeight: 5,
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Back button + step label header ───────────────────────────────────────────
class OnboardingHeader extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onBack;

  const OnboardingHeader({
    super.key,
    required this.current,
    required this.total,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: onBack ?? () => Navigator.maybePop(context),
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
        Text(
          'STEP $current OF $total',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11.5,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Field label ────────────────────────────────────────────────────────────────
class OnboardingFieldLabel extends StatelessWidget {
  final String text;
  const OnboardingFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ── Text field ─────────────────────────────────────────────────────────────────
class OnboardingTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const OnboardingTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.white38, size: 20)
            : null,
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
          borderSide:
              const BorderSide(color: OnboardingTheme.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

// ── Animated pulsing Next / Continue / Get Started button ─────────────────────
///
/// Shows a breathing blue glow while idle.
/// Shows a [CircularProgressIndicator] when [isLoading] is true.
/// Shows a check icon when [isSuccess] is true.
class OnboardingPulseButton extends StatefulWidget {
  final String label;
  final bool showArrow;
  final bool isLoading;
  final bool isSuccess;
  final VoidCallback? onPressed;

  const OnboardingPulseButton({
    super.key,
    required this.label,
    this.showArrow = true,
    this.isLoading = false,
    this.isSuccess = false,
    this.onPressed,
  });

  @override
  State<OnboardingPulseButton> createState() => _OnboardingPulseButtonState();
}

class _OnboardingPulseButtonState extends State<OnboardingPulseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glow = Tween<double>(begin: 0.20, end: 0.60).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        final showGlow = !widget.isLoading && !widget.isSuccess;
        return Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [OnboardingTheme.gradientStart, OnboardingTheme.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: OnboardingTheme.accent.withAlpha(
                          (_glow.value * 255).round()),
                      blurRadius: 22,
                      spreadRadius: 1,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton(
            onPressed: (widget.isLoading || widget.isSuccess)
                ? null
                : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
      );
    }
    if (widget.isSuccess) {
      return const Icon(Icons.check_circle_outline,
          color: Colors.white, size: 26);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (widget.showArrow) ...[
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
        ],
      ],
    );
  }
}
