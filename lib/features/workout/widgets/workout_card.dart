import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout_model.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback onTap;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalVolume = _calculateVolume(workout);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withAlpha(51),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workout.name ?? 'Workout',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(workout.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _IconText(
                    icon: Icons.timer_outlined,
                    text: '${workout.durationSeconds ~/ 60} min',
                  ),
                  const SizedBox(width: 16),
                  _IconText(
                    icon: Icons.fitness_center_outlined,
                    text: '$totalVolume kg',
                  ),
                  const SizedBox(width: 16),
                  _IconText(
                    icon: Icons.format_list_bulleted,
                    text: '${workout.exercises.length} Exercises',
                  ),
                ],
              ),
              if (workout.exercises.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  workout.exercises.map((e) => e.name).join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _calculateVolume(WorkoutModel workout) {
    double vol = 0;
    for (var ex in workout.exercises) {
      for (var set in ex.sets) {
        if (set.isCompleted || set.weight > 0) {
          vol += set.weight * set.reps;
        }
      }
    }
    return vol;
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withAlpha(153);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
