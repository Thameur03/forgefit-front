class AICoachRecommendation {
  final String title;
  final String reason;
  final String action;
  final String priority;
  final String category;
  final int impact;
  final String? metric;

  AICoachRecommendation({
    required this.title,
    required this.reason,
    required this.action,
    required this.priority,
    required this.category,
    required this.impact,
    this.metric,
  });

  factory AICoachRecommendation.fromJson(Map<String, dynamic> json) {
    return AICoachRecommendation(
      title: json['title'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      action: json['action'] as String? ?? '',
      priority: json['priority'] as String? ?? 'medium',
      category: json['category'] as String? ?? 'workout',
      impact: (json['impact'] as num?)?.toInt() ?? 0,
      metric: json['metric'] as String?,
    );
  }
}

class AICoachWarning {
  final String code;
  final String title;
  final String detail;
  final String priority;

  AICoachWarning({
    required this.code,
    required this.title,
    required this.detail,
    required this.priority,
  });

  factory AICoachWarning.fromJson(Map<String, dynamic> json) {
    return AICoachWarning(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      priority: json['priority'] as String? ?? 'medium',
    );
  }
}

class AICoachScoreBreakdown {
  final double noWorkoutsDeduction;
  final double adherenceDeduction;
  final double volumeSpikeDeduction;
  final double muscleImbalanceDeduction;
  final double lowProteinDeduction;
  final double lowLoggingDeduction;
  final double calorieCvDeduction;
  final bool missingWeightNote;
  final bool missingActiveProgramNote;

  AICoachScoreBreakdown({
    required this.noWorkoutsDeduction,
    required this.adherenceDeduction,
    required this.volumeSpikeDeduction,
    required this.muscleImbalanceDeduction,
    required this.lowProteinDeduction,
    required this.lowLoggingDeduction,
    required this.calorieCvDeduction,
    required this.missingWeightNote,
    required this.missingActiveProgramNote,
  });

  factory AICoachScoreBreakdown.fromJson(Map<String, dynamic> json) {
    return AICoachScoreBreakdown(
      noWorkoutsDeduction:
          (json['no_workouts_deduction'] as num?)?.toDouble() ?? 0.0,
      adherenceDeduction:
          (json['adherence_deduction'] as num?)?.toDouble() ?? 0.0,
      volumeSpikeDeduction:
          (json['volume_spike_deduction'] as num?)?.toDouble() ?? 0.0,
      muscleImbalanceDeduction:
          (json['muscle_imbalance_deduction'] as num?)?.toDouble() ?? 0.0,
      lowProteinDeduction:
          (json['low_protein_deduction'] as num?)?.toDouble() ?? 0.0,
      lowLoggingDeduction:
          (json['low_logging_deduction'] as num?)?.toDouble() ?? 0.0,
      calorieCvDeduction:
          (json['calorie_cv_deduction'] as num?)?.toDouble() ?? 0.0,
      missingWeightNote: json['missing_weight_note'] as bool? ?? false,
      missingActiveProgramNote:
          json['missing_active_program_note'] as bool? ?? false,
    );
  }
}

class AICoachSummaryModel {
  final DateTime generatedAt;
  final int periodDays;

  final int overallScore;
  final int trainingScore;
  final int nutritionScore;
  final int recoveryScore;
  final String readinessLabel;

  final String confidence;
  final String confidenceReason;
  final List<String> missingData;

  final String summary;
  final List<AICoachRecommendation> recommendations;
  final List<AICoachWarning> warnings;
  final String? nextBestAction;

  final AICoachScoreBreakdown scoreBreakdown;

  final int workoutsThisPeriod;
  final int workoutsPreviousPeriod;
  final double weeklyVolumeKg;
  final double previousWeeklyVolumeKg;
  final double? volumeChangePercent;

  final double averageDailyCalories;
  final double averageDailyProteinG;
  final double? proteinPerKg;
  final double nutritionLoggingConsistencyPercent;
  final double? calorieCoefficientOfVariation;

  final String disclaimer;

  AICoachSummaryModel({
    required this.generatedAt,
    required this.periodDays,
    required this.overallScore,
    required this.trainingScore,
    required this.nutritionScore,
    required this.recoveryScore,
    required this.readinessLabel,
    required this.confidence,
    required this.confidenceReason,
    required this.missingData,
    required this.summary,
    required this.recommendations,
    required this.warnings,
    this.nextBestAction,
    required this.scoreBreakdown,
    required this.workoutsThisPeriod,
    required this.workoutsPreviousPeriod,
    required this.weeklyVolumeKg,
    required this.previousWeeklyVolumeKg,
    this.volumeChangePercent,
    required this.averageDailyCalories,
    required this.averageDailyProteinG,
    this.proteinPerKg,
    required this.nutritionLoggingConsistencyPercent,
    this.calorieCoefficientOfVariation,
    required this.disclaimer,
  });

  factory AICoachSummaryModel.fromJson(Map<String, dynamic> json) {
    return AICoachSummaryModel(
      generatedAt: DateTime.tryParse(json['generated_at'] as String? ?? '') ??
          DateTime.now(),
      periodDays: (json['period_days'] as num?)?.toInt() ?? 7,
      overallScore: (json['overall_score'] as num?)?.toInt() ?? 0,
      trainingScore: (json['training_score'] as num?)?.toInt() ?? 0,
      nutritionScore: (json['nutrition_score'] as num?)?.toInt() ?? 0,
      recoveryScore: (json['recovery_score'] as num?)?.toInt() ?? 0,
      readinessLabel: json['readiness_label'] as String? ?? 'Moderate',
      confidence: json['confidence'] as String? ?? 'low',
      confidenceReason: json['confidence_reason'] as String? ?? '',
      missingData: (json['missing_data'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      summary: json['summary'] as String? ?? '',
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) =>
                  AICoachRecommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map(
                  (e) => AICoachWarning.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextBestAction: json['next_best_action'] as String?,
      scoreBreakdown: json['score_breakdown'] != null
          ? AICoachScoreBreakdown.fromJson(
              json['score_breakdown'] as Map<String, dynamic>)
          : AICoachScoreBreakdown.fromJson({}),
      workoutsThisPeriod:
          (json['workouts_this_period'] as num?)?.toInt() ?? 0,
      workoutsPreviousPeriod:
          (json['workouts_previous_period'] as num?)?.toInt() ?? 0,
      weeklyVolumeKg:
          (json['weekly_volume_kg'] as num?)?.toDouble() ?? 0.0,
      previousWeeklyVolumeKg:
          (json['previous_weekly_volume_kg'] as num?)?.toDouble() ?? 0.0,
      volumeChangePercent:
          (json['volume_change_percent'] as num?)?.toDouble(),
      averageDailyCalories:
          (json['average_daily_calories'] as num?)?.toDouble() ?? 0.0,
      averageDailyProteinG:
          (json['average_daily_protein_g'] as num?)?.toDouble() ?? 0.0,
      proteinPerKg: (json['protein_per_kg'] as num?)?.toDouble(),
      nutritionLoggingConsistencyPercent:
          (json['nutrition_logging_consistency_percent'] as num?)
                  ?.toDouble() ??
              0.0,
      calorieCoefficientOfVariation:
          (json['calorie_coefficient_of_variation'] as num?)?.toDouble(),
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }
}
