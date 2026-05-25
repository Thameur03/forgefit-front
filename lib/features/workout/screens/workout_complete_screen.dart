import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../providers/workout_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../home/screens/home_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/muscle_svg_viewer.dart';
import '../utils/muscle_utils.dart';
import '../services/pr_detector.dart';

class WorkoutCompleteScreen extends StatefulWidget {
  final String workoutId;
  final String workoutTitle;
  final int elapsedSeconds;
  final int completedSets;
  final double totalVolumeKg;
  final Map<String, int> muscleSetCounts;
  final List<BrokenPr> brokenPrs;

  const WorkoutCompleteScreen({
    super.key,
    required this.workoutId,
    required this.workoutTitle,
    required this.elapsedSeconds,
    required this.completedSets,
    required this.totalVolumeKg,
    required this.muscleSetCounts,
    required this.brokenPrs,
  });

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  late AnimationController _fadeStatsController;
  late Animation<double> _fadeStats;

  late AnimationController _fadePRsController;
  late Animation<double> _fadePRs;

  late AnimationController _fadeCardsController;
  late Animation<double> _fadeCards;

  late AnimationController _fadeMusclesController;
  late Animation<double> _fadeMuscles;

  late AnimationController _fadeButtonsController;
  late Animation<double> _fadeButtons;

  bool _isSaving = false;
  int _streakDays = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeStatsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadePRsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _fadeCardsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _fadeMusclesController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _fadeButtonsController.forward();
    });
  }

  void _setupAnimations() {
    _checkController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _checkScale = CurvedAnimation(
        parent: _checkController, curve: Curves.elasticOut);

    _fadeStatsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeStats = CurvedAnimation(
        parent: _fadeStatsController, curve: Curves.easeIn);

    _fadePRsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadePRs = CurvedAnimation(parent: _fadePRsController, curve: Curves.easeIn);

    _fadeCardsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeCards = CurvedAnimation(
        parent: _fadeCardsController, curve: Curves.easeIn);

    _fadeMusclesController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeMuscles = CurvedAnimation(
        parent: _fadeMusclesController, curve: Curves.easeIn);

    _fadeButtonsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeButtons = CurvedAnimation(
        parent: _fadeButtonsController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _checkController.dispose();
    _fadeStatsController.dispose();
    _fadePRsController.dispose();
    _fadeCardsController.dispose();
    _fadeMusclesController.dispose();
    _fadeButtonsController.dispose();
    super.dispose();
  }
  Future<void> _loadData() async {
    final apiClient = context.read<ApiClient>();
    try {
      final statsResponse = await apiClient.get(ApiConstants.statsWorkouts);
      if (statsResponse.data != null && mounted) {
        setState(() {
          _streakDays = statsResponse.data['current_streak_days'] ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveWorkout() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final apiClient = context.read<ApiClient>();
    final workoutProvider = context.read<WorkoutProvider>();

    try {
      if (widget.workoutId.isNotEmpty) {
        // ignore: avoid_print
        print('Saving workout id: ${widget.workoutId}');
        await apiClient.put(
          '${ApiConstants.workouts}${widget.workoutId}',
          data: {
            'name': widget.workoutTitle,
            'duration_seconds': widget.elapsedSeconds,
            'calories_burned': _caloriesBurned,
          },
        ).timeout(const Duration(seconds: 10));
      }
      
      if (mounted) {
        workoutProvider.clearActiveWorkout();
        await workoutProvider.loadWorkouts();
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Workout saved! 💪')),
        );
      }
    } on TimeoutException {
      if (mounted) {
        setState(() => _isSaving = false);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Save failed. Try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m < 60) {
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    final h = m ~/ 60;
    final rem = m % 60;
    return rem > 0 ? '${h}h ${rem}m' : '${h}h';
  }

  int get _caloriesBurned {
    final authProvider = context.read<AuthProvider>();
    final bodyWeight = authProvider.currentUser?.weightKg ?? 75.0;
    final durationMinutes = widget.elapsedSeconds ~/ 60;
    return ((3.5 * bodyWeight * durationMinutes) / 60).round();
  }

  String _formatVolume(double v) {
    return NumberFormat('#,##0').format(v);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a').format(now);

    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // SECTION 1: Header
              Column(
                children: [
                  ScaleTransition(
                    scale: _checkScale,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OnboardingTheme.success.withAlpha(25),
                        border: Border.all(
                            color: OnboardingTheme.success.withAlpha(80),
                            width: 2.5),
                      ),
                      child: const Icon(Icons.check,
                          color: OnboardingTheme.success, size: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Workout Complete!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.workoutTitle} · Today, $timeStr',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // SECTION 2: Summary stats
              FadeTransition(
                opacity: _fadeStats,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_fadeStats),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: OnboardingTheme.border),
                    ),
                    child: Row(
                      children: [
                        _statCol(
                            _formatVolume(widget.totalVolumeKg), 'kg', 'VOLUME'),
                        Container(
                            width: 1, height: 36, color: OnboardingTheme.border),
                        _statCol(
                            _formatDuration(widget.elapsedSeconds), '', 'DURATION'),
                        Container(
                            width: 1, height: 36, color: OnboardingTheme.border),
                        _statCol('${widget.completedSets}', 'total', 'SETS'),
                        Container(
                            width: 1, height: 36, color: OnboardingTheme.border),
                        _statCol(
                            _caloriesBurned > 0 ? '$_caloriesBurned' : '—',
                            'kcal',
                            'CALORIES'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 3: New PRs
              if (widget.brokenPrs.isNotEmpty)
                FadeTransition(
                  opacity: _fadePRs,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: OnboardingTheme.border),
                    ),
                    child: Row(
                      children: [
                        // Trophies
                        SizedBox(
                          width: 80,
                          height: 36,
                          child: Stack(
                            children: List.generate(
                              widget.brokenPrs.length > 3 ? 3 : widget.brokenPrs.length,
                              (index) => Positioned(
                                left: index * 20.0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: OnboardingTheme.accent.withAlpha(25),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: OnboardingTheme.card, width: 2),
                                  ),
                                  child: const Icon(Icons.emoji_events, color: OnboardingTheme.accent, size: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.brokenPrs.length} NEW PRs',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.brokenPrs.map((p) => p.exerciseName).join(', '),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white38),
                      ],
                    ),
                  ),
                ),

              // SECTION 4: Streak + Month
              FadeTransition(
                opacity: _fadeCards,
                child: Row(
                  children: [
                    Expanded(child: _buildStreakCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPRsCard()),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 5: Target Muscles
              FadeTransition(
                opacity: _fadeMuscles,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OnboardingTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: OnboardingTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white.withAlpha(10),
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.accessibility_new,
                                color: Colors.white.withAlpha(150), size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Target Muscles',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MuscleSvgViewer(muscleSetCounts: widget.muscleSetCounts),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.muscleSetCounts.keys.map((muscle) {
                          final count = widget.muscleSetCounts[muscle] ?? 0;
                          
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: OnboardingTheme.cardMid,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(muscleColor(count).replaceFirst('#', '0xFF'))),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  capitalizeMuscle(muscle),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // SECTION 6: Action Buttons
              FadeTransition(
                opacity: _fadeButtons,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [OnboardingTheme.gradientStart, OnboardingTheme.gradientEnd],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveWorkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Save Workout',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sharing coming soon'),
                              backgroundColor: OnboardingTheme.card,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.ios_share,
                            color: Colors.white60, size: 20),
                        label: const Text(
                          'Share Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: OnboardingTheme.border),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCol(String value, String unit, String label) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white.withAlpha(100),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(80),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    String streakVal = '$_streakDays-day';
    if (_streakDays >= 7) {
      streakVal = '${_streakDays ~/ 7}-week';
    } else if (_streakDays == 0) {
      streakVal = '0-day';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: OnboardingTheme.success, size: 16),
              const SizedBox(width: 6),
              Text(
                'STREAK',
                style: TextStyle(
                  color: Colors.white.withAlpha(130),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            streakVal,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Consistency is key!',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPRsCard() {
    final prCount = widget.brokenPrs.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECORDS',
                style: TextStyle(
                  color: Colors.white.withAlpha(130),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: prCount > 0
                      ? OnboardingTheme.accent.withAlpha(30)
                      : Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  prCount > 0 ? '+$prCount PRs' : 'No PRs',
                  style: TextStyle(
                    color: prCount > 0 ? OnboardingTheme.accent : Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$prCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  prCount == 1 ? 'Record Broken' : 'Records Broken',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
