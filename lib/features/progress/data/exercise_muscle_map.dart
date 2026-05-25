import '../models/muscle_group.dart';

// ── Exercise-to-muscle mapping ────────────────────────────────────────────────
// Returns all muscle groups worked by the given exercise.
// Compound lifts return multiple groups (sets/volume counted to each).

Set<MuscleGroup> musclesForExercise(String exerciseName) {
  final name = exerciseName.toLowerCase().trim();

  // ── Exact / keyword matching ──────────────────────────────────────────────

  // CHEST
  if (_matches(name, [
    'bench press',
    'chest press',
    'dumbbell press',
    'incline press',
    'incline dumbbell',
    'incline bench',
    'decline press',
    'decline bench',
    'chest fly',
    'cable fly',
    'cable chest',
    'low cable fly',
    'high cable fly',
    'pec fly',
    'pec deck',
    'push up',
    'pushup',
    'push-up',
    'chest dip',
    'smith machine bench',
    'machine chest',
  ])) {
    return {MuscleGroup.chest, MuscleGroup.triceps, MuscleGroup.shoulders};
  }

  // DIPS — chest + triceps
  if (_matches(name, ['dip', 'dips'])) {
    return {MuscleGroup.chest, MuscleGroup.triceps, MuscleGroup.shoulders};
  }

  // DEADLIFT (conventional) — back, hamstrings, glutes
  if (name == 'deadlift' ||
      name.contains('conventional deadlift') ||
      name.contains('sumo deadlift') ||
      (name.contains('deadlift') &&
          !name.contains('romanian') &&
          !name.contains('rdl') &&
          !name.contains('stiff'))) {
    return {MuscleGroup.back, MuscleGroup.hamstrings, MuscleGroup.glutes};
  }

  // ROMANIAN / STIFF LEG DEADLIFT
  if (_matches(name, [
    'romanian deadlift',
    'rdl',
    'stiff leg deadlift',
    'stiff-leg deadlift',
  ])) {
    return {MuscleGroup.hamstrings, MuscleGroup.glutes, MuscleGroup.back};
  }

  // SQUAT (barbell, front, goblet, hack)
  if (_matches(name, [
    'barbell squat',
    'back squat',
    'front squat',
    'goblet squat',
    'hack squat',
    'squat',
    'bulgarian split',
    'split squat',
    'pistol squat',
    'wall sit',
    'step up',
    'step-up',
  ])) {
    return {MuscleGroup.quads, MuscleGroup.glutes};
  }

  // OVERHEAD PRESS / SHOULDER PRESS
  if (_matches(name, [
    'overhead press',
    'ohp',
    'shoulder press',
    'military press',
    'arnold press',
    'seated press',
    'standing press',
    'z press',
    'landmine press',
    'pike push',
    'handstand push',
  ])) {
    return {MuscleGroup.shoulders, MuscleGroup.triceps};
  }

  // PULL-UPS / CHIN-UPS
  if (_matches(name, [
    'pull up',
    'pull-up',
    'pullup',
    'chin up',
    'chin-up',
    'chinup',
  ])) {
    return {MuscleGroup.back, MuscleGroup.biceps};
  }

  // ROWS (back + biceps)
  if (_matches(name, [
    'barbell row',
    'bent over row',
    'bent-over row',
    'dumbbell row',
    'cable row',
    'seated row',
    'seated cable row',
    't-bar row',
    'pendlay row',
    'machine row',
    'chest supported row',
    'meadows row',
    'inverted row',
    'seal row',
    'cable back row',
  ])) {
    return {MuscleGroup.back, MuscleGroup.biceps};
  }

  // LAT PULLDOWN
  if (_matches(name, [
    'lat pulldown',
    'pulldown',
    'lat pull',
    'pull down',
    'straight arm pulldown',
    'straight-arm pulldown',
  ])) {
    return {MuscleGroup.back, MuscleGroup.biceps};
  }

  // FACE PULLS — shoulders (rear delt) + back
  if (_matches(name, ['face pull', 'face-pull'])) {
    return {MuscleGroup.shoulders, MuscleGroup.back};
  }

  // LATERAL / FRONT RAISES — shoulders
  if (_matches(name, [
    'lateral raise',
    'side raise',
    'side lateral',
    'front raise',
    'upright row',
    'cable raise',
    'cable lateral',
    'machine lateral',
    'dumbbell raise',
  ])) {
    return {MuscleGroup.shoulders};
  }

  // BICEP CURLS
  if (_matches(name, [
    'dumbbell curl',
    'barbell curl',
    'hammer curl',
    'ez bar curl',
    'preacher curl',
    'concentration curl',
    'cable curl',
    'spider curl',
    'reverse curl',
    'zottman curl',
    'incline curl',
    'machine curl',
    'curl',
  ])) {
    return {MuscleGroup.biceps};
  }

  // TRICEP ISOLATION
  if (_matches(name, [
    'tricep pushdown',
    'tricep push down',
    'skull crusher',
    'skullcrusher',
    'lying tricep',
    'overhead tricep',
    'tricep extension',
    'cable tricep',
    'close grip bench',
    'close-grip bench',
    'diamond push',
    'tricep kickback',
    'rope pushdown',
    'v-bar pushdown',
    'tricep',
  ])) {
    return {MuscleGroup.triceps};
  }

  // LEG PRESS
  if (_matches(name, ['leg press'])) {
    return {MuscleGroup.quads, MuscleGroup.glutes};
  }

  // LEG EXTENSION
  if (_matches(name, ['leg extension'])) {
    return {MuscleGroup.quads};
  }

  // LEG CURL
  if (_matches(name, [
    'leg curl',
    'hamstring curl',
    'nordic curl',
    'glute ham raise',
    'lying leg curl',
    'seated leg curl',
  ])) {
    return {MuscleGroup.hamstrings};
  }

  // HIP THRUST / GLUTE BRIDGE
  if (_matches(name, [
    'hip thrust',
    'glute bridge',
    'hip bridge',
    'donkey kick',
    'cable kickback',
    'fire hydrant',
    'hip abduction',
    'hip extension',
    'cable pull through',
    'kneeling hip thrust',
  ])) {
    return {MuscleGroup.glutes};
  }

  // LUNGES
  if (_matches(name, [
    'lunge',
    'walking lunge',
    'reverse lunge',
    'lateral lunge',
    'curtsy lunge',
  ])) {
    return {MuscleGroup.quads, MuscleGroup.glutes, MuscleGroup.hamstrings};
  }

  // CALF RAISES
  if (_matches(name, [
    'calf raise',
    'calf raises',
    'standing calf',
    'seated calf',
    'donkey calf',
    'jump rope',
    'box jump',
    'jump squat',
  ])) {
    return {MuscleGroup.calves};
  }

  // CORE / ABS
  if (_matches(name, [
    'plank',
    'side plank',
    'crunch',
    'sit up',
    'situp',
    'ab crunch',
    'leg raise',
    'leg raises',
    'russian twist',
    'cable crunch',
    'hanging leg',
    'hanging knee',
    'ab wheel',
    'mountain climber',
    'hollow hold',
    'dead bug',
    'bicycle crunch',
    'v-up',
    'v up',
    'flutter kick',
    'toe touch',
    'windmill',
    'pallof press',
    'ab rollout',
    'dragon flag',
  ])) {
    return {MuscleGroup.core};
  }

  // SHRUGS — traps (map to back/shoulders)
  if (_matches(name, [
    'shrug',
    'dumbbell shrug',
    'barbell shrug',
    'cable shrug',
  ])) {
    return {MuscleGroup.back, MuscleGroup.shoulders};
  }

  // BACK EXTENSIONS / HYPEREXTENSIONS
  if (_matches(name, [
    'back extension',
    'hyperextension',
    'good morning',
    'superman',
    'reverse hyperextension',
    'back raise',
  ])) {
    return {MuscleGroup.back, MuscleGroup.hamstrings, MuscleGroup.glutes};
  }

  return {};
}

// ── Helper ────────────────────────────────────────────────────────────────────

bool _matches(String name, List<String> keywords) {
  for (final kw in keywords) {
    if (name == kw || name.contains(kw)) return true;
  }
  return false;
}
