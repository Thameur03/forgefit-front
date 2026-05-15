import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/ai_coach_model.dart';

class AICoachProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  AICoachProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  bool isLoading = false;
  String? error;
  AICoachSummaryModel? summary;

  Future<void> loadSummary({int days = 7, bool forceRefresh = false}) async {
    if (isLoading) return;
    if (!forceRefresh && summary != null && summary!.periodDays == days) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _apiClient.wakeServer();
      final response = await _apiClient.get(
        ApiConstants.aiCoachSummary,
        queryParameters: {'days': days},
      );

      summary = AICoachSummaryModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    summary = null;
    error = null;
    notifyListeners();
  }
}
