import 'package:flutter/material.dart';
import '../models/nutrition_model.dart';
import 'macro_bar.dart';

class NutritionSummaryCard extends StatelessWidget {
  final DailyNutritionSummary summary;

  const NutritionSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const targetCalories = 2000; // fallback — no target returned by backend
    final isOverTarget = summary.totalCalories > targetCalories;

    return Card(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withAlpha(51),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calories',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${summary.totalCalories}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isOverTarget
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: ' / $targetCalories kcal',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(153),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: targetCalories > 0
                            ? (summary.totalCalories / targetCalories)
                                .clamp(0.0, 1.0)
                            : 0,
                        backgroundColor: theme.colorScheme.outline.withAlpha(51),
                        color: isOverTarget
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        strokeWidth: 6,
                      ),
                    ),
                    Icon(
                      isOverTarget ? Icons.warning_amber : Icons.local_fire_department,
                      color: isOverTarget
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            MacroBar(
              label: 'Protein',
              current: summary.totalProtein,
              target: 150, // Hardcoded targets for UI, usually from user settings
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            MacroBar(
              label: 'Carbs',
              current: summary.totalCarbs,
              target: 200,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 16),
            MacroBar(
              label: 'Fat',
              current: summary.totalFat,
              target: 65,
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}
