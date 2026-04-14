class WeeklyVolumeModel {
  final DateTime date;
  final double volume;
  final int workoutCount;

  WeeklyVolumeModel({
    required this.date,
    required this.volume,
    this.workoutCount = 0,
  });

  factory WeeklyVolumeModel.fromJson(Map<String, dynamic> json) {
    return WeeklyVolumeModel(
      date: DateTime.tryParse(json['week_start'] ?? json['date'] ?? '') ??
          DateTime.now(),
      volume: (json['total_volume_kg'] ?? json['volume'] ?? 0).toDouble(),
      workoutCount: json['workout_count'] ?? 0,
    );
  }
}

class MacroTrendModel {
  final DateTime date;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  MacroTrendModel({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MacroTrendModel.fromJson(Map<String, dynamic> json) {
    return MacroTrendModel(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      calories: json['calories'] ?? 0,
      protein: (json['protein_g'] ?? 0).toDouble(),
      carbs: (json['carbs_g'] ?? 0).toDouble(),
      fat: (json['fat_g'] ?? 0).toDouble(),
    );
  }
}

class PersonalRecordModel {
  final String exerciseName;
  final double maxWeight;
  final int maxReps;
  final DateTime dateAchieved;

  PersonalRecordModel({
    required this.exerciseName,
    required this.maxWeight,
    this.maxReps = 0,
    required this.dateAchieved,
  });

  factory PersonalRecordModel.fromJson(Map<String, dynamic> json) {
    return PersonalRecordModel(
      exerciseName: json['exercise_name'] ?? '',
      maxWeight: (json['max_weight_kg'] ?? json['max_weight'] ?? 0).toDouble(),
      maxReps: json['max_reps'] ?? 0,
      dateAchieved:
          DateTime.tryParse(json['date_achieved'] ?? '') ?? DateTime.now(),
    );
  }
}

