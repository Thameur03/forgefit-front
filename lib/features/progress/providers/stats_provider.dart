import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/stats_model.dart';
import '../models/muscle_volume_model.dart';

class StatsProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<WeeklyVolumeModel> _weeklyVolume = [];
  List<MacroTrendModel> _nutritionTrend = [];
  List<PersonalRecordModel> _personalRecords = [];
  int _currentStreakDays = 0;
  List<MuscleVolumeModel> _muscleVolume = [];
  String _selectedPeriod = '1m';
  String _muscleVolumePeriodLabel = '';

  bool _isLoading = false;
  bool _isMuscleVolumeLoading = false;
  String? _errorMessage;

  StatsProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  List<WeeklyVolumeModel> get weeklyVolume => _weeklyVolume;
  List<MacroTrendModel> get nutritionTrend => _nutritionTrend;
  List<PersonalRecordModel> get personalRecords => _personalRecords;
  int get currentStreakDays => _currentStreakDays;
  List<MuscleVolumeModel> get muscleVolume => _muscleVolume;
  String get selectedPeriod => _selectedPeriod;
  String get muscleVolumePeriodLabel => _muscleVolumePeriodLabel;

  bool get isLoading => _isLoading;
  bool get isMuscleVolumeLoading => _isMuscleVolumeLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadWorkoutStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.statsWorkouts);
      if (response.data != null && response.data is Map) {
        _currentStreakDays = response.data['current_streak_days'] ?? 0;
        notifyListeners();
      }
    } catch (_) {
      _currentStreakDays = 0;
    }
  }

  Future<void> loadAllStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch all stats concurrently
      final responses = await Future.wait([
        _apiClient.get(ApiConstants.statsWeeklyVolume),
        _apiClient.get(ApiConstants.statsNutritionTrend),
        _apiClient.get(ApiConstants.statsPersonalRecords),
        _apiClient.get(ApiConstants.statsWorkouts),
      ]);

      // Parse Weekly Volume
      _weeklyVolume = (responses[0].data as List?)
              ?.map((v) => WeeklyVolumeModel.fromJson(v))
              .toList() ??
          [];

      // Parse Nutrition Trend
      _nutritionTrend = (responses[1].data as List?)
              ?.map((t) => MacroTrendModel.fromJson(t))
              .toList() ??
          [];

      // Parse PRs
      _personalRecords = (responses[2].data as List?)
              ?.map((pr) => PersonalRecordModel.fromJson(pr))
              .toList() ??
          [];

      // Parse streak from workouts endpoint
      if (responses[3].data != null && responses[3].data is Map) {
        _currentStreakDays = responses[3].data['current_streak_days'] ?? 0;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMuscleVolume(String period) async {
    _isMuscleVolumeLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.get(
        ApiConstants.statsMuscleVolume,
        queryParameters: {'period': period},
      );
      final data = response.data as Map<String, dynamic>;
      _muscleVolumePeriodLabel = data['period_label'] as String? ?? '';
      _muscleVolume = (data['items'] as List?)
              ?.map((item) =>
                  MuscleVolumeModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
    } catch (_) {
      _muscleVolume = [];
    } finally {
      _isMuscleVolumeLoading = false;
      notifyListeners();
    }
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    loadMuscleVolume(period);
  }
}
