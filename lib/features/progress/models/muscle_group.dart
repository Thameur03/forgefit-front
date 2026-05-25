// ── Shared muscle group enum used across Progress & Analytics ──────────────

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  quads,
  hamstrings,
  glutes,
  calves,
  core,
}

extension MuscleGroupX on MuscleGroup {
  String get label {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.quads:
        return 'Quads';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.core:
        return 'Core';
    }
  }

  String get insightsTitle => '$label Insights';

  /// Maps to the name string used by the existing MuscleMapWidget painter
  String get painterKey {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.quads:
        return 'Quads';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.core:
        return 'Core';
    }
  }

  static MuscleGroup? fromPainterKey(String key) {
    for (final m in MuscleGroup.values) {
      if (m.painterKey == key) return m;
    }
    return null;
  }

  List<String> get suggestedExercises {
    switch (this) {
      case MuscleGroup.chest:
        return ['Bench Press', 'Incline Dumbbell Press', 'Cable Fly'];
      case MuscleGroup.back:
        return ['Pull Ups', 'Barbell Row', 'Lat Pulldown'];
      case MuscleGroup.shoulders:
        return ['Overhead Press', 'Lateral Raises', 'Face Pulls'];
      case MuscleGroup.biceps:
        return ['Dumbbell Curl', 'Barbell Curl', 'Hammer Curl'];
      case MuscleGroup.triceps:
        return ['Tricep Pushdown', 'Skull Crushers', 'Dips'];
      case MuscleGroup.quads:
        return ['Squat', 'Leg Press', 'Leg Extension'];
      case MuscleGroup.hamstrings:
        return ['Romanian Deadlift', 'Leg Curl'];
      case MuscleGroup.glutes:
        return ['Hip Thrust', 'Squat', 'Romanian Deadlift'];
      case MuscleGroup.calves:
        return ['Calf Raises'];
      case MuscleGroup.core:
        return ['Plank', 'Crunches', 'Leg Raises'];
    }
  }
}
