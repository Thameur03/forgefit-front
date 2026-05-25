import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';
import '../providers/workout_provider.dart';

/// A single broken personal record detected after completing a workout.
class BrokenPr {
  final String exerciseName;
  final double previousE1rm;
  final double newE1rm;
  final double weightKg;
  final int reps;

  const BrokenPr({
    required this.exerciseName,
    required this.previousE1rm,
    required this.newE1rm,
    required this.weightKg,
    required this.reps,
  });
}

/// Pure utility class for detecting personal records (PRs) at workout
/// completion time.  Has no Flutter/provider dependencies.
class PrDetector {
  PrDetector._();

  /// Epley estimated 1-rep-max formula.
  static double _e1rm(double weightKg, int reps) {
    if (weightKg <= 0 || reps <= 0) return 0;
    return weightKg * (1 + reps / 30.0);
  }

  /// Normalises an exercise name for comparison: lowercase + trim.
  static String _normalize(String name) => name.trim().toLowerCase();

  /// Detects PRs broken in [completedExercises] relative to [previousWorkouts].
  ///
  /// Rules:
  /// - Uses Epley e1RM as the comparison metric.
  /// - Builds a previous-best map from **all** [previousWorkouts] (which must
  ///   NOT include the current workout — the caller is responsible for this).
  /// - Does NOT count first-time exercises as PRs (no previous best → skip).
  /// - Counts at most one PR per exercise name (the best set in the workout).
  /// - Uses a tolerance of 0.01 to avoid floating-point equality issues.
  static List<BrokenPr> detectBrokenPrs({
    required List<ActiveExercise> completedExercises,
    required List<WorkoutModel> previousWorkouts,
  }) {
    // ── Step 1: build previous-best e1RM map ────────────────────────────────
    // Walk all sets in all previous workouts. WorkoutModel.sets is
    // List<WorkoutSetDetail> which has exerciseName / reps / weightKg.
    final Map<String, double> previousBest = {};

    for (final workout in previousWorkouts) {
      for (final set in workout.sets) {
        final name = set.exerciseName;
        if (name.isEmpty) continue;
        final key = _normalize(name);
        final e = _e1rm(set.weightKg, set.reps);
        if (e > (previousBest[key] ?? 0)) {
          previousBest[key] = e;
        }
      }
    }

    debugPrint('[PR Detection] previous workouts=${previousWorkouts.length}');
    debugPrint('[PR Detection] previousBestByExercise=$previousBest');

    // ── Step 2: find best set per exercise in the completed workout ──────────
    // Build a map from normalised exercise name → best e1RM for the session.
    final Map<String, _SessionBest> sessionBest = {};

    for (final exercise in completedExercises) {
      if (exercise.name.isEmpty) continue;
      final key = _normalize(exercise.name);

      for (final set in exercise.sets) {
        if (!set.isCompleted) continue;
        if (set.weightKg <= 0 || set.reps <= 0) continue;

        final e = _e1rm(set.weightKg, set.reps);
        final current = sessionBest[key];
        if (current == null || e > current.e1rm) {
          sessionBest[key] = _SessionBest(
            exerciseName: exercise.name,
            e1rm: e,
            weightKg: set.weightKg,
            reps: set.reps,
          );
        }
      }
    }

    debugPrint('[PR Detection] session best=$sessionBest');

    // ── Step 3: compare against previous bests ──────────────────────────────
    const tolerance = 0.01;
    final List<BrokenPr> broken = [];

    for (final entry in sessionBest.entries) {
      final key = entry.key;
      final best = entry.value;
      final prev = previousBest[key];

      if (prev == null) {
        // First time ever — do NOT count as PR.
        debugPrint('[PR Detection] ${best.exerciseName}: first time, skipping');
        continue;
      }

      if (best.e1rm > prev + tolerance) {
        debugPrint(
          '[PR Detection] PR! ${best.exerciseName}: '
          'prev=${prev.toStringAsFixed(1)} new=${best.e1rm.toStringAsFixed(1)}',
        );
        broken.add(BrokenPr(
          exerciseName: best.exerciseName,
          previousE1rm: prev,
          newE1rm: best.e1rm,
          weightKg: best.weightKg,
          reps: best.reps,
        ));
      } else {
        debugPrint(
          '[PR Detection] no PR for ${best.exerciseName}: '
          'prev=${prev.toStringAsFixed(1)} new=${best.e1rm.toStringAsFixed(1)}',
        );
      }
    }

    debugPrint('[PR Detection] broken PRs=${broken.map((p) => p.exerciseName).toList()}');
    return broken;
  }
}

// Private helper to store the best set within the current workout session.
class _SessionBest {
  final String exerciseName;
  final double e1rm;
  final double weightKg;
  final int reps;

  const _SessionBest({
    required this.exerciseName,
    required this.e1rm,
    required this.weightKg,
    required this.reps,
  });

  @override
  String toString() =>
      '$exerciseName(e1rm=${e1rm.toStringAsFixed(1)}, ${weightKg}kg×$reps)';
}
