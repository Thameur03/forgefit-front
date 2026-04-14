import 'package:flutter/material.dart';
import '../../auth/widgets/onboarding_widgets.dart';

class NutritionSnapshotWidget extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;
  final VoidCallback onLogMeal;
  final Animation<double> animation;

  const NutritionSnapshotWidget({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.proteinGoal = 180,
    this.carbsGoal = 250,
    this.fatGoal = 80,
    required this.onLogMeal,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutrition Snapshot',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBar(
              label: 'Protein',
              value: protein,
              goal: proteinGoal,
              color: OnboardingTheme.accent,
              delay: 0.0,
            ),
            const SizedBox(height: 14),
            _buildBar(
              label: 'Carbs',
              value: carbs,
              goal: carbsGoal,
              color: Colors.white.withAlpha(200),
              delay: 0.15,
            ),
            const SizedBox(height: 14),
            _buildBar(
              label: 'Fat',
              value: fat,
              goal: fatGoal,
              color: Colors.white.withAlpha(200),
              delay: 0.3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLogMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OnboardingTheme.card,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: OnboardingTheme.border,
                    ),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log New Meal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBar({
    required String label,
    required double value,
    required double goal,
    required Color color,
    required double delay,
  }) {
    final progress = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;

    // Stagger effect: each bar starts after a delay
    final effectiveAnim = animation.value > delay
        ? ((animation.value - delay) / (1.0 - delay)).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label (${value.toInt()}g / ${goal.toInt()}g)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${goal.toInt()}g',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Track — uses the same subtle tone as onboarding progress
                    Container(
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: OnboardingTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Progress
                    Transform.translate(
                      offset: Offset(
                        -(constraints.maxWidth * progress) *
                            (1.0 - effectiveAnim),
                        0,
                      ),
                      child: Container(
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
