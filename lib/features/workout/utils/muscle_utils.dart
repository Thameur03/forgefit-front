import '../providers/workout_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MUSCLE MAPPING
// Maps raw API muscle names → one of the 12 canonical UI muscle group names.
// ─────────────────────────────────────────────────────────────────────────────

/// Canonical UI muscle group names used throughout the app.
const List<String> kAllUiMuscles = [
  'chest',
  'shoulders',
  'biceps',
  'triceps',
  'forearms',
  'abs',
  'quads',
  'hamstrings',
  'calves',
  'glutes',
  'back',
  'traps',
];

/// Maps an API muscle string to one of the 12 canonical UI muscle names.
/// Returns null if no mapping is found (unknown muscle — safe to ignore).
String? mapToUiMuscle(String apiMuscle) {
  final m = apiMuscle.toLowerCase().trim();
  if (m.isEmpty) return null;

  // Ordered from most specific to most general to avoid wrong matches.
  const Map<String, List<String>> rules = {
    'chest':      ['chest', 'pectoral', 'pec'],
    'shoulders':  ['deltoid', 'shoulder', 'delt'],
    'biceps':     ['bicep', 'brachii', 'upper arm'],
    'triceps':    ['tricep'],
    'forearms':   ['forearm', 'brachioradialis', 'wrist'],
    'abs':        ['abs', 'abdominal', 'oblique', 'core', 'rectus abdominis', 'transverse'],
    'quads':      ['quad', 'vastus', 'rectus femoris', 'thigh', 'leg'],
    'hamstrings': ['hamstring', 'biceps femoris', 'semimembranosus', 'semitendinosus'],
    'calves':     ['calf', 'calves', 'gastrocnemius', 'soleus'],
    'glutes':     ['glute', 'gluteal', 'gluteus', 'buttock'],
    'back':       ['back', 'lat', 'latissimus', 'rhomboid', 'erector', 'spine', 'row', 'infraspinatus', 'teres'],
    'traps':      ['trap', 'trapezius', 'neck', 'levator'],
  };

  for (final entry in rules.entries) {
    for (final keyword in entry.value) {
      if (m.contains(keyword)) return entry.key;
    }
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// SET COUNT AGGREGATION
// Loops exercises → counts completed sets → aggregates by UI muscle group.
// Both primary (targetMuscles) and secondary muscles contribute equally.
// ─────────────────────────────────────────────────────────────────────────────

/// Builds a map of { uiMuscleGroup → completedSetCount } from the active workout.
Map<String, int> buildMuscleSetCounts(List<ActiveExercise> exercises) {
  final Map<String, int> counts = {};

  for (final exercise in exercises) {
    // Count only completed sets for this exercise.
    final completedSets = exercise.sets.where((s) => s.isCompleted).length;
    if (completedSets == 0) continue;

    final result = exercise.exerciseResult;

    // Collect all raw muscle strings: primary + secondary.
    final List<String> rawMuscles = [];

    if (result != null) {
      rawMuscles.addAll(result.targetMuscles);
      rawMuscles.addAll(result.secondaryMuscles);
    } else if (exercise.targetMuscle.isNotEmpty && exercise.targetMuscle != '—') {
      // Fallback: use the simple targetMuscle string.
      rawMuscles.add(exercise.targetMuscle);
    }

    // If no muscle data at all, skip.
    if (rawMuscles.isEmpty) continue;

    // Map each raw muscle to a UI group; add set count.
    final Set<String> addedGroups = {}; // deduplicate per exercise
    for (final raw in rawMuscles) {
      final uiGroup = mapToUiMuscle(raw);
      if (uiGroup == null) continue;
      if (addedGroups.contains(uiGroup)) continue;
      addedGroups.add(uiGroup);
      counts[uiGroup] = (counts[uiGroup] ?? 0) + completedSets;
    }
  }

  return counts;
}

// ─────────────────────────────────────────────────────────────────────────────
// COLOR HELPER
// Returns a hex colour string based on set count intensity.
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a CSS/SVG hex colour for a given set count.
/// 0 sets → neutral grey; 7+ sets → dark red.
String muscleColor(int setCount) {
  if (setCount == 0) return '#3A3A3C';
  if (setCount <= 2) return '#FF9999';
  if (setCount <= 4) return '#FF4444';
  if (setCount <= 6) return '#CC1111';
  return '#881111'; // 7+
}

/// Capitalises the first letter of a muscle name for display.
String capitalizeMuscle(String name) {
  if (name.isEmpty) return name;
  return '${name[0].toUpperCase()}${name.substring(1)}';
}
