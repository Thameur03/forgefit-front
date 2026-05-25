class ProgramExerciseModel {
  final int id;
  final String exerciseName;
  final String? exerciseId;   // ExerciseDB ID — null for manual/legacy exercises
  final int sets;
  final int reps;
  final double? weightKg;
  final int? restSeconds;
  final int orderIndex;

  ProgramExerciseModel({
    required this.id,
    required this.exerciseName,
    this.exerciseId,
    required this.sets,
    required this.reps,
    this.weightKg,
    this.restSeconds,
    required this.orderIndex,
  });

  factory ProgramExerciseModel.fromJson(Map<String, dynamic> json) {
    return ProgramExerciseModel(
      id: json['id'] as int,
      exerciseName: json['exercise_name'] as String? ?? '',
      exerciseId: json['exercise_id'] as String?,
      sets: json['sets'] as int? ?? 3,
      reps: json['reps'] as int? ?? 8,
      weightKg: json['weight_kg'] != null
          ? (json['weight_kg'] as num).toDouble()
          : null,
      restSeconds: json['rest_seconds'] as int?,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exercise_name': exerciseName,
    if (exerciseId != null) 'exercise_id': exerciseId,
    'sets': sets,
    'reps': reps,
    if (weightKg != null) 'weight_kg': weightKg,
    if (restSeconds != null) 'rest_seconds': restSeconds,
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
      id: json['id'] as int? ?? 0,
      dayNumber: json['day_number'] as int? ?? 0,
      dayName: json['day_name'] as String? ?? '',
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => ProgramExerciseModel.fromJson(e as Map<String, dynamic>))
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

/// A program template managed by an admin, stored in the DB.
/// Comes from GET /programs/global-templates (no auth required).
/// All optional fields are parsed defensively — will not crash on nulls.
class ProgramDbTemplateModel {
  final int id;
  final String name;
  final int? weeks;
  final int? daysPerWeek;
  final String? description;
  final String? difficulty;
  final String? goal;
  final bool isActive;
  final List<ProgramDayModel> days;

  const ProgramDbTemplateModel({
    required this.id,
    required this.name,
    this.weeks,
    this.daysPerWeek,
    this.description,
    this.difficulty,
    this.goal,
    this.isActive = true,
    this.days = const [],
  });

  factory ProgramDbTemplateModel.fromJson(Map<String, dynamic> json) {
    return ProgramDbTemplateModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Untitled Program',
      weeks: json['weeks'] as int?,
      daysPerWeek: json['days_per_week'] as int?,
      description: json['description'] as String?,
      difficulty: json['difficulty'] as String?,
      goal: json['goal'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      days: ((json['days'] as List?) ?? [])
          .map((d) => ProgramDayModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  String get subtitle {
    final parts = <String>[];
    if (weeks != null) parts.add('$weeks Weeks');
    if (daysPerWeek != null) parts.add('${daysPerWeek}x/week');
    return parts.join('  •  ');
  }
}
