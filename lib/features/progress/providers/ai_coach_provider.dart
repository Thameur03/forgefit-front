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

  /// Timestamp of last successful fetch — used for staleness checks.
  DateTime? _lastFetchedAt;

  Future<void> loadSummary({int days = 7, bool forceRefresh = false}) async {
    if (isLoading) return;

    // Allow cached result only if < 60 s old and same period
    if (!forceRefresh &&
        summary != null &&
        summary!.periodDays == days &&
        _lastFetchedAt != null &&
        DateTime.now().difference(_lastFetchedAt!).inSeconds < 60) {
      return;
    }

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
      _lastFetchedAt = DateTime.now();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Convenience method matched to RefreshIndicator / refresh button.
  Future<void> refreshSummary({int days = 7}) async {
    await loadSummary(days: days, forceRefresh: true);
  }

  /// Invalidate the cache so the next loadSummary will re-fetch.
  void invalidate() {
    _lastFetchedAt = null;
  }

  void clear() {
    summary = null;
    error = null;
    _lastFetchedAt = null;
    notifyListeners();
  }
}
