import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/nutrition_stats_model.dart';

class NutritionStatsProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  bool _isLoading = false;
  String? _error;
  int _selectedDays = 14;
  NutritionDashboardStats? _stats;

  NutritionStatsProvider({required ApiClient apiClient})
      : _apiClient = apiClient;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedDays => _selectedDays;
  NutritionDashboardStats? get stats => _stats;

  Future<void> loadStats({int? days}) async {
    final d = days ?? _selectedDays;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiClient.get(
        ApiConstants.nutritionDashboardStats,
        queryParameters: {'days': d},
      );
      _stats = NutritionDashboardStats.fromJson(
        response.data as Map<String, dynamic>,
      );
      _selectedDays = d;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDays(int days) {
    if (days == _selectedDays && _stats != null) return;
    _selectedDays = days;
    loadStats(days: days);
  }
}
