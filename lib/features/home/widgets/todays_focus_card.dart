import 'package:flutter/material.dart';
import '../../auth/widgets/onboarding_widgets.dart';

class TodaysFocusCard extends StatefulWidget {
  final VoidCallback onStartWorkout;

  const TodaysFocusCard({
    super.key,
    required this.onStartWorkout,
  });

  @override
  State<TodaysFocusCard> createState() => _TodaysFocusCardState();
}

class _TodaysFocusCardState extends State<TodaysFocusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Focus",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                OnboardingTheme.cardAlt,
                OnboardingTheme.bg,
                OnboardingTheme.cardDark,
              ],
            ),
            border: Border.all(color: OnboardingTheme.border),
          ),
          child: Stack(
            children: [
              // Subtle overlay pattern
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CustomPaint(
                    painter: _GymPatternPainter(),
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Full Body Strength',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '45 mins, Moderate Intensity',
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: OnboardingTheme.accent.withAlpha(80),
                    blurRadius: _glowAnimation.value + 4,
                    spreadRadius: _glowAnimation.value / 4,
                  ),
                ],
              ),
              width: double.infinity,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [OnboardingTheme.gradientStart, OnboardingTheme.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: widget.onStartWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start New Workout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.play_circle_fill, size: 22),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GymPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Subtle dumbbell shapes
    for (double y = 30; y < size.height; y += 60) {
      for (double x = 30; x < size.width; x += 80) {
        canvas.drawCircle(Offset(x, y), 8, paint);
        canvas.drawLine(Offset(x + 8, y), Offset(x + 25, y), paint);
        canvas.drawCircle(Offset(x + 33, y), 8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
