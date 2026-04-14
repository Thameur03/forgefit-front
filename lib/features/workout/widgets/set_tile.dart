import 'package:flutter/material.dart';
import '../models/workout_model.dart';

class SetTile extends StatelessWidget {
  final int setIndex;
  final WorkoutSetModel set;
  final bool isEditing;
  final Function(String)? onRepsChanged;
  final Function(String)? onWeightChanged;
  final VoidCallback? onToggleComplete;

  const SetTile({
    super.key,
    required this.setIndex,
    required this.set,
    this.isEditing = false,
    this.onRepsChanged,
    this.onWeightChanged,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedColor = set.isCompleted ? theme.colorScheme.primary : null;

    return Container(
      color: set.isCompleted
          ? theme.colorScheme.primary.withAlpha(26)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$setIndex',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildInputOrText(
              context,
              value: set.weight.toString().replaceAll(RegExp(r'\.0$'), ''),
              suffix: ' kg',
              onChanged: onWeightChanged,
              isEditing: isEditing,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildInputOrText(
              context,
              value: set.reps.toString(),
              suffix: ' reps',
              onChanged: onRepsChanged,
              isEditing: isEditing,
            ),
          ),
          const SizedBox(width: 16),
          if (isEditing)
            IconButton(
              icon: Icon(
                Icons.check_circle,
                color: set.isCompleted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withAlpha(51),
              ),
              onPressed: onToggleComplete,
            )
          else
            Icon(
              Icons.check_circle,
              color: completedColor ?? Colors.transparent,
            ),
        ],
      ),
    );
  }

  Widget _buildInputOrText(
    BuildContext context, {
    required String value,
    required String suffix,
    required Function(String)? onChanged,
    required bool isEditing,
  }) {
    final theme = Theme.of(context);

    if (isEditing) {
      return Container(
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          initialValue: value == '0' ? '' : value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: '-',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withAlpha(77),
            ),
          ),
          onChanged: onChanged,
        ),
      );
    }

    return Text(
      '$value$suffix',
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
