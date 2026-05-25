import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../workout/models/workout_model.dart';
import '../models/muscle_group.dart';
import '../models/muscle_analytics_model.dart';
import '../services/progress_analytics_calculator.dart';

class ProgressProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  ProgressProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  bool isLoading = false;
  String? error;
  // Prevents re-fetching on every screen visit; refresh button uses force:true
  bool _alreadyLoaded = false;

  ProgressOverview? overview;
  Map<MuscleGroup, MuscleAnalytics> muscleAnalytics = {};

  Future<void> loadProgressAnalytics({bool force = false}) async {
    if (isLoading) return;
    if (_alreadyLoaded && !force) return; // use cached data
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Step 1: Fetch workout summaries (up to 100, covering 8+ weeks)
      final listResp = await _apiClient.get(
        '/workouts/',
        queryParameters: {'limit': '100', 'offset': '0'},
      );

      final rawList = listResp.data;
      List<Map<String, dynamic>> summaries = [];

      if (rawList is List) {
        summaries = rawList.cast<Map<String, dynamic>>();
      } else if (rawList is Map && rawList['items'] != null) {
        summaries = (rawList['items'] as List).cast<Map<String, dynamic>>();
      }

      if (summaries.isEmpty) {
        overview = const ProgressOverview(
          currentWeekTotalVolumeKg: 0,
          previousWeekTotalVolumeKg: 0,
          currentWeekTotalSets: 0,
          workoutsThisWeek: 0,
          totalVolumeTrend: [],
        );
        muscleAnalytics = {};
        _alreadyLoaded = true;
        return;
      }

      // Step 2: Fetch full details for each workout (to get set-level data)
      // Use Future.wait for concurrency — typically ~5-30 workouts in 8 weeks
      final detailFutures = summaries.map((s) async {
        try {
          final id = s['id']?.toString() ?? '';
          if (id.isEmpty) return WorkoutModel.fromJson(s);
          final detailResp = await _apiClient.get('/workouts/$id');
          return WorkoutModel.fromJson(
              detailResp.data as Map<String, dynamic>);
        } catch (_) {
          // Fall back to summary if detail fails
          return WorkoutModel.fromJson(s);
        }
      });

      final workouts = await Future.wait(detailFutures);

      overview = ProgressAnalyticsCalculator.computeOverview(workouts);
      muscleAnalytics =
          ProgressAnalyticsCalculator.computeAllMuscles(workouts);
      _alreadyLoaded = true;
    } catch (e) {
      debugPrint('[Progress] loadProgressAnalytics error: $e');
      error = 'Could not load workout history.';
      overview = const ProgressOverview(
        currentWeekTotalVolumeKg: 0,
        previousWeekTotalVolumeKg: 0,
        currentWeekTotalSets: 0,
        workoutsThisWeek: 0,
        totalVolumeTrend: [],
      );
      muscleAnalytics = {};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
