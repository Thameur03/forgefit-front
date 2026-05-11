import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/program_model.dart';

class ProgramProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<ProgramModel> _programs = [];
  List<ProgramTemplate> _templates = [];
  ProgramModel? _activeProgram;
  bool _isLoading = false;
  bool _isFromCache = false;
  String? _error;

  ProgramProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  List<ProgramModel> get programs => _programs;
  List<ProgramTemplate> get templates => _templates;
  ProgramModel? get activeProgram => _activeProgram;
  bool get isLoading => _isLoading;
  bool get isFromCache => _isFromCache;
  String? get error => _error;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<void> loadTemplates() async {
    try {
      final response = await _apiClient.get(ApiConstants.programTemplates);
      _templates = (response.data as List)
          .map((t) => ProgramTemplate.fromJson(t))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadPrograms() async {
    _setLoading(true);
    try {
      final response = await _apiClient.get(ApiConstants.programs);
      _programs = (response.data as List)
          .map((p) => ProgramModel.fromJson(p))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<ProgramModel?> loadProgramDetail(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.programs}$id');
      return ProgramModel.fromJson(response.data);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<ProgramModel?> adoptTemplate(String slug) async {
    try {
      final response = await _apiClient.post(
        '/programs/from-template/$slug',
        data: {},
      );
      final newProgram = ProgramModel.fromJson(response.data);
      _programs.insert(0, newProgram);
      notifyListeners();
      return newProgram;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<ProgramModel?> createProgram({
    required String name,
    int? weeks,
    int? daysPerWeek,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.programs,
        data: {
          'name': name,
          if (weeks != null) 'weeks': weeks,
          if (daysPerWeek != null) 'days_per_week': daysPerWeek,
        },
      );
      final newProgram = ProgramModel.fromJson(response.data);
      _programs.insert(0, newProgram);
      notifyListeners();
      return newProgram;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> activateProgram(int id) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.programs}$id/activate',
        data: {},
      );
      final updated = ProgramModel.fromJson(response.data);
      _programs = _programs.map((p) {
        if (p.id == id) return updated;
        return ProgramModel(
          id: p.id,
          name: p.name,
          weeks: p.weeks,
          daysPerWeek: p.daysPerWeek,
          isActive: false,
          sourceTemplate: p.sourceTemplate,
          days: p.days,
        );
      }).toList();
      _activeProgram = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProgram(int id) async {
    try {
      await _apiClient.delete('${ApiConstants.programs}$id');
      _programs.removeWhere((p) => p.id == id);
      if (_activeProgram?.id == id) _activeProgram = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadActiveProgram() async {
    try {
      final response = await _apiClient.get(ApiConstants.programsActive);
      _activeProgram = ProgramModel.fromJson(response.data);
      _isFromCache = false;
      notifyListeners();
      // Cache the active program for offline fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'cached_active_program',
          jsonEncode(_activeProgram!.toJson()),
        );
      } catch (_) {
        // Cache write failure is non-critical
      }
    } catch (e) {
      // Check if it's a 404 "No active program" response — that is a valid
      // empty state, NOT an offline/cache situation.
      final errorStr = e.toString();
      final is404 = errorStr.contains('404') ||
          errorStr.contains('No active program') ||
          errorStr.contains('not found');

      if (is404) {
        // Normal empty state: user simply has no active program yet.
        _activeProgram = null;
        _isFromCache = false;
        notifyListeners();
        return;
      }

      // Real network / server error — try loading from local cache.
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('cached_active_program');
        if (cached != null) {
          _activeProgram = ProgramModel.fromJson(jsonDecode(cached));
          _isFromCache = true;
        } else {
          _activeProgram = null;
          _isFromCache = false;
        }
      } catch (_) {
        _activeProgram = null;
        _isFromCache = false;
      }
      notifyListeners();
    }
  }

  Future<ProgramExerciseModel?> addExerciseToDay(
    int dayId, {
    required String exerciseName,
    required int sets,
    required int reps,
    double? weightKg,
  }) async {
    try {
      final response = await _apiClient.post(
        '/programs/days/$dayId/exercises',
        data: {
          'exercise_name': exerciseName,
          'sets': sets,
          'reps': reps,
          if (weightKg != null) 'weight_kg': weightKg,
          'order_index': 0,
        },
      );
      return ProgramExerciseModel.fromJson(response.data);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> removeExerciseFromDay(int dayId, int exerciseId) async {
    try {
      await _apiClient.delete(
        '/programs/days/$dayId/exercises/$exerciseId',
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<ProgramDayModel?> addDayToProgram(int programId, {required String dayName}) async {
    try {
      // Calculate next day number from current local state first (fast path),
      // then fall back to a fresh load if not available.
      final existing = _programs.firstWhere(
        (p) => p.id == programId,
        orElse: () => ProgramModel(
          id: programId, name: '', isActive: false, days: [],
        ),
      );

      int nextDayNumber = 1;
      if (existing.days.isNotEmpty) {
        nextDayNumber =
            existing.days.map((d) => d.dayNumber).reduce((a, b) => a > b ? a : b) + 1;
      }

      final response = await _apiClient.post(
        '/programs/$programId/days',
        data: {
          'day_number': nextDayNumber,
          'day_name': dayName,
        },
      );

      final newDay = ProgramDayModel.fromJson(response.data as Map<String, dynamic>);

      // Append the new day locally so the UI updates immediately
      _programs = _programs.map((p) {
        if (p.id != programId) return p;
        return ProgramModel(
          id: p.id,
          name: p.name,
          weeks: p.weeks,
          daysPerWeek: p.daysPerWeek,
          isActive: p.isActive,
          sourceTemplate: p.sourceTemplate,
          days: [...p.days, newDay],
        );
      }).toList();

      notifyListeners();
      return newDay;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
