import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/stats_model.dart';

class StatsProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<WeeklyVolumeModel> _weeklyVolume = [];
  List<MacroTrendModel> _nutritionTrend = [];
  List<PersonalRecordModel> _personalRecords = [];
  int _currentStreakDays = 0;
  
  bool _isLoading = false;
  String? _errorMessage;

  StatsProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  List<WeeklyVolumeModel> get weeklyVolume => _weeklyVolume;
  List<MacroTrendModel> get nutritionTrend => _nutritionTrend;
  List<PersonalRecordModel> get personalRecords => _personalRecords;
  int get currentStreakDays => _currentStreakDays;
  
  bool get isLoading => _isLoading;
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

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
