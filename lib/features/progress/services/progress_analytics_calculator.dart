import '../models/muscle_group.dart';
import '../models/muscle_analytics_model.dart';
import '../data/exercise_muscle_map.dart';
import '../../workout/models/workout_model.dart';
import '../../workout/utils/muscle_utils.dart';

// ── ProgressAnalyticsCalculator ───────────────────────────────────────────────
// Pure computation: takes a list of WorkoutModel and produces
// ProgressOverview + MuscleAnalytics for every MuscleGroup.

class ProgressAnalyticsCalculator {
  static const int _kWeeks = 8;

  // ── Public API ─────────────────────────────────────────────────────────────

  static ProgressOverview computeOverview(List<WorkoutModel> workouts) {
    final now = DateTime.now();
    final thisWeek = _startOfWeek(now);
    final prevWeek = thisWeek.subtract(const Duration(days: 7));

    double currentVol = 0;
    double prevVol = 0;
    int currentSets = 0;
    int workoutsThisWeek = 0;

    // Build 8-week buckets (keyed by weekStart)
    final Map<DateTime, double> weekVolume = {};
    for (int i = 0; i < _kWeeks; i++) {
      weekVolume[thisWeek.subtract(Duration(days: 7 * i))] = 0;
    }

    for (final w in workouts) {
      final ws = _startOfWeek(w.date);

      // Add to weekly buckets
      if (weekVolume.containsKey(ws)) {
        for (final s in w.sets) {
          final vol = _setVol(1, s.reps, s.weightKg);
          weekVolume[ws] = (weekVolume[ws] ?? 0) + vol;
        }
      }

      // Current-week stats
      if (ws == thisWeek) {
        workoutsThisWeek++;
        for (final s in w.sets) {
          currentVol += _setVol(1, s.reps, s.weightKg);
          currentSets++;
        }
      }

      // Previous-week volume
      if (ws == prevWeek) {
        for (final s in w.sets) {
          prevVol += _setVol(1, s.reps, s.weightKg);
        }
      }
    }

    final trend = weekVolume.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ProgressOverview(
      currentWeekTotalVolumeKg: currentVol,
      previousWeekTotalVolumeKg: prevVol,
      currentWeekTotalSets: currentSets,
      workoutsThisWeek: workoutsThisWeek,
      totalVolumeTrend: trend
          .map((e) => MuscleWeeklyPoint(
                weekStart: e.key,
                volumeKg: e.value,
                sets: 0,
              ))
          .toList(),
    );
  }

  static Map<MuscleGroup, MuscleAnalytics> computeAllMuscles(
    List<WorkoutModel> workouts,
  ) {
    final result = <MuscleGroup, MuscleAnalytics>{};
    for (final m in MuscleGroup.values) {
      result[m] = _computeMuscle(m, workouts);
    }
    return result;
  }

  // ── Per-muscle computation ─────────────────────────────────────────────────

  static MuscleAnalytics _computeMuscle(
    MuscleGroup muscle,
    List<WorkoutModel> workouts,
  ) {
    final now = DateTime.now();
    final thisWeek = _startOfWeek(now);
    final prevWeek = thisWeek.subtract(const Duration(days: 7));

    // 8-week buckets
    final Map<DateTime, double> weekVol = {};
    final Map<DateTime, int> weekSets = {};
    for (int i = 0; i < _kWeeks; i++) {
      final ws = thisWeek.subtract(Duration(days: 7 * i));
      weekVol[ws] = 0;
      weekSets[ws] = 0;
    }

    double currentWeekVol = 0;
    double prevWeekVol = 0;
    int currentWeekSets = 0;
    int prevWeekSets = 0;

    // Sessions this week (unique workout dates)
    final Set<String> sessionDatesThisWeek = {};

    // Per-exercise e1RM tracking  (exercise -> best e1RM)
    final Map<String, double> bestE1rmAllTime = {};
    // Same for this week vs prev week (to detect performance drop)
    final Map<String, double> bestE1rmThisWeek = {};
    final Map<String, double> bestE1rmPrevWeek = {};
    // For PR list: exercise -> best record
    final Map<String, MusclePersonalRecord> prMap = {};

    for (final w in workouts) {
      final ws = _startOfWeek(w.date);
      final isThisWeek = ws == thisWeek;
      final isPrevWeek = ws == prevWeek;
      final inBuckets = weekVol.containsKey(ws);

      bool workoutHasMuscle = false;

      for (final s in w.sets) {
        // 1. Try local exercise-name lookup
        Set<MuscleGroup> muscles = musclesForExercise(s.exerciseName);

        // 2. Fallback: use backend targetMuscle string (e.g. 'pectorals')
        if (muscles.isEmpty && s.targetMuscle.isNotEmpty) {
          final uiKey = mapToUiMuscle(s.targetMuscle); // e.g. 'chest'
          if (uiKey != null) {
            final mg = MuscleGroup.values.where((g) => g.name == uiKey).firstOrNull;
            if (mg != null) muscles = {mg};
          }
        }

        if (!muscles.contains(muscle)) continue;

        workoutHasMuscle = true;

        // Volume = sets × reps × weight (backend row has 1 set each)
        final vol = _setVol(1, s.reps, s.weightKg);

        // Weekly buckets
        if (inBuckets) {
          weekVol[ws] = (weekVol[ws] ?? 0) + vol;
          weekSets[ws] = (weekSets[ws] ?? 0) + 1;
        }

        // Current vs previous week accumulators
        if (isThisWeek) {
          currentWeekVol += vol;
          currentWeekSets++;
        } else if (isPrevWeek) {
          prevWeekVol += vol;
          prevWeekSets++;
        }

        // Estimated 1RM (only meaningful when reps < 30 and weight > 0)
        if (s.weightKg > 0 && s.reps > 0) {
          final e1rm = _epley(s.weightKg, s.reps);
          final exKey = s.exerciseName.toLowerCase();

          // All-time best (for PR list)
          final prev = bestE1rmAllTime[exKey] ?? 0;
          if (e1rm > prev) {
            bestE1rmAllTime[exKey] = e1rm;
            prMap[exKey] = MusclePersonalRecord(
              exerciseName: s.exerciseName,
              estimatedOneRepMaxKg: e1rm,
              weightKg: s.weightKg,
              reps: s.reps,
              date: w.date,
            );
          }

          // This-week / prev-week best for fatigue detection
          if (isThisWeek) {
            final pw = bestE1rmThisWeek[exKey] ?? 0;
            if (e1rm > pw) bestE1rmThisWeek[exKey] = e1rm;
          } else if (isPrevWeek) {
            final pw = bestE1rmPrevWeek[exKey] ?? 0;
            if (e1rm > pw) bestE1rmPrevWeek[exKey] = e1rm;
          }
        }
      }

      if (workoutHasMuscle && isThisWeek) {
        sessionDatesThisWeek.add(w.date.toIso8601String().substring(0, 10));
      }
    }

    // ── Sort weekly trend chronologically ──────────────────────────────────
    final trend = weekVol.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // ── Personal Records — top 5 by e1RM ──────────────────────────────────
    final prs = prMap.values.toList()
      ..sort((a, b) =>
          b.estimatedOneRepMaxKg.compareTo(a.estimatedOneRepMaxKg));
    final top5 = prs.take(5).toList();

    // ── Best exercise / e1RM ──────────────────────────────────────────────
    final String? bestEx = top5.isEmpty ? null : top5.first.exerciseName;
    final double? bestE1rm = top5.isEmpty ? null : top5.first.estimatedOneRepMaxKg;

    // ── Fatigue warnings ──────────────────────────────────────────────────
    final warnings = <String>[];

    // 1. Volume spike this week vs previous
    if (prevWeekVol > 0 && currentWeekVol > prevWeekVol * 1.35) {
      warnings.add('Volume is up sharply this week. Watch recovery.');
    }

    // 2. Too many sessions
    if (sessionDatesThisWeek.length >= 4) {
      warnings.add(
          'This muscle was trained ${sessionDatesThisWeek.length}× this week.');
    }

    // 3. Strength drop  (need at least one exercise in both weeks)
    for (final exKey in bestE1rmThisWeek.keys) {
      final thisW = bestE1rmThisWeek[exKey] ?? 0;
      if (thisW <= 0) continue;
      final prevW = bestE1rmPrevWeek[exKey];
      if (prevW != null && prevW > 0 && thisW < prevW * 0.9) {
        warnings.add(
            'Strength output dropped this week. Consider fatigue or recovery.');
        break;
      }
    }

    return MuscleAnalytics(
      muscle: muscle,
      currentWeekVolumeKg: currentWeekVol,
      previousWeekVolumeKg: prevWeekVol,
      currentWeekSets: currentWeekSets,
      previousWeekSets: prevWeekSets,
      volumeChangePercent: _percentChange(currentWeekVol, prevWeekVol),
      sessionsThisWeek: sessionDatesThisWeek.length,
      bestExerciseName: bestEx,
      bestEstimatedOneRepMaxKg: bestE1rm,
      weeklyTrend: trend
          .map((e) => MuscleWeeklyPoint(
                weekStart: e.key,
                volumeKg: e.value,
                sets: weekSets[e.key] ?? 0,
              ))
          .toList(),
      personalRecords: top5,
      fatigueWarnings:
          warnings.isEmpty ? ['No recovery concerns this week.'] : warnings,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static double _setVol(int sets, int reps, double weightKg) =>
      sets * reps * weightKg;

  static double _epley(double weightKg, int reps) =>
      reps <= 1 ? weightKg : weightKg * (1 + reps / 30);

  static DateTime _startOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1)); // Monday
  }

  static double _percentChange(double current, double previous) {
    if (previous == 0 && current == 0) return 0;
    if (previous == 0 && current > 0) return 100;
    return ((current - previous) / previous) * 100;
  }
}
