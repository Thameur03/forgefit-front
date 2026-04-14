import '../models/workout_model.dart';

class WorkoutUtils {
  static String displayName(WorkoutModel w) {
    if (w.name != null &&
        w.name!.isNotEmpty &&
        w.name != 'My Workout' &&
        w.name != 'Workout' &&
        w.name != 'Empty Session') {
      return w.name!;
    }
    if (w.sets.isNotEmpty) {
      final exercises = w.sets
          .map((s) => s.exerciseName)
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList();
      if (exercises.isNotEmpty) {
        if (exercises.length == 1) {
          return exercises.first;
        }
        return '${exercises.first} +${exercises.length - 1} more';
      }
    }
    return 'Workout Session';
  }

  static String muscleGroups(WorkoutModel w) {
    if (w.sets.isEmpty) return '';
    return w.sets
        .map((s) => s.exerciseName)
        .toSet()
        .take(3)
        .join(' · ');
  }

  static String formatDuration(int seconds) {
    if (seconds <= 0) return '—';
    final m = seconds ~/ 60;
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem > 0 ? '${h}h ${rem}m' : '${h}h';
  }
}
