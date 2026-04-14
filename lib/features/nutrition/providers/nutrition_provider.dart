import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/nutrition_model.dart';

class NutritionProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<NutritionModel> _todayLogs = [];
  DailyNutritionSummary? _todaySummary;
  bool _isLoading = false;
  String? _errorMessage;

  NutritionProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  List<NutritionModel> get todayLogs => _todayLogs;
  DailyNutritionSummary? get todaySummary => _todaySummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  /// Backend returns:
  /// { "date": "...", "total_calories": 0.0, "total_protein_g": 0.0,
  ///   "total_carbs_g": 0.0, "total_fat_g": 0.0, "logs": [], "meals": {} }
  Future<void> loadTodayNutrition() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.get(ApiConstants.nutritionToday);
      final data = response.data as Map<String, dynamic>;

      _todaySummary = DailyNutritionSummary(
        totalCalories: (data['total_calories'] as num?)?.toDouble() ?? 0.0,
        totalProtein: (data['total_protein_g'] as num?)?.toDouble() ?? 0.0,
        totalCarbs: (data['total_carbs_g'] as num?)?.toDouble() ?? 0.0,
        totalFat: (data['total_fat_g'] as num?)?.toDouble() ?? 0.0,
      );

      final logsList = data['logs'] as List? ?? [];
      _todayLogs = logsList
          .map((log) => NutritionModel.fromJson(log as Map<String, dynamic>))
          .toList();

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

      _todaySummary = DailyNutritionSummary(
        totalCalories: (data['total_calories'] as num?)?.toDouble() ?? 0.0,
        totalProtein: (data['total_protein_g'] as num?)?.toDouble() ?? 0.0,
        totalCarbs: (data['total_carbs_g'] as num?)?.toDouble() ?? 0.0,
        totalFat: (data['total_fat_g'] as num?)?.toDouble() ?? 0.0,
      );

      final logsList = data['logs'] as List? ?? [];
      _todayLogs = logsList
          .map((log) => NutritionModel.fromJson(log as Map<String, dynamic>))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load nutrition data');
    } finally {
      _setLoading(false);
    }
  }

  /// Returns all individual log entries from the last [days] days via a
  /// single call to the history endpoint which embeds logs in each summary.
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

  /// Food search endpoint returns flat snake_case objects:
  /// [{ "fdc_id": 123, "name": "...", "brand": "...",
  ///    "calories": 0.0, "protein_g": 0.0, "carbs_g": 0.0, "fat_g": 0.0 }]
  Future<List<Map<String, dynamic>>> searchFood(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _apiClient.get(
        ApiConstants.foodSearch,
        queryParameters: {'q': query},
      );
      final list = response.data as List? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  /// Direct POST to /nutrition/ with a pre-built payload map.
  Future<void> postNutritionLog(Map<String, dynamic> payload) async {
    await _apiClient.post(ApiConstants.nutrition, data: payload);
    await loadTodayNutrition();
  }

  Future<bool> logFood(NutritionModel nutrition) async {
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
      await loadTodayNutrition();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteLog(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.delete('${ApiConstants.nutrition}$id');
      await loadTodayNutrition();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ── Nutrient cache for micronutrient dashboard ──────────────────────────────

  final Map<String, List<Map<String, dynamic>>> _nutrientCache = {};

  /// Fetches the full nutrient breakdown for a food.
  /// Tries [fdcId] first; falls back to searching by [foodName] to resolve
  /// an fdc_id and then fetching nutrients.
  /// Results are cached in memory for the lifetime of the provider.
  Future<List<Map<String, dynamic>>> getNutrients({
    int? fdcId,
    String? foodName,
  }) async {
    // ── Try fdcId first ──────────────────────────────────────────────────────
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

    // ── Fallback: search by food name → resolve fdc_id → fetch nutrients ──
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

