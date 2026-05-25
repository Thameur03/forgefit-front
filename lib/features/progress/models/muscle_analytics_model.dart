import 'muscle_group.dart';

// ── Per-week data point ────────────────────────────────────────────────────────

class MuscleWeeklyPoint {
  final DateTime weekStart;
  final double volumeKg;
  final int sets;

  const MuscleWeeklyPoint({
    required this.weekStart,
    required this.volumeKg,
    required this.sets,
  });
}

// ── Personal record per exercise ──────────────────────────────────────────────

class MusclePersonalRecord {
  final String exerciseName;
  final double estimatedOneRepMaxKg;
  final double weightKg;
  final int reps;
  final DateTime date;

  const MusclePersonalRecord({
    required this.exerciseName,
    required this.estimatedOneRepMaxKg,
    required this.weightKg,
    required this.reps,
    required this.date,
  });
}

// ── All analytics for a single muscle ────────────────────────────────────────

class MuscleAnalytics {
  final MuscleGroup muscle;
  final double currentWeekVolumeKg;
  final double previousWeekVolumeKg;
  final int currentWeekSets;
  final int previousWeekSets;
  final double volumeChangePercent;
  final int sessionsThisWeek;
  final String? bestExerciseName;
  final double? bestEstimatedOneRepMaxKg;
  final List<MuscleWeeklyPoint> weeklyTrend;
  final List<MusclePersonalRecord> personalRecords;
  final List<String> fatigueWarnings;

  const MuscleAnalytics({
    required this.muscle,
    required this.currentWeekVolumeKg,
    required this.previousWeekVolumeKg,
    required this.currentWeekSets,
    required this.previousWeekSets,
    required this.volumeChangePercent,
    required this.sessionsThisWeek,
    required this.bestExerciseName,
    required this.bestEstimatedOneRepMaxKg,
    required this.weeklyTrend,
    required this.personalRecords,
    required this.fatigueWarnings,
  });

  bool get hasData =>
      currentWeekSets > 0 ||
      previousWeekSets > 0 ||
      weeklyTrend.any((p) => p.sets > 0 || p.volumeKg > 0);
}

// ── Global week overview ──────────────────────────────────────────────────────

class ProgressOverview {
  final double currentWeekTotalVolumeKg;
  final double previousWeekTotalVolumeKg;
  final int currentWeekTotalSets;
  final int workoutsThisWeek;
  final List<MuscleWeeklyPoint> totalVolumeTrend;

  const ProgressOverview({
    required this.currentWeekTotalVolumeKg,
    required this.previousWeekTotalVolumeKg,
    required this.currentWeekTotalSets,
    required this.workoutsThisWeek,
    required this.totalVolumeTrend,
  });
}
