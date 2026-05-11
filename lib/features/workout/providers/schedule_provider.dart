import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/scheduled_workout_model.dart';

class ScheduleProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  ScheduleProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  ScheduledWorkoutModel? _todayScheduled;
  // key = normalized date (year/month/day only)
  final Map<DateTime, ScheduledWorkoutModel> _scheduledByDate = {};
  bool _isLoading = false;
  String? _error;

  ScheduledWorkoutModel? get todayScheduled => _todayScheduled;
  Map<DateTime, ScheduledWorkoutModel> get scheduledByDate => _scheduledByDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // ── Load today's scheduled workout ────────────────────────────────────────

  Future<void> loadToday() async {
    try {
      final response = await _apiClient.get(ApiConstants.scheduleToday);
      _todayScheduled = ScheduledWorkoutModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (_) {
      // 404 = no scheduled workout today — that's normal
      _todayScheduled = null;
    }
    notifyListeners();
  }

  // ── Load month (for calendar markers) ────────────────────────────────────

  Future<void> loadMonth(DateTime month) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.get(
        ApiConstants.scheduleMonth,
        queryParameters: {
          'year': month.year.toString(),
          'month': month.month.toString(),
        },
      );
      final list = (response.data as List)
          .map((e) => ScheduledWorkoutModel.fromJson(e as Map<String, dynamic>))
          .toList();
      for (final sw in list) {
        _scheduledByDate[_dateOnly(sw.scheduledDate)] = sw;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Schedule a workout ────────────────────────────────────────────────────

  Future<ScheduledWorkoutModel?> scheduleWorkout({
    required DateTime date,
    required int programDayId,
  }) async {
    try {
      final dateStr =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _apiClient.post(
        ApiConstants.schedule,
        data: {
          'program_day_id': programDayId,
          'scheduled_date': dateStr,
        },
      );
      final sw = ScheduledWorkoutModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      _scheduledByDate[_dateOnly(sw.scheduledDate)] = sw;

      // Update today if applicable
      final today = _dateOnly(DateTime.now());
      if (_dateOnly(sw.scheduledDate) == today) {
        _todayScheduled = sw;
      }

      _error = null;
      notifyListeners();
      return sw;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ── Delete a scheduled workout ────────────────────────────────────────────

  Future<bool> deleteScheduled(int id) async {
    try {
      await _apiClient.delete('${ApiConstants.schedule}$id');
      _scheduledByDate.removeWhere((_, v) => v.id == id);
      if (_todayScheduled?.id == id) _todayScheduled = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Returns the scheduled workout for a given date, or null.
  ScheduledWorkoutModel? getForDate(DateTime date) =>
      _scheduledByDate[_dateOnly(date)];

  bool hasScheduledOn(DateTime date) =>
      _scheduledByDate.containsKey(_dateOnly(date));
}
