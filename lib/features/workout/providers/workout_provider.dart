import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/workout_model.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACTIVE WORKOUT MODELS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ActiveSet {
  String? id;
  double weightKg;
  int reps;
  bool isCompleted;

  ActiveSet({this.id, this.weightKg = 0, this.reps = 0, this.isCompleted = false});
}

class ActiveExercise {
  String name;
  String targetMuscle;
  String gifUrl;
  List<ActiveSet> sets;
  bool isExpanded;
  ExerciseResult? exerciseResult;
  int restSeconds;
  bool hasPR;

  ActiveExercise({
    required this.name,
    this.targetMuscle = '—',
    this.gifUrl = '',
    List<ActiveSet>? sets,
    this.isExpanded = false,
    this.exerciseResult,
    this.restSeconds = 90,
    this.hasPR = false,
  }) : sets = sets ??
            [
              ActiveSet(weightKg: 0, reps: 8),
              ActiveSet(weightKg: 0, reps: 8),
              ActiveSet(weightKg: 0, reps: 8),
            ];
}

class ExerciseResult {
  final String id;
  final String name;
  final String gifUrl;
  final List<String> targetMuscles;
  final List<String> bodyParts;
  final List<String> equipment;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  ExerciseResult({
    required this.id,
    required this.name,
    required this.gifUrl,
    required this.targetMuscles,
    required this.bodyParts,
    required this.equipment,
    required this.secondaryMuscles,
    required this.instructions,
  });

  factory ExerciseResult.fromJson(Map<String, dynamic> json) {
    return ExerciseResult(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      gifUrl: json['gif_url'] ?? '',
      targetMuscles: List<String>.from(json['target_muscles'] ?? []),
      bodyParts: List<String>.from(json['body_parts'] ?? []),
      equipment: List<String>.from(json['equipment'] ?? []),
      secondaryMuscles: List<String>.from(json['secondary_muscles'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WORKOUT PROVIDER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class WorkoutProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<WorkoutModel> _workouts = [];
  WorkoutModel? _currentWorkout;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  // Active workout state
  bool _isWorkoutInProgress = false;
  String _activeWorkoutTitle = 'Workout';
  Duration _activeWorkoutElapsed = Duration.zero;
  String? _activeWorkoutId;
  Timer? _workoutTimer;

  // Active exercise state (survives navigation)
  final List<ActiveExercise> _activeExercises = [];

  // Notifications
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _notificationsInitialized = false;

  WorkoutProvider({required ApiClient apiClient}) : _apiClient = apiClient {
    _initNotifications();
  }

  List<WorkoutModel> get workouts => _workouts;
  WorkoutModel? get currentWorkout => _currentWorkout;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isWorkoutInProgress => _isWorkoutInProgress;
  String get activeWorkoutTitle => _activeWorkoutTitle;
  Duration get activeWorkoutElapsed => _activeWorkoutElapsed;
  String? get activeWorkoutId => _activeWorkoutId;
  int get elapsedSeconds => _activeWorkoutElapsed.inSeconds;

  List<ActiveExercise> get activeExercises => _activeExercises;

  int _prCount = 0;
  int get prCount => _prCount;

  bool _isRepeatingLastWorkout = false;
  bool get isRepeatingLastWorkout => _isRepeatingLastWorkout;

  void resetRepeatFlag() {
    _isRepeatingLastWorkout = false;
  }

  void checkAndUpdatePR(int exerciseIndex, String exerciseName, double weightKg, int reps) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExercises.length) return;
    
    // Find last workout with this exercise
    for (final workout in _workouts) {
      final matchingSets = workout.sets
          .where((s) => s.exerciseName.toLowerCase() == exerciseName.toLowerCase())
          .toList();
      if (matchingSets.isEmpty) continue;
      
      // Get max weight from last session
      final lastMaxWeight = matchingSets
          .map((s) => s.weightKg)
          .reduce((a, b) => a > b ? a : b);
      
      if (weightKg > lastMaxWeight) {
        if (!_activeExercises[exerciseIndex].hasPR) {
          _activeExercises[exerciseIndex].hasPR = true;
        }
        _prCount++;
        notifyListeners();
        return;
      }
      break; // Only check most recent
    }
  }

  int get completedExercises {
    return _activeExercises.where((e) =>
      e.sets.isNotEmpty &&
      e.sets.every((s) => s.isCompleted)
    ).length;
  }
  
  int get totalExercises => _activeExercises.length;

  int get totalCompletedSets {
    int count = 0;
    for (final ex in _activeExercises) {
      for (final s in ex.sets) {
        if (s.isCompleted) count++;
      }
    }
    return count;
  }

  int get totalSets {
    int count = 0;
    for (final ex in _activeExercises) {
      count += ex.sets.length;
    }
    return count;
  }

  double get totalVolumeKg {
    double vol = 0;
    for (final ex in _activeExercises) {
      for (final s in ex.sets) {
        if (s.isCompleted) vol += s.weightKg * s.reps;
      }
    }
    return vol;
  }

  double get progressPercent {
    if (totalSets == 0) return 0;
    return totalCompletedSets / totalSets;
  }

  // ── Notifications ──────────────────────────────────────────────────────────

  Future<void> _initNotifications() async {
    if (_notificationsInitialized) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
    _notificationsInitialized = true;
  }

  Future<void> fireRestComplete() async {
    // Vibration
    try {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500]);
      }
    } catch (_) {}

    // Local notification
    try {
      const androidDetails = AndroidNotificationDetails(
        'rest_timer',
        'Rest Timer',
        channelDescription: 'Notifies when rest timer completes',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);
      await _notificationsPlugin.show(
        0,
        'Rest Complete 💪',
        'Time to get back to it!',
        details,
      );
    } catch (_) {}
  }

  // ── Active exercise management ─────────────────────────────────────────────

  void addExercise(String name, {String muscle = '—', String gifUrl = '', ExerciseResult? exerciseResult}) {
    // Collapse all existing
    for (final ex in _activeExercises) {
      ex.isExpanded = false;
    }
    _activeExercises.add(ActiveExercise(
      name: name,
      targetMuscle: muscle,
      gifUrl: gifUrl,
      isExpanded: true,
      exerciseResult: exerciseResult,
    ));
    notifyListeners();
  }

  /// Call this after adding a batch of exercises (e.g. from a program day)
  /// to fetch their GIFs and muscle data asynchronously.
  void enrichExercisesInBackground() {
    final names = _activeExercises.map((e) => e.name).toList();
    if (names.isEmpty) return;
    _enrichExercisesWithGifs(names);
  }

  /// Public wrapper around [notifyListeners] for use by screen-level callers
  /// that need to trigger a single rebuild after manually mutating state.
  void broadcast() => notifyListeners();

  void addSet(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExercises.length) return;
    final exercise = _activeExercises[exerciseIndex];
    final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : ActiveSet();
    exercise.sets
        .add(ActiveSet(weightKg: lastSet.weightKg, reps: lastSet.reps));
    notifyListeners();
  }

  void removeSet(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExercises.length) return;
    final exercise = _activeExercises[exerciseIndex];
    if (exercise.sets.length <= 1) return;
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    exercise.sets.removeAt(setIndex);
    notifyListeners();
  }

  void removeExercise(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExercises.length) return;
    _activeExercises.removeAt(exerciseIndex);
    notifyListeners();
  }

  void replaceExercise(
      int exerciseIndex, 
      String newName,
      {String muscle = '—',
       String gifUrl = '',
       ExerciseResult? exerciseResult}) {
    if (exerciseIndex < 0 || 
        exerciseIndex >= 
        _activeExercises.length) {
      return;
    }
    
    // Create fresh empty sets (3 default)
    // DO NOT keep old sets
    final freshSets = [
      ActiveSet(weightKg: 0, reps: 8),
      ActiveSet(weightKg: 0, reps: 8),
      ActiveSet(weightKg: 0, reps: 8),
    ];

    _activeExercises[exerciseIndex] = ActiveExercise(
      name: newName,
      targetMuscle: muscle,
      gifUrl: gifUrl,
      exerciseResult: exerciseResult,
      sets: freshSets,
      isExpanded: true,
    );
    notifyListeners();
  }

  void toggleSetComplete(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExercises.length) return;
    final exercise = _activeExercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    final set = exercise.sets[setIndex];
    set.isCompleted = !set.isCompleted;

    if (set.isCompleted) {
      checkAndUpdatePR(exerciseIndex, exercise.name, set.weightKg, set.reps);
    }
    
    notifyListeners();
  }

  void updateSet(int exerciseIndex, int setIndex,
      {double? weight, int? reps}) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExercises.length) return;
    final exercise = _activeExercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    if (weight != null) exercise.sets[setIndex].weightKg = weight;
    if (reps != null) exercise.sets[setIndex].reps = reps;
    notifyListeners();
  }

  void toggleExerciseExpanded(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExercises.length) return;
    _activeExercises[exerciseIndex].isExpanded =
        !_activeExercises[exerciseIndex].isExpanded;
    notifyListeners();
  }

  void updateExerciseRestTime(int exerciseIndex, int seconds) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExercises.length) return;
    _activeExercises[exerciseIndex].restSeconds = seconds;
    notifyListeners();
  }

  void clearActiveWorkout() {
    _activeExercises.clear();
    _isWorkoutInProgress = false;
    _activeWorkoutId = null;
    _activeWorkoutElapsed = Duration.zero;
    _prCount = 0; // Reset PR count
    _stopTimer();
    notifyListeners();
  }

  void preloadLastWorkout(WorkoutModel lastWorkout) {
    _activeExercises.clear();
    _prCount = 0;

    final Map<String, List<WorkoutSetDetail>> grouped = {};
    final List<String> order = [];

    for (final s in lastWorkout.sets) {
      if (!grouped.containsKey(s.exerciseName)) {
        grouped[s.exerciseName] = [];
        order.add(s.exerciseName);
      }
      grouped[s.exerciseName]!.add(s);
    }

    for (int i = 0; i < order.length; i++) {
      final name = order[i];
      final sets = grouped[name]!;

      _activeExercises.add(ActiveExercise(
        name: name,
        targetMuscle: '—',
        gifUrl: '',
        sets: sets.map((s) => ActiveSet(
          weightKg: s.weightKg,
          reps: s.reps,
          isCompleted: false,
        )).toList(),
        isExpanded: i == 0,
        restSeconds: 90,
      ));
    }

    notifyListeners();

    // Fetch GIFs asynchronously — do not block UI
    _enrichExercisesWithGifs(order);
  }

  Future<void> _enrichExercisesWithGifs(List<String> exerciseNames) async {
    for (int i = 0; i < exerciseNames.length; i++) {
      final name = exerciseNames[i];
      try {
        final result = await findExercise(name);
        if (result != null) {
          final idx = _activeExercises.indexWhere(
            (e) => e.name.toLowerCase().trim() == name.toLowerCase().trim(),
          );
          if (idx != -1) {
            _activeExercises[idx].gifUrl = result.gifUrl;
            _activeExercises[idx].targetMuscle =
                result.targetMuscles.isNotEmpty ? result.targetMuscles.first : '—';
            _activeExercises[idx].exerciseResult = result;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              notifyListeners();
            });
          }
        }
      } catch (e, stack) {
        debugPrint('[ForgeFit] GIF enrichment failed: $e');
        debugPrint('[ForgeFit] Stack: $stack');
      }
    }
  }

  // ── Timer + workout state ─────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    Future.microtask(() => notifyListeners());
  }

  void _setError(String? message) {
    _errorMessage = message;
    Future.microtask(() => notifyListeners());
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setWorkoutInProgress(bool isInProgress,
      {String title = 'Workout',
      Duration elapsed = Duration.zero,
      String? workoutId}) {
    _isWorkoutInProgress = isInProgress;
    if (isInProgress) {
      _activeWorkoutTitle = title;
      _activeWorkoutElapsed = elapsed;
      _activeWorkoutId = workoutId;
      _startTimer();
    } else {
      _stopTimer();
      _activeWorkoutId = null;
      _activeWorkoutElapsed = Duration.zero;
    }
    notifyListeners();
  }

  void updateActiveWorkoutTitle(String title) {
    _activeWorkoutTitle = title;
    notifyListeners();
  }

  void _startTimer() {
    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _activeWorkoutElapsed += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopTimer() {
    _workoutTimer?.cancel();
    _workoutTimer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  // ── API calls ────────────────────────────────────────────────────────────

  Future<void> loadWorkouts() async {
    _isOffline = false; // reset before each attempt
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.get(ApiConstants.workouts);
      _workouts = (response.data as List)
          .map((e) => WorkoutModel.fromJson(e))
          .toList()
        ..sort((a, b) {
          final dateCompare = b.date.compareTo(a.date);
          if (dateCompare != 0) return dateCompare;
          return b.id.compareTo(a.id);
        });
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          // Real connectivity failure — show offline banner
          _isOffline = true;
        } else {
          // Auth error, server 4xx/5xx etc — NOT offline
          _isOffline = false;
          _setError(
            (e.response?.data as Map?)?['detail']?.toString() ??
                e.message ??
                'Failed to load workouts',
          );
        }
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadWorkoutDetails(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.get('${ApiConstants.workouts}$id');
      _currentWorkout = WorkoutModel.fromJson(response.data);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Loads detailed workout data (with sets) for PR baseline comparison.
  ///
  /// [GET /workouts/] only returns summaries — no `sets` field.
  /// This method fetches each workout individually to get full set details.
  /// Fetches up to [limit] previous workouts.
  Future<List<WorkoutModel>> loadDetailedWorkoutsForPrBaseline({
    int limit = 50,
  }) async {
    // Ensure summary list is loaded (uses cached if already loaded).
    if (_workouts.isEmpty) {
      await loadWorkouts();
    }

    final summaries = _workouts.take(limit).toList();
    debugPrint('[PR Baseline] fetching details for ${summaries.length} workouts');

    final detailed = <WorkoutModel>[];
    for (final summary in summaries) {
      try {
        final response =
            await _apiClient.get('${ApiConstants.workouts}${summary.id}');
        final detail = WorkoutModel.fromJson(
            response.data as Map<String, dynamic>);
        if (detail.sets.isNotEmpty) {
          detailed.add(detail);
        }
      } catch (_) {
        // Skip workouts that fail to load.
      }
    }

    debugPrint(
      '[PR Baseline] loaded ${detailed.length} workouts with sets '
      '(${detailed.fold(0, (s, w) => s + w.sets.length)} total sets)',
    );
    return detailed;
  }


  /// Creates a new empty workout and returns its server-assigned ID.
  Future<String?> createWorkout() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.workouts,
        data: {}, // Backend accepts empty body since it's a new empty workout
      );
      final id = response.data['id'] ?? response.data['_id'] ?? '';
      return id.toString();
    } catch (e) {
      _setError(e.toString());
      rethrow; // Rethrow to allow caller to handle the auth error
    }
  }

  /// Logs a completed set to the backend for a specific workout.
  Future<String?> logSet({
    required String workoutId,
    required String exerciseName,
    required int reps,
    required double weightKg,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.workouts}$workoutId/sets',
        data: {
          'exercise_name': exerciseName,
          'sets': 1,
          'reps': reps,
          'weight_kg': weightKg,
        },
      );
      return response.data['id']?.toString();
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveWorkout(WorkoutModel workout) async {
    _setLoading(true);
    _setError(null);
    try {
      if (workout.id.isEmpty) {
        // Create new
        await _apiClient.post(
          ApiConstants.workouts,
          data: workout.toJson(),
        );
      } else {
        // Update existing
        await _apiClient.put(
          '${ApiConstants.workouts}${workout.id}',
          data: {
            'name': workout.name,
            'notes': workout.name,
            'duration_seconds': workout.durationSeconds,
          },
        );
      }
      await loadWorkouts(); // Refresh list
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteWorkout(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.delete('${ApiConstants.workouts}$id');
      _workouts.removeWhere((w) => w.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a specific set by ID
  Future<bool> deleteSet(String workoutId, String setId) async {
    try {
      await _apiClient.delete(
        '${ApiConstants.workouts}$workoutId/sets/$setId',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  List<WorkoutModel> getWorkoutsForMonth(DateTime month) {
    return _workouts.where((w) {
      return w.date.year == month.year && w.date.month == month.month;
    }).toList();
  }

  Set<DateTime> getWorkoutDates() {
    return _workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet();
  }

  double getTotalVolumeForMonth(DateTime month) {
    final monthWorkouts = getWorkoutsForMonth(month);
    double total = 0;
    for (final w in monthWorkouts) {
      total += w.totalVolumeKg;
    }
    return total;
  }

  Future<List<ExerciseResult>> searchExercises(String query) async {
    if (query.isEmpty) return [];
    try {
      final response = await _apiClient.get(
        ApiConstants.exerciseSearch,
        queryParameters: {'q': query},
      );
      final list = response.data as List;
      final results = list
          .map((e) => ExerciseResult.fromJson(e as Map<String, dynamic>))
          .toList();
      // Cache results
      for (final r in results) {
        _exerciseCache[r.name.toLowerCase().trim()] = r;
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  // ── Exercise Cache ──────────────────────────────────────────────────────────
  final Map<String, ExerciseResult> _exerciseCache = {};

  Future<ExerciseResult?> findExercise(String name) async {
    final key = name.toLowerCase().trim();
    if (_exerciseCache.containsKey(key)) {
      return _exerciseCache[key];
    }
    final results = await searchExercises(key);
    if (results.isNotEmpty) {
      _exerciseCache[key] = results.first;
      return results.first;
    }
    return null;
  }
}
