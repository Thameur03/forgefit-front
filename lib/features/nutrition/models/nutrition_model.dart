class NutritionModel {
  final String id;
  final String foodName;
  final DateTime consumedAt;
  final String mealType;
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int? fdcId; // Part 4: fdc_id for nutrient lookup

  NutritionModel({
    required this.id,
    required this.foodName,
    required this.consumedAt,
    required this.mealType,
    required this.amount,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fdcId,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      foodName: json['food_name'] ?? '',
      consumedAt: json['consumed_at'] != null
          ? DateTime.tryParse(json['consumed_at']) ?? DateTime.now()
          : (json['date'] != null
              ? DateTime.tryParse(json['date']) ?? DateTime.now()
              : DateTime.now()),
      mealType: json['meal_name'] ?? json['meal_type'] ?? 'Snack',
      amount: (json['amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'g',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein_g'] ?? 0).toDouble(),
      carbs: (json['carbs_g'] ?? 0).toDouble(),
      fat: (json['fat_g'] ?? 0).toDouble(),
      fdcId: json['fdc_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'food_name': foodName,
      'date': consumedAt.toIso8601String().split('T')[0],
      'meal_name': mealType,
      'calories': calories,
      'protein_g': protein,
      'carbs_g': carbs,
      'fat_g': fat,
      if (fdcId != null) 'fdc_id': fdcId,
    };
  }

  /// Constructs a NutritionModel from the flat quick-add body map.
  /// id is left empty since the entry hasn't been saved to the server yet.
  factory NutritionModel.fromQuickAdd(Map<String, dynamic> data) {
    return NutritionModel(
      id: '',
      foodName: data['food_name'] as String? ?? '',
      consumedAt: DateTime.now(),
      mealType: data['meal_name'] as String? ?? 'Breakfast',
      amount: 0,
      unit: 'g',
      calories: (data['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (data['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbs: (data['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fat: (data['fat_g'] as num?)?.toDouble() ?? 0.0,
      fdcId: data['fdc_id'] as int?,
    );
  }
}

/// Backend returns summary fields at the top level of /nutrition/today:
/// { "date": "...", "total_calories": 0.0, "total_protein_g": 0.0, ... }
class DailyNutritionSummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  DailyNutritionSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) {
    return DailyNutritionSummary(
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (json['total_protein_g'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (json['total_carbs_g'] as num?)?.toDouble() ?? 0.0,
      totalFat: (json['total_fat_g'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
