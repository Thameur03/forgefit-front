import 'package:flutter/material.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import 'progress_ring_widget.dart';

class TodaySummaryCard extends StatelessWidget {
  final int calories;
  final int caloriesGoal;
  final Animation<double> ringAnimation;

  const TodaySummaryCard({
    super.key,
    required this.calories,
    this.caloriesGoal = 2000,
    required this.ringAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Progress",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ProgressRingWidget(
              value: calories.toDouble(),
              maxValue: caloriesGoal.toDouble(),
              ringColor: OnboardingTheme.ringOrange,
              centerText: _formatNumber(calories),
              centerSubText: 'kcal',
              label: 'Calories',
              subLabel: '${_formatNumber(caloriesGoal)} kcal',
              animation: ringAnimation,
            ),
            ProgressRingWidget(
              value: 0,
              maxValue: 10000,
              ringColor: OnboardingTheme.ringGreen,
              centerText: '0',
              centerSubText: 'steps',
              label: 'Steps',
              subLabel: '10,000 steps',
              animation: ringAnimation,
            ),
            ProgressRingWidget(
              value: 0,
              maxValue: 3.0,
              ringColor: OnboardingTheme.ringBlue,
              centerText: '0',
              centerSubText: '3.0 L',
              label: 'Water',
              subLabel: '3.0 L',
              animation: ringAnimation,
            ),
            ProgressRingWidget(
              value: 0,
              maxValue: 60,
              ringColor: OnboardingTheme.gradientStart,
              centerText: '0',
              centerSubText: 'min',
              label: 'Active\nMinutes',
              animation: ringAnimation,
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}k';
    }
    return number.toString();
  }
}
