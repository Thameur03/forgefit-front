class ProgramExerciseModel {
  final int id;
  final String exerciseName;
  final int sets;
  final int reps;
  final double? weightKg;
  final int orderIndex;

  ProgramExerciseModel({
    required this.id,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weightKg,
    required this.orderIndex,
  });

  factory ProgramExerciseModel.fromJson(Map<String, dynamic> json) {
    return ProgramExerciseModel(
      id: json['id'],
      exerciseName: json['exercise_name'] ?? '',
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 8,
      weightKg: json['weight_kg'] != null
          ? (json['weight_kg'] as num).toDouble()
          : null,
      orderIndex: json['order_index'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exercise_name': exerciseName,
    'sets': sets,
    'reps': reps,
    if (weightKg != null) 'weight_kg': weightKg,
    'order_index': orderIndex,
  };
}

class ProgramDayModel {
  final int id;
  final int dayNumber;
  final String dayName;
  final List<ProgramExerciseModel> exercises;

  ProgramDayModel({
    required this.id,
    required this.dayNumber,
    required this.dayName,
    required this.exercises,
  });

  factory ProgramDayModel.fromJson(Map<String, dynamic> json) {
    return ProgramDayModel(
      id: json['id'],
      dayNumber: json['day_number'],
      dayName: json['day_name'] ?? '',
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => ProgramExerciseModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'day_number': dayNumber,
    'day_name': dayName,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}

class ProgramModel {
  final int id;
  final String name;
  final int? weeks;
  final int? daysPerWeek;
  final bool isActive;
  final String? sourceTemplate;
  final List<ProgramDayModel> days;

  ProgramModel({
    required this.id,
    required this.name,
    this.weeks,
    this.daysPerWeek,
    required this.isActive,
    this.sourceTemplate,
    this.days = const [],
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'],
      name: json['name'] ?? '',
      weeks: json['weeks'],
      daysPerWeek: json['days_per_week'],
      isActive: json['is_active'] ?? false,
      sourceTemplate: json['source_template'],
      days: (json['days'] as List? ?? [])
          .map((d) => ProgramDayModel.fromJson(d))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (weeks != null) 'weeks': weeks,
    if (daysPerWeek != null) 'days_per_week': daysPerWeek,
    'is_active': isActive,
    if (sourceTemplate != null) 'source_template': sourceTemplate,
    'days': days.map((d) => d.toJson()).toList(),
  };

  String get subtitle {
    final parts = <String>[];
    if (weeks != null) parts.add('$weeks Weeks');
    if (daysPerWeek != null) parts.add('${daysPerWeek}x per week');
    return parts.join('  •  ');
  }
}

class ProgramTemplate {
  final String name;
  final String slug;
  final int? weeks;
  final int? daysPerWeek;
  final List<ProgramDayModel> days;

  ProgramTemplate({
    required this.name,
    required this.slug,
    this.weeks,
    this.daysPerWeek,
    required this.days,
  });

  factory ProgramTemplate.fromJson(Map<String, dynamic> json) {
    return ProgramTemplate(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      weeks: json['weeks'],
      daysPerWeek: json['days_per_week'],
      days: (json['days'] as List? ?? [])
          .map((d) => ProgramDayModel.fromJson(d))
          .toList(),
    );
  }

  String get subtitle {
    final parts = <String>[];
    if (weeks != null) parts.add('$weeks Weeks');
    if (daysPerWeek != null) parts.add('${daysPerWeek}x per week');
    return parts.join('  •  ');
  }
}
