// Models for the nutrition analytics dashboard.
// Maps to backend `GET /stats/nutrition-dashboard?days=N`.

class MacroSplit {
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;

  const MacroSplit({
    this.proteinPercent = 0,
    this.carbsPercent = 0,
    this.fatPercent = 0,
  });

  factory MacroSplit.fromJson(Map<String, dynamic> json) => MacroSplit(
        proteinPercent: (json['protein_percent'] ?? 0).toDouble(),
        carbsPercent: (json['carbs_percent'] ?? 0).toDouble(),
        fatPercent: (json['fat_percent'] ?? 0).toDouble(),
      );
}

class CalorieConsistency {
  final double? standardDeviation;
  final double? coefficientOfVariation;
  final String label;

  const CalorieConsistency({
    this.standardDeviation,
    this.coefficientOfVariation,
    this.label = 'Not enough data',
  });

  factory CalorieConsistency.fromJson(Map<String, dynamic> json) =>
      CalorieConsistency(
        standardDeviation: (json['standard_deviation'] as num?)?.toDouble(),
        coefficientOfVariation:
            (json['coefficient_of_variation'] as num?)?.toDouble(),
        label: json['label'] as String? ?? 'Not enough data',
      );
}

class NutritionDailyPoint {
  final DateTime date;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const NutritionDailyPoint({
    required this.date,
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
  });

  factory NutritionDailyPoint.fromJson(Map<String, dynamic> json) =>
      NutritionDailyPoint(
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        calories: (json['calories'] ?? 0).toDouble(),
        proteinG: (json['protein_g'] ?? 0).toDouble(),
        carbsG: (json['carbs_g'] ?? 0).toDouble(),
        fatG: (json['fat_g'] ?? 0).toDouble(),
      );
}

class NutritionPeriodSummary {
  final double averageCalories;
  final double averageProteinG;

  const NutritionPeriodSummary({
    this.averageCalories = 0,
    this.averageProteinG = 0,
  });

  factory NutritionPeriodSummary.fromJson(Map<String, dynamic> json) =>
      NutritionPeriodSummary(
        averageCalories: (json['average_calories'] ?? 0).toDouble(),
        averageProteinG: (json['average_protein_g'] ?? 0).toDouble(),
      );
}

class NutritionDashboardStats {
  final int periodDays;
  final int loggedDays;
  final double loggingConsistencyPercent;

  final double averageCalories;
  final double averageProteinG;
  final double averageCarbsG;
  final double averageFatG;

  final double? proteinPerKg;

  final MacroSplit macroSplit;

  final NutritionPeriodSummary currentPeriod;
  final NutritionPeriodSummary previousPeriod;

  final double calorieChangePercent;
  final double proteinChangePercent;

  final CalorieConsistency calorieConsistency;

  final List<NutritionDailyPoint> dailyPoints;
  final List<String> insights;

  const NutritionDashboardStats({
    this.periodDays = 14,
    this.loggedDays = 0,
    this.loggingConsistencyPercent = 0,
    this.averageCalories = 0,
    this.averageProteinG = 0,
    this.averageCarbsG = 0,
    this.averageFatG = 0,
    this.proteinPerKg,
    this.macroSplit = const MacroSplit(),
    this.currentPeriod = const NutritionPeriodSummary(),
    this.previousPeriod = const NutritionPeriodSummary(),
    this.calorieChangePercent = 0,
    this.proteinChangePercent = 0,
    this.calorieConsistency = const CalorieConsistency(),
    this.dailyPoints = const [],
    this.insights = const [],
  });

  factory NutritionDashboardStats.fromJson(Map<String, dynamic> json) =>
      NutritionDashboardStats(
        periodDays: json['period_days'] ?? 14,
        loggedDays: json['logged_days'] ?? 0,
        loggingConsistencyPercent:
            (json['logging_consistency_percent'] ?? 0).toDouble(),
        averageCalories: (json['average_calories'] ?? 0).toDouble(),
        averageProteinG: (json['average_protein_g'] ?? 0).toDouble(),
        averageCarbsG: (json['average_carbs_g'] ?? 0).toDouble(),
        averageFatG: (json['average_fat_g'] ?? 0).toDouble(),
        proteinPerKg: (json['protein_per_kg'] as num?)?.toDouble(),
        macroSplit: json['macro_split'] != null
            ? MacroSplit.fromJson(json['macro_split'])
            : const MacroSplit(),
        currentPeriod: json['current_period'] != null
            ? NutritionPeriodSummary.fromJson(json['current_period'])
            : const NutritionPeriodSummary(),
        previousPeriod: json['previous_period'] != null
            ? NutritionPeriodSummary.fromJson(json['previous_period'])
            : const NutritionPeriodSummary(),
        calorieChangePercent:
            (json['calorie_change_percent'] ?? 0).toDouble(),
        proteinChangePercent:
            (json['protein_change_percent'] ?? 0).toDouble(),
        calorieConsistency: json['calorie_consistency'] != null
            ? CalorieConsistency.fromJson(json['calorie_consistency'])
            : const CalorieConsistency(),
        dailyPoints: ((json['daily_points'] as List?) ?? [])
            .map((e) => NutritionDailyPoint.fromJson(e))
            .toList(),
        insights: ((json['insights'] as List?) ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}
