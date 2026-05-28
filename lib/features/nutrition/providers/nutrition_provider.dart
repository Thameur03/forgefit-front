import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/nutrition_model.dart';
import '../models/food_filter_model.dart';

class NutritionProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  // ── Per-date caches ────────────────────────────────────────────────────────
  /// Stores summaries indexed by 'YYYY-MM-DD' key so navigating away and back
  /// always shows the correct date's data without stale overlap.
  final Map<String, DailyNutritionSummary> _summariesByDate = {};
  final Map<String, List<NutritionModel>> _logsByDate = {};

  bool _isLoading = false;
  String? _errorMessage;

  // Food filter state
  List<FoodFilterModel> _foodFilters = [];
  FoodFilterModel? _selectedFoodFilter;
  bool _loadingFilters = false;
  String? _filtersError;

  NutritionProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  // ── Public getters ─────────────────────────────────────────────────────────

  /// Summary for the given date key (e.g. '2026-05-04'), or null if not loaded.
  DailyNutritionSummary? summaryForDate(String dateKey) =>
      _summariesByDate[dateKey];

  /// Logs for the given date key, or empty list.
  List<NutritionModel> logsForDate(String dateKey) =>
      _logsByDate[dateKey] ?? [];

  /// Convenience getters that the Nutrition screen previously used.
  /// These now return the *today* entry so existing call sites keep working.
  DailyNutritionSummary? get todaySummary =>
      _summariesByDate[_todayKey()];
  List<NutritionModel> get todayLogs =>
      _logsByDate[_todayKey()] ?? [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<FoodFilterModel> get foodFilters => _foodFilters;
  FoodFilterModel? get selectedFoodFilter => _selectedFoodFilter;
  bool get loadingFilters => _loadingFilters;
  String? get filtersError => _filtersError;

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _todayKey() => dateKey(DateTime.now());

  static bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _setLoading(bool value) {
    _isLoading = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String? message) {
    _errorMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _storeSummary(String key, Map<String, dynamic> data) {
    _summariesByDate[key] = DailyNutritionSummary(
      totalCalories: (data['total_calories'] as num?)?.toDouble() ?? 0.0,
      totalProtein:  (data['total_protein_g'] as num?)?.toDouble() ?? 0.0,
      totalCarbs:    (data['total_carbs_g']   as num?)?.toDouble() ?? 0.0,
      totalFat:      (data['total_fat_g']     as num?)?.toDouble() ?? 0.0,
    );
    final logsList = data['logs'] as List? ?? [];
    _logsByDate[key] = logsList
        .map((log) => NutritionModel.fromJson(log as Map<String, dynamic>))
        .toList();
  }

  // ── Load endpoints ─────────────────────────────────────────────────────────

  Future<void> loadTodayNutrition() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.get(ApiConstants.nutritionToday);
      final data = response.data as Map<String, dynamic>;
      _storeSummary(_todayKey(), data);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load nutrition data');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadNutritionForDate(String date) async {
    _setLoading(true);
    _setError(null);
    try {
      final response =
          await _apiClient.get('${ApiConstants.nutritionDate}$date');
      final data = response.data as Map<String, dynamic>;
      _storeSummary(date, data);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load nutrition data');
    } finally {
      _setLoading(false);
    }
  }

  /// Returns all individual log entries from the last [days] days via the
  /// history endpoint.
  Future<List<NutritionModel>> loadNutritionHistory({int days = 30}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.nutritionHistory,
        queryParameters: {'limit': days},
      );
      final summaries = response.data as List? ?? [];
      final allLogs = <NutritionModel>[];
      for (final summary in summaries) {
        final logs = (summary as Map<String, dynamic>)['logs'] as List? ?? [];
        allLogs.addAll(
            logs.map((l) => NutritionModel.fromJson(l as Map<String, dynamic>)));
      }
      return allLogs;
    } catch (e) {
      return [];
    }
  }

  // ── Food search ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> searchFood(String query,
      {String? filterSlug}) async {
    if (query.trim().isEmpty && (filterSlug == null || filterSlug.isEmpty)) {
      return [];
    }
    try {
      final params = <String, dynamic>{};
      if (query.trim().isNotEmpty) params['q'] = query;
      if (filterSlug != null && filterSlug.isNotEmpty) {
        params['filter'] = filterSlug;
      }
      final response = await _apiClient.get(
        ApiConstants.foodSearch,
        queryParameters: params,
      );
      final list = response.data as List? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> loadFoodFilters() async {
    _loadingFilters = true;
    _filtersError = null;
    notifyListeners();
    try {
      final response = await _apiClient.get(ApiConstants.foodFilters);
      final rawList = response.data as List? ?? [];
      _foodFilters = rawList
          .map((f) => FoodFilterModel.fromJson(f as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _filtersError = e.toString();
      _foodFilters = [];
    } finally {
      _loadingFilters = false;
      notifyListeners();
    }
  }

  void selectFoodFilter(FoodFilterModel? filter) {
    _selectedFoodFilter = filter;
    notifyListeners();
  }

  // ── Write endpoints ────────────────────────────────────────────────────────

  /// POST a new nutrition log and refresh the correct date summary.
  ///
  /// [selectedDate] must match the `date` field in [payload].
  /// If null, today is assumed.
  ///
  /// Throws a user-readable String on failure so callers (e.g. FoodDetailScreen)
  /// can surface it in a SnackBar.
  Future<void> postNutritionLog(
    Map<String, dynamic> payload, {
    DateTime? selectedDate,
  }) async {
    final targetDate = selectedDate ?? DateTime.now();
    final key = dateKey(targetDate);

    debugPrint('[NutritionProvider] addFood body=${payload.map((k, v) => MapEntry(k, v.toString()))}');

    try {
      final response = await _apiClient.post(ApiConstants.nutrition, data: payload);
      debugPrint('[NutritionProvider] addFood status=${response.statusCode}');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final detail = e.response?.data;
      String msg;
      if (detail is Map && detail['detail'] != null) {
        final d = detail['detail'];
        if (d is List && d.isNotEmpty) {
          msg = d.map((item) => item['msg'] ?? item.toString()).join(', ');
        } else {
          msg = d.toString();
        }
      } else {
        msg = 'Failed to save food log (status $status)';
      }
      debugPrint('[NutritionProvider] addFood error=$msg');
      throw msg;
    } catch (e) {
      debugPrint('[NutritionProvider] addFood error=$e');
      throw 'Unexpected error saving food log: $e';
    }

    // ── Refresh the correct date so the UI updates immediately ──────────────
    if (_isSameDate(targetDate, DateTime.now())) {
      debugPrint('[NutritionProvider] refreshToday after addFood');
      await loadTodayNutrition();
    } else {
      debugPrint('[NutritionProvider] refreshDate=$key after addFood');
      await loadNutritionForDate(key);
    }
  }

  Future<bool> logFood(NutritionModel nutrition,
      {DateTime? selectedDate}) async {
    _setLoading(true);
    _setError(null);
    try {
      if (nutrition.id.isEmpty) {
        await _apiClient.post(
          ApiConstants.nutrition,
          data: nutrition.toJson(),
        );
      } else {
        await _apiClient.put(
          '${ApiConstants.nutrition}${nutrition.id}',
          data: nutrition.toJson(),
        );
      }
      final date = selectedDate ?? nutrition.consumedAt;
      if (_isSameDate(date, DateTime.now())) {
        await loadTodayNutrition();
      } else {
        await loadNutritionForDate(dateKey(date));
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteLog(String id, {DateTime? forDate}) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.delete('${ApiConstants.nutrition}$id');
      final date = forDate ?? DateTime.now();
      if (_isSameDate(date, DateTime.now())) {
        await loadTodayNutrition();
      } else {
        await loadNutritionForDate(dateKey(date));
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ── Nutrient cache ─────────────────────────────────────────────────────────

  final Map<String, List<Map<String, dynamic>>> _nutrientCache = {};

  Future<List<Map<String, dynamic>>> getNutrients({
    int? fdcId,
    String? foodName,
  }) async {
    if (fdcId != null) {
      final key = fdcId.toString();
      if (_nutrientCache.containsKey(key)) return _nutrientCache[key]!;
      try {
        final response = await _apiClient.get('/food/$fdcId/nutrients');
        final data =
            List<Map<String, dynamic>>.from(response.data as List? ?? []);
        if (data.isNotEmpty) {
          _nutrientCache[key] = data;
          return data;
        }
      } catch (_) {}
    }

    if (foodName != null && foodName.isNotEmpty) {
      final cacheKey = 'name:$foodName';
      if (_nutrientCache.containsKey(cacheKey)) {
        return _nutrientCache[cacheKey]!;
      }
      try {
        final searchResponse = await _apiClient.get(
          ApiConstants.foodSearch,
          queryParameters: {'q': foodName},
        );
        final results =
            List<Map<String, dynamic>>.from(searchResponse.data as List? ?? []);
        if (results.isNotEmpty) {
          final resolvedId = results.first['fdc_id'];
          if (resolvedId != null) {
            final nutrientResponse =
                await _apiClient.get('/food/$resolvedId/nutrients');
            final data = List<Map<String, dynamic>>.from(
                nutrientResponse.data as List? ?? []);
            if (data.isNotEmpty) {
              _nutrientCache[cacheKey] = data;
              return data;
            }
          }
        }
      } catch (_) {}
    }

    return [];
  }
}
