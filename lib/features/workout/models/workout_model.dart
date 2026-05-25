class WorkoutSetDetail {
  final String id;
  final String exerciseName;
  final String targetMuscle; // e.g. 'pectorals', 'quads' from ExerciseDB
  final int reps;
  final double weightKg;
  final Map<String, dynamic>? lastSession;

  WorkoutSetDetail({
    required this.id,
    required this.exerciseName,
    this.targetMuscle = '',
    required this.reps,
    required this.weightKg,
    this.lastSession,
  });

  factory WorkoutSetDetail.fromJson(Map<String, dynamic> json) {
    return WorkoutSetDetail(
      id: (json['id'] ?? 0).toString(),
      exerciseName: json['exercise_name'] ?? '',
      targetMuscle: json['target_muscle'] as String? ?? '',
      reps: json['reps'] ?? 0,
      weightKg: (json['weight_kg'] ?? 0).toDouble(),
      lastSession: json['last_session'] as Map<String, dynamic>?,
    );
  }
}

class WorkoutSetModel {
  final String id;
  final int reps;
  final double weight;
  final bool isCompleted;

  WorkoutSetModel({
    required this.id,
    required this.reps,
    required this.weight,
    this.isCompleted = false,
  });

  factory WorkoutSetModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSetModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      reps: json['reps'] ?? 0,
      weight: (json['weight'] ?? 0).toDouble(),
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'reps': reps,
      'weight': weight,
      'is_completed': isCompleted,
    };
  }
}

class WorkoutExerciseModel {
  final String id;
  final String name;
  final List<WorkoutSetModel> sets;

  WorkoutExerciseModel({
    required this.id,
    required this.name,
    required this.sets,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      id: (json['id'] ?? json['exercise_id'] ?? '').toString(),
      name: json['name'] ?? '',
      sets: (json['sets'] as List?)
              ?.map((s) => WorkoutSetModel.fromJson(s))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': id,
      'name': name,
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }
}

class WorkoutModel {
  final String id;
  final String? name;
  final DateTime date;
  final int durationSeconds;
  final int totalSets;
  final double totalVolumeKg;
  final int caloriesBurned;
  final List<WorkoutSetDetail> sets;
  final List<WorkoutExerciseModel> exercises;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.date,
    required this.durationSeconds,
    this.totalSets = 0,
    this.totalVolumeKg = 0.0,
    this.caloriesBurned = 0,
    required this.sets,
    required this.exercises,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: (json['id'] ?? 0).toString(),
      name: (json['name'] as String?)?.isNotEmpty == true
          ? json['name']
          : (json['notes'] as String?)?.isNotEmpty == true
              ? json['notes']
              : null,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      durationSeconds: json['duration_seconds'] ?? 0,
      totalSets: json['total_sets'] ?? 0,
      totalVolumeKg: (json['total_volume_kg'] ?? 0).toDouble(),
      caloriesBurned: json['calories_burned'] ?? 0,
      sets: (json['sets'] as List?)
              ?.map((s) => WorkoutSetDetail.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      exercises: (json['exercises'] as List?)
              ?.map((e) => WorkoutExerciseModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (name != null) 'name': name,
      'date': date.toIso8601String(),
      'duration_seconds': durationSeconds,
      'total_sets': totalSets,
      'total_volume_kg': totalVolumeKg,
      if (caloriesBurned > 0) 'calories_burned': caloriesBurned,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}
