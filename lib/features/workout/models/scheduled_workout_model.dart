import '../models/program_model.dart';

class ScheduledWorkoutModel {
  final int id;
  final int userId;
  final int programId;
  final int programDayId;
  final DateTime scheduledDate;
  final String dayName;
  final String programName;
  final List<ProgramExerciseModel> exercises;

  const ScheduledWorkoutModel({
    required this.id,
    required this.userId,
    required this.programId,
    required this.programDayId,
    required this.scheduledDate,
    required this.dayName,
    required this.programName,
    required this.exercises,
  });

  factory ScheduledWorkoutModel.fromJson(Map<String, dynamic> json) {
    return ScheduledWorkoutModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      programId: json['program_id'] as int,
      programDayId: json['program_day_id'] as int,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      dayName: json['day_name'] as String,
      programName: json['program_name'] as String,
      exercises: (json['exercises'] as List)
          .map((e) => ProgramExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Returns a synthetic ProgramDayModel so we can pass it to LogWorkoutScreen
  ProgramDayModel toProgramDayModel() {
    return ProgramDayModel(
      id: programDayId,
      dayNumber: 1,
      dayName: dayName,
      exercises: exercises,
    );
  }
}
