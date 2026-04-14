import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_gif_widget.dart';
import 'workout_complete_screen.dart';
import 'exercise_detail_screen.dart';
import '../../home/screens/home_screen.dart';
import '../widgets/exercise_search_sheet.dart';
import '../models/program_model.dart';
import '../utils/muscle_utils.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOG WORKOUT SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class LogWorkoutScreen extends StatefulWidget {
  final ProgramDayModel? programDay;

  const LogWorkoutScreen({super.key, this.programDay});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen>
    with TickerProviderStateMixin {
  // Workout state
  String? _workoutId;
  bool _isCreating = true;
  final _titleController = TextEditingController(text: 'My Workout');
  bool _isEditingTitle = false;
  String? _createError;

  // Controllers for set inputs to prevent rebuild keyboard lag
  final Map<String, TextEditingController> _controllers = {};

  // Scroll controller for keyboard visibility
  final ScrollController _scrollController = ScrollController();

  TextEditingController _ctrl(String key, String initialValue) {
    return _controllers.putIfAbsent(
      key, 
      () => TextEditingController(text: initialValue)
    );
  }

  // Rest timer
  int _restTimerSeconds = 0;
  bool _isRestTimerActive = false;
  bool _isRestTimerPaused = false;
  Timer? _restTimer;
  late AnimationController _restPulseController;

  // Progress animation
  late AnimationController _progressController;

  // Provider shortcuts
  WorkoutProvider get _provider => context.read<WorkoutProvider>();

  @override
  void initState() {
    super.initState();
    _restPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0,
    );
    _createWorkout();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _titleController.dispose();
    _scrollController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _restPulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _createWorkout() async {
    final provider = context.read<WorkoutProvider>();
    
    if (provider.isRepeatingLastWorkout) {
      // Skip creating new empty workout logically clearing local items
      final newId = await provider.createWorkout();
      provider.setWorkoutInProgress(
        true,
        title: 'My Workout',
        workoutId: newId,
      );
      provider.resetRepeatFlag();
      
      if (mounted) {
        setState(() {
          _workoutId = newId;
          _isCreating = false;
        });
      }
      return;
    }

    if (_provider.isWorkoutInProgress) {
      if (mounted) {
        setState(() {
          _isCreating = false;
          _workoutId = _provider.activeWorkoutId;
          _titleController.text = _provider.activeWorkoutTitle;
        });
      }
      return;
    }

    // ignore: avoid_print
    print('Creating workout...');
    setState(() {
      _isCreating = true;
      _createError = null;
    });

    try {
      final id = await _provider.createWorkout();
      // ignore: avoid_print
      print('Response: OK, ID: $id');
      
      if (id == null || id.isEmpty) {
        throw Exception('Received empty ID');
      }

      if (mounted) {
        setState(() {
          _workoutId = id;
          _isCreating = false;
        });
        _provider.setWorkoutInProgress(
          true,
          title: _titleController.text,
          workoutId: id,
        );

        // Pre-populate exercises from program day if provided
        final day = widget.programDay;
        if (day != null && day.exercises.isNotEmpty) {
          final title = day.dayName;
          _titleController.text = title;
          _provider.setWorkoutInProgress(true, title: title, workoutId: id);

          for (final ex in day.exercises) {
            _provider.addExercise(ex.exerciseName);
            // Pre-fill sets based on the program's target
            final addedIndex = _provider.activeExercises.length - 1;
            for (int i = 1; i < ex.sets; i++) {
              _provider.addSet(addedIndex);
            }
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
      if (mounted) {
        if (e.toString().contains('401')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please login again')),
          );
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        } else {
          setState(() {
            _createError = 'Failed to start workout. Please check your connection.';
          });
        }
      }
    }
  }

  // ── Stats (from provider) ──────────────────────────────────────────────────

  int get _completedSets => _provider.totalCompletedSets;
  double get _totalVolume => _provider.totalVolumeKg;
  double get _progressPercent => _provider.progressPercent;

  String _formatTime(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatRestTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '$m:00';
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  // ── Set completion ─────────────────────────────────────────────────────────

  void _completeSet(int exIndex, int setIndex) async {
    final exercises = _provider.activeExercises;
    if (exIndex < 0 || exIndex >= exercises.length) return;
    final exercise = exercises[exIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    final set = exercise.sets[setIndex];

    if (set.isCompleted) return;

    final wasAllComplete = _provider.completedExercises == _provider.totalExercises && _provider.totalExercises > 0;

    _provider.toggleSetComplete(exIndex, setIndex);

    final isAllComplete = _provider.completedExercises == _provider.totalExercises && _provider.totalExercises > 0;
    
    if (!wasAllComplete && isAllComplete) {
      HapticFeedback.heavyImpact();
    }

    // Update progress bar
    _progressController.animateTo(_progressPercent);

    // Log to backend
    if (_workoutId != null) {
      final setId = await _provider.logSet(
            workoutId: _workoutId!,
            exerciseName: exercise.name,
            reps: set.reps,
            weightKg: set.weightKg,
          );
      if (setId != null) {
        set.id = setId;
      }
    }

    // Start rest timer
    _startRestTimer(exercise.restSeconds);
  }

  void _uncompleteSet(int exIndex, int setIndex) async {
    if (!mounted) return;
    
    final exercises = _provider.activeExercises;
    if (exIndex < 0 || exIndex >= exercises.length) return;
    final exercise = exercises[exIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    final set = exercise.sets[setIndex];

    if (!set.isCompleted) return;

    _provider.toggleSetComplete(exIndex, setIndex);

    // Update progress bar
    _progressController.animateTo(_progressPercent);

    // Remove from backend
    if (_workoutId != null && set.id != null) {
      await _provider.deleteSet(_workoutId!, set.id!);
      set.id = null;
    }
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restTimerSeconds = seconds;
      _isRestTimerActive = true;
      _isRestTimerPaused = false;
    });
    _restPulseController.repeat(reverse: true);

    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRestTimerPaused && mounted) {
        setState(() {
          _restTimerSeconds--;
          if (_restTimerSeconds <= 0) {
            _provider.fireRestComplete();
            _dismissRestTimer();
          }
        });
      }
    });
  }

  void _dismissRestTimer() {
    _restTimer?.cancel();
    _restPulseController.stop();
    _restPulseController.reset();
    if (mounted) {
      setState(() {
        _isRestTimerActive = false;
        _isRestTimerPaused = false;
      });
    }
  }

  // ── Exercise management ────────────────────────────────────────────────────

  void _showExerciseSearch({int? replaceIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExerciseSearchSheet(
        provider: _provider,
        onExerciseAdded: () {
          _progressController.animateTo(_progressPercent);
        },
        onManualAdd: (name, {String muscle = '—'}) {
          if (replaceIndex != null) {
            _provider.replaceExercise(replaceIndex, name, muscle: muscle);
          } else {
            _addExerciseByName(name, muscle: muscle);
          }
        },
        replaceIndex: replaceIndex,
      ),
    );
  }

  void _addExerciseByName(String name, {String muscle = '—'}) {
    // Duplicate guard — case-insensitive
    final exists = _provider.activeExercises.any(
      (e) => e.name.trim().toLowerCase() == name.trim().toLowerCase(),
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$name" is already in this workout'),
          backgroundColor: OnboardingTheme.card,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _provider.addExercise(name, muscle: muscle);
    _progressController.animateTo(_progressPercent);
  }

  // ── End workout ────────────────────────────────────────────────────────────

  void _showEndDialog() {
    // Count sets with no weight AND no reps (truly unlogged)
    int unloggedCount = 0;
    for (final ex in _provider.activeExercises) {
      for (final s in ex.sets) {
        if (!s.isCompleted && s.weightKg == 0 && s.reps == 0) {
          unloggedCount++;
        }
      }
    }

    if (unloggedCount > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: OnboardingTheme.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('End Workout?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            '$unloggedCount ${unloggedCount == 1 ? 'set' : 'sets'} not logged. Are you sure you want to finish?',
            style: const TextStyle(color: Colors.white60),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Going',
                  style: TextStyle(color: OnboardingTheme.accent, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _finishWorkout();
              },
              child: const Text('Finish Anyway',
                  style: TextStyle(color: OnboardingTheme.danger, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() {
    _restTimer?.cancel();

    final provider = _provider;

    // Check if any sets were actually completed
    final hasCompletedSets = provider.activeExercises
        .any((e) => e.sets.any((s) => s.isCompleted));

    if (!hasCompletedSets) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: OnboardingTheme.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('No sets logged',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text("You haven't logged any sets yet. End this workout?",
              style: TextStyle(color: Colors.white60)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                provider.clearActiveWorkout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('End Workout',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    final elapsedSecs = provider.elapsedSeconds;

    // Aggregate set counts per muscle group using centralised helper.
    // Includes both primary (targetMuscles) and secondary muscles.
    final muscleSetCounts = buildMuscleSetCounts(provider.activeExercises);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutCompleteScreen(
          workoutId: _workoutId ?? '',
          workoutTitle: _provider.activeWorkoutTitle,
          totalVolumeKg: _totalVolume,
          elapsedSeconds: elapsedSecs,
          completedSets: _completedSets,
          muscleSetCounts: muscleSetCounts,
        ),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Listen to provider changes for timer + exercise state
    return Consumer<WorkoutProvider>(
      builder: (context, provider, _) {
        final exercises = provider.activeExercises;
        final elapsedSeconds = provider.elapsedSeconds;

        if (_isCreating || _createError != null) {
          return Scaffold(
            backgroundColor: OnboardingTheme.bg,
            body: Center(
              child: _createError != null 
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.orange, size: 48),
                      const SizedBox(height: 16),
                      Text(_createError!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _createWorkout,
                        style: ElevatedButton.styleFrom(backgroundColor: OnboardingTheme.accent),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: OnboardingTheme.accent),
                      SizedBox(height: 16),
                      Text('Starting workout...',
                          style: TextStyle(color: Colors.white60)),
                    ],
                  ),
            ),
          );
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: OnboardingTheme.bg,
          body: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              child: Column(
                children: [
                  const Offstage(
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                    ),
                  ),
                  // Top bar
                _buildTopBar(elapsedSeconds),
                // Stats row
                _buildStatsRow(elapsedSeconds),
                const SizedBox(height: 8),
                // Progress bar
                _buildProgressBar(),
                const SizedBox(height: 4),
                // Exercise list
                Expanded(
                  child: exercises.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.only(
                            bottom: 120,
                            left: 20,
                            right: 20,
                            top: 8,
                          ),
                          itemCount: exercises.length + 1,
                          itemBuilder: (context, index) {
                            if (index == exercises.length) {
                              return _buildAddExerciseButton();
                            }
                            return _buildExerciseCard(index);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
          // Rest timer overlay
          bottomSheet: _isRestTimerActive ? _buildRestTimer() : null,
        );
      },
    );
  }

  Widget _buildTopBar(int elapsedSeconds) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          // Chevron down (minimize)
          IconButton(
            onPressed: _showEndDialog,
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 4),
          // Title
          Expanded(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isEditingTitle = true),
                  child: _isEditingTitle
                      ? SizedBox(
                          height: 32,
                          child: TextField(
                            controller: _titleController,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (_) {
                              setState(() => _isEditingTitle = false);
                              _provider.updateActiveWorkoutTitle(
                                  _titleController.text);
                            },
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                _titleController.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.edit,
                                color: Colors.white38, size: 14),
                          ],
                        ),
                ),
                // Live timer
                Text(
                  _formatTime(elapsedSeconds),
                  style: const TextStyle(
                    color: OnboardingTheme.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Finish button
          GestureDetector(
            onTap: _finishWorkout,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: OnboardingTheme.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Finish',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int elapsedSeconds) {
    final volumeStr = _totalVolume >= 1000
        ? '${NumberFormat('#,##0').format(_totalVolume)} KG'
        : '${_totalVolume.toStringAsFixed(0)} KG';
    final completedExercises = _provider.completedExercises;
    final totalExercises = _provider.totalExercises;
    final isAllDone = completedExercises == totalExercises && totalExercises > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _statItem('SETS', '$_completedSets'),
          _divider(),
          _statItem('VOLUME', volumeStr),
          _divider(),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$completedExercises/$totalExercises',
                  style: TextStyle(
                    color: isAllDone ? OnboardingTheme.success : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'EXERCISES',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 16,
      color: OnboardingTheme.border,
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${(_progressPercent * 100).toInt()}% Complete',
                style: TextStyle(
                  color: Colors.white.withAlpha(130),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _progressController,
            builder: (_, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: _progressController.value,
                  backgroundColor: OnboardingTheme.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      OnboardingTheme.accent),
                  minHeight: 4,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center,
              color: Colors.white.withAlpha(40), size: 56),
          const SizedBox(height: 16),
          const Text(
            'Add an exercise to start',
            style: TextStyle(color: Colors.white38, fontSize: 15),
          ),
          const SizedBox(height: 20),
          _buildAddExerciseButton(),
        ],
      ),
    );
  }

  Widget _buildAddExerciseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: _showExerciseSearch,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: OnboardingTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: OnboardingTheme.border),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: OnboardingTheme.accent, size: 20),
              SizedBox(width: 8),
              Text(
                'Add Exercise',
                style: TextStyle(
                  color: OnboardingTheme.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Exercise Card ──────────────────────────────────────────────────────────

  Widget _buildExerciseCard(int exIndex) {
    final exercise = _provider.activeExercises[exIndex];
    final completedInEx = exercise.sets.where((s) => s.isCompleted).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        children: [
          // Header — always visible
          GestureDetector(
            onTap: () => _provider.toggleExerciseExpanded(exIndex),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Number badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: OnboardingTheme.accent.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${exIndex + 1}',
                      style: const TextStyle(
                        color: OnboardingTheme.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (exercise.gifUrl.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(
                              exercise: exercise.exerciseResult,
                              fallbackName: exercise.name,
                            ),
                          ),
                        );
                      },
                      child: ExerciseGifWidget(
                        gifUrl: exercise.gifUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                exercise.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (exercise.hasPR) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: OnboardingTheme.gradientStart.withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: OnboardingTheme.gradientStart.withAlpha(100)),
                                ),
                                child: const Text(
                                  'PR',
                                  style: TextStyle(
                                    color: OnboardingTheme.gradientStart,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Target: ${exercise.targetMuscle} · ${exercise.sets.length} sets',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (!exercise.isExpanded && completedInEx > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: OnboardingTheme.accent.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$completedInEx/${exercise.sets.length}',
                        style: const TextStyle(
                          color: OnboardingTheme.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showRestTimeOptions(context, exIndex, exercise),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white60, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _formatRestTime(exercise.restSeconds),
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: exercise.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _showExerciseOptions(context, exIndex, exercise),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(exIndex, exercise),
            crossFadeState: exercise.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(int exIndex, ActiveExercise exercise) {
    // Find the first non-completed set (active set)
    int activeSetIndex = -1;
    for (int i = 0; i < exercise.sets.length; i++) {
      if (!exercise.sets[i].isCompleted) {
        activeSetIndex = i;
        break;
      }
    }

    return Column(
      children: [
        // Column headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const SizedBox(
                  width: 40,
                  child: Text('SET',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                      textAlign: TextAlign.center)),
              const Expanded(
                  child: Text('KG',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                      textAlign: TextAlign.center)),
              const Expanded(
                  child: Text('REPS',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                      textAlign: TextAlign.center)),
              const SizedBox(
                  width: 44,
                  child: Icon(Icons.check, color: Colors.white24, size: 16)),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Set rows
        ...exercise.sets.asMap().entries.map((entry) {
          final setIdx = entry.key;
          final set = entry.value;
          final bool isActive = setIdx == activeSetIndex;
          return _buildSetRow(exIndex, setIdx, set, isActive);
        }),

        // Quick adjust buttons (for active set)
        if (activeSetIndex >= 0)
          _buildQuickAdjust(exIndex, activeSetIndex, exercise),

        // Add Set button
        GestureDetector(
          onTap: () {
            _provider.addSet(exIndex);
            _progressController.animateTo(_progressPercent);
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: OnboardingTheme.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: OnboardingTheme.border),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white38, size: 16),
                SizedBox(width: 6),
                Text(
                  'ADD SET',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetRow(
      int exIndex, int setIndex, ActiveSet set, bool isActive) {
    if (set.isCompleted) {
      // Completed row
      return GestureDetector(
        onTap: () => _uncompleteSet(exIndex, setIndex),
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
          children: [
            SizedBox(
              width: 40,
              child: GestureDetector(
                onTap: () => _showSetOptions(context, exIndex, setIndex),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: OnboardingTheme.cardMid,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${setIndex + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                set.weightKg.toStringAsFixed(set.weightKg == set.weightKg.roundToDouble() ? 0 : 1),
                style: const TextStyle(color: Colors.white38, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                '${set.reps}',
                style: const TextStyle(color: Colors.white38, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 44,
              child: Icon(
                Icons.check_circle,
                color: OnboardingTheme.accent,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

    // Active / editable row
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: isActive
          ? BoxDecoration(
              color: OnboardingTheme.accent.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: OnboardingTheme.accent.withAlpha(50)),
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: GestureDetector(
              onTap: () => _showSetOptions(context, exIndex, setIndex),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive ? OnboardingTheme.gradientStart : OnboardingTheme.cardMid,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${setIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _inputField(
              controller: _ctrl("ex${exIndex}_set${setIndex}_kg", set.weightKg == 0 ? '' : set.weightKg.toStringAsFixed(set.weightKg == set.weightKg.roundToDouble() ? 0 : 1)),
              onChanged: (v) => _provider.updateSet(exIndex, setIndex, weight: v),
              isActive: isActive,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _inputFieldInt(
              controller: _ctrl("ex${exIndex}_set${setIndex}_reps", set.reps == 0 ? '' : set.reps.toString()),
              onChanged: (v) => _provider.updateSet(exIndex, setIndex, reps: v),
              isActive: isActive,
            ),
          ),
          SizedBox(
            width: 44,
            child: GestureDetector(
              onTap: () => _completeSet(exIndex, setIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: isActive
                        ? OnboardingTheme.accent
                        : OnboardingTheme.border,
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.check,
                    color: Colors.white38, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required Function(double) onChanged,
    required bool isActive,
  }) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color:
            isActive ? OnboardingTheme.bg : OnboardingTheme.bg.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        autofocus: false,
        enableInteractiveSelection: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white60,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          hintText: '—',
          hintStyle: TextStyle(color: Colors.white24),
        ),
        onTap: _scrollToBottom,
        onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
      ),
    );
  }

  Widget _inputFieldInt({
    required TextEditingController controller,
    required Function(int) onChanged,
    required bool isActive,
  }) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color:
            isActive ? OnboardingTheme.bg : OnboardingTheme.bg.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        autofocus: false,
        enableInteractiveSelection: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white60,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          hintText: '—',
          hintStyle: TextStyle(color: Colors.white24),
        ),
        onTap: _scrollToBottom,
        onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
      ),
    );
  }

  Widget _buildQuickAdjust(
      int exIndex, int activeSetIndex, ActiveExercise exercise) {
    final activeSet = exercise.sets[activeSetIndex];

    String? matchLastLabel;
    for (int i = activeSetIndex - 1; i >= 0; i--) {
      if (exercise.sets[i].isCompleted) {
        final ls = exercise.sets[i];
        matchLastLabel =
            '${ls.weightKg.toStringAsFixed(ls.weightKg == ls.weightKg.roundToDouble() ? 0 : 1)}×${ls.reps}';
        break;
      }
    }

    void syncControllers() {
      final kgKey = 'ex${exIndex}_set${activeSetIndex}_kg';
      final repsKey = 'ex${exIndex}_set${activeSetIndex}_reps';
      final updatedSet = _provider.activeExercises[exIndex].sets[activeSetIndex];
      if (_controllers.containsKey(kgKey)) {
        _controllers[kgKey]!.text = updatedSet.weightKg == 0
            ? ''
            : updatedSet.weightKg.toStringAsFixed(
                updatedSet.weightKg == updatedSet.weightKg.roundToDouble() ? 0 : 1);
      }
      if (_controllers.containsKey(repsKey)) {
        _controllers[repsKey]!.text =
            updatedSet.reps == 0 ? '' : updatedSet.reps.toString();
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _quickChip('+1 rep', () {
            _provider.updateSet(exIndex, activeSetIndex,
                reps: activeSet.reps + 1);
            syncControllers();
          }),
          _quickChip('+1 kg', () {
            _provider.updateSet(exIndex, activeSetIndex,
                weight: activeSet.weightKg + 1);
            syncControllers();
          }),
          _quickChip('+2.5 kg', () {
            _provider.updateSet(exIndex, activeSetIndex,
                weight: activeSet.weightKg + 2.5);
            syncControllers();
          }),
          if (matchLastLabel != null)
            _quickChip('Match Last ($matchLastLabel)', () {
              final parts = matchLastLabel!.split('×');
              if (parts.length == 2) {
                _provider.updateSet(exIndex, activeSetIndex,
                    weight: double.tryParse(parts[0]) ?? activeSet.weightKg,
                    reps: int.tryParse(parts[1]) ?? activeSet.reps);
                syncControllers();
              }
            }, isAccent: true),
        ],
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap,
      {bool isAccent = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isAccent ? Colors.transparent : OnboardingTheme.border,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isAccent ? OnboardingTheme.accent : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Rest Timer ─────────────────────────────────────────────────────────────

  Widget _buildRestTimer() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          border: Border(top: BorderSide(color: OnboardingTheme.border)),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            children: [
            // Pulsing icon
            AnimatedBuilder(
              animation: _restPulseController,
              builder: (_, child) {
                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: OnboardingTheme.accent
                        .withAlpha((40 + _restPulseController.value * 40).toInt()),
                  ),
                  child: const Icon(Icons.timer,
                      color: OnboardingTheme.accent, size: 20),
                );
              },
            ),
            const SizedBox(width: 10),
            // Label + timer
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'REST TIMER',
                  style: TextStyle(
                    color: Colors.white.withAlpha(100),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  _formatRestTime(_restTimerSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const Spacer(),
            // -30s
            GestureDetector(
              onTap: () {
                setState(() {
                  _restTimerSeconds = (_restTimerSeconds - 30).clamp(5, 600);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '-30s',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // +30s
            _restButton('+30s', () {
              setState(() => _restTimerSeconds = (_restTimerSeconds + 30).clamp(5, 600));
            }),
            const SizedBox(width: 2),
            Container(width: 1, height: 20, color: OnboardingTheme.border),
            const SizedBox(width: 2),
            // Skip
            _restButton('Skip', _dismissRestTimer),
          ],
        ),
      ),
      ),
    );
  }

  Widget _restButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showSetOptions(BuildContext context, int exerciseIndex, int setIndex) {
    final exercise = _provider.activeExercises[exerciseIndex];
    final bool canDelete = exercise.sets.length > 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: OnboardingTheme.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Set ${setIndex + 1} Options',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (canDelete)
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _provider.removeSet(exerciseIndex, setIndex);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withAlpha(80)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Delete Set',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.block, color: Colors.white38, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Can\'t delete last set',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showExerciseOptions(
      BuildContext context, int exerciseIndex, ActiveExercise exercise) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: OnboardingTheme.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              exercise.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showExerciseSearch(replaceIndex: exerciseIndex);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OnboardingTheme.gradientStart.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: OnboardingTheme.gradientStart.withAlpha(80)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.swap_horiz, color: OnboardingTheme.gradientStart, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Replace Exercise',
                      style: TextStyle(
                        color: OnboardingTheme.gradientStart,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: OnboardingTheme.cardDark,
                    title: const Text('Remove Exercise?',
                        style: TextStyle(color: Colors.white)),
                    content: Text(
                        'Remove ${exercise.name} and all its sets?',
                        style: const TextStyle(color: Colors.white60)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.white60)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _provider.removeExercise(exerciseIndex);
                        },
                        child: const Text('Remove',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withAlpha(80)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Remove Exercise',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestTimeOptions(BuildContext context, int exerciseIndex, ActiveExercise exercise) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setBottomSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: OnboardingTheme.cardDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rest Time',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Time between sets',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final sec in [30, 60, 90, 120, 180])
                      GestureDetector(
                        onTap: () {
                          _provider.updateExerciseRestTime(exerciseIndex, sec);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: exercise.restSeconds == sec 
                                ? OnboardingTheme.gradientStart 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: exercise.restSeconds == sec 
                                  ? OnboardingTheme.gradientStart 
                                  : Colors.white60,
                            ),
                          ),
                          child: Text(
                            sec == 30 ? '30s' : _formatRestTime(sec),
                            style: TextStyle(
                              color: exercise.restSeconds == sec 
                                  ? Colors.white 
                                  : Colors.white60,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}

