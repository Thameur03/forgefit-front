class MuscleVolumeModel {
  final String muscleGroup;
  final double totalVolumeKg;
  final int totalSets;
  final double percentage;
  final double previousVolumeKg;
  final double trendPercent;

  const MuscleVolumeModel({
    required this.muscleGroup,
    required this.totalVolumeKg,
    required this.totalSets,
    required this.percentage,
    required this.previousVolumeKg,
    required this.trendPercent,
  });

  factory MuscleVolumeModel.fromJson(Map<String, dynamic> json) {
    return MuscleVolumeModel(
      muscleGroup: json['muscle_group'] as String,
      totalVolumeKg: (json['total_volume_kg'] as num).toDouble(),
      totalSets: json['total_sets'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      previousVolumeKg: (json['previous_volume_kg'] as num).toDouble(),
      trendPercent: (json['trend_percent'] as num).toDouble(),
    );
  }
}
