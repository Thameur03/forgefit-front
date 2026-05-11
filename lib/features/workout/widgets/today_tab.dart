import '../utils/workout_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../models/program_model.dart';
import '../providers/workout_provider.dart';
import '../providers/program_provider.dart';
import '../providers/schedule_provider.dart';
import '../models/workout_model.dart';
import '../models/scheduled_workout_model.dart';
import '../screens/program_detail_screen.dart';
import '../screens/log_workout_screen.dart';
import '../screens/workout_detail_screen.dart';

class TodayTab extends StatefulWidget {
  final void Function(String) onShowComingSoon;
  final VoidCallback onSwitchToHistory;
  final VoidCallback onViewPrograms;

  const TodayTab({
    super.key,
    required this.onShowComingSoon,
    required this.onSwitchToHistory,
    required this.onViewPrograms,
  });

  @override
  State<TodayTab> createState() => TodayTabState();
}

class TodayTabState extends State<TodayTab> {
  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    print('=== WorkoutListScreen _TodayTabState initState called ===');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ignore: avoid_print
      print('=== Calling loadWorkouts() from _TodayTabState ===');
      context.read<WorkoutProvider>().loadWorkouts();
      context.read<ProgramProvider>().loadActiveProgram();
      context.read<ScheduleProvider>().loadToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkoutProvider, ScheduleProvider>(
      builder: (context, provider, scheduleProvider, _) {
        final scheduled = scheduleProvider.todayScheduled;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // In Progress Card
              if (provider.isWorkoutInProgress) ...[
                _buildInProgressCard(context, provider),
                const SizedBox(height: 24),
              ],

              // Today's Scheduled Workout card (if any)
              if (scheduled != null) ...[
                _buildScheduledCard(context, scheduled),
                const SizedBox(height: 24),
              ],

              // Quick Start
              _buildQuickStart(context),
              const SizedBox(height: 24),

              // Active Program
              _buildActiveProgramSection(context),
              const SizedBox(height: 24),

              // Recent Workouts
              _buildRecentWorkouts(provider),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduledCard(BuildContext context, ScheduledWorkoutModel sw) {
    final exerciseNames = sw.exercises.take(3).map((e) => e.exerciseName).toList();
    final remaining = sw.exercises.length - 3;
    final preview = exerciseNames.isEmpty
        ? 'No exercises'
        : remaining > 0
            ? '${exerciseNames.join(' · ')} +$remaining more'
            : exerciseNames.join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            OnboardingTheme.accent.withAlpha(40),
            OnboardingTheme.accent.withAlpha(15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.accent.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available_rounded,
                  color: OnboardingTheme.accent, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Today\'s Workout',
                style: TextStyle(
                  color: OnboardingTheme.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sw.dayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'From: ${sw.programName}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            preview,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LogWorkoutScreen(
                      programDay: sw.toProgramDayModel(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OnboardingTheme.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text(
                'Start Workout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _exerciseAcronym(String name) {
    const Map<String, String> known = {
      'bench press': 'BP',
      'barbell bench press': 'BP',
      'dumbbell bench press': 'DBP',
      'incline bench press': 'IBP',
      'overhead press': 'OHP',
      'barbell overhead press': 'OHP',
      'dumbbell overhead press': 'DOHP',
      'squat': 'SQ',
      'barbell squat': 'SQ',
      'back squat': 'SQ',
      'front squat': 'FSQ',
      'deadlift': 'DL',
      'romanian deadlift': 'RDL',
      'sumo deadlift': 'SDL',
      'pull up': 'PU',
      'pullup': 'PU',
      'chin up': 'CU',
      'barbell row': 'BR',
      'bent over row': 'BOR',
      'dumbbell row': 'DBR',
      'lat pulldown': 'LPD',
      'leg press': 'LP',
      'leg curl': 'LC',
      'leg extension': 'LE',
      'hip thrust': 'HT',
      'dumbbell curl': 'DC',
      'barbell curl': 'BC',
      'tricep pushdown': 'TPD',
      'tricep extension': 'TE',
      'lateral raise': 'LR',
      'dumbbell lateral raise': 'DLR',
      'cable lateral raise': 'CLR',
      'face pull': 'FP',
      'cable row': 'CR',
      'chest fly': 'CF',
      'dumbbell fly': 'DF',
      'cable fly': 'CAF',
      'military press': 'MP',
      'arnold press': 'AP',
      'hammer curl': 'HC',
      'skull crusher': 'SC',
      'calf raise': 'CR',
      'plank': 'PLK',
      'crunch': 'CRU',
      'sit up': 'SU',
    };

    final lower = name.toLowerCase().trim();
    if (known.containsKey(lower)) {
      return known[lower]!;
    }
    for (final entry in known.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    final words = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length == 1) {
      return words[0].substring(0, words[0].length.clamp(1, 3)).toUpperCase();
    }
    return words.take(3).map((w) => w[0].toUpperCase()).join();
  }

  Widget _buildInProgressCard(BuildContext context, WorkoutProvider provider) {
    final title = provider.activeWorkoutTitle;
    final elapsedSec = provider.elapsedSeconds;
    final m = (elapsedSec ~/ 60).toString().padLeft(2, '0');
    final s = (elapsedSec % 60).toString().padLeft(2, '0');
    final timeStr = '$m:$s';

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
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: OnboardingTheme.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'In Progress',
                style: TextStyle(
                  color: OnboardingTheme.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'ELAPSED',
                style: TextStyle(
                  color: Colors.white.withAlpha(100),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Active Session',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                timeStr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...() {
                final exercises = provider.activeExercises.map((e) => e.name).toList();
                if (exercises.isEmpty) return <Widget>[];
                final shown = exercises.take(2).toList();
                final remaining = exercises.length - 2;
                return [
                  ...shown.map((name) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _chip(_exerciseAcronym(name)),
                  )),
                  if (remaining > 0)
                    _chip('+$remaining'),
                ];
              }(),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LogWorkoutScreen(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: OnboardingTheme.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Resume',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: OnboardingTheme.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuickStart(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Start',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _quickStartCard(
                Icons.add,
                'Empty\nWorkout',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogWorkoutScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickStartCard(
                Icons.refresh,
                'Repeat\nLast',
                () async {
                  final provider = context.read<WorkoutProvider>();
                  
                  if (provider.workouts.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No previous workout found'),
                      ),
                    );
                    return;
                  }
                  
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(
                        color: OnboardingTheme.gradientStart,
                      ),
                    ),
                  );
                  
                  // Load FULL workout with sets
                  final lastId = provider.workouts.first.id;
                  await provider.loadWorkoutDetails(lastId);
                  
                  if (context.mounted) {
                    Navigator.pop(context); // dismiss loader
                  }
                  
                  final full = provider.currentWorkout;
                  if (full == null || full.sets.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Last workout had no exercises'),
                        ),
                      );
                    }
                    return;
                  }
                  
                  // Preload exercises from last workout
                  provider.preloadLastWorkout(full);
                  
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LogWorkoutScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickStartCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OnboardingTheme.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white60, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProgramSection(BuildContext context) {
    return Consumer<ProgramProvider>(
      builder: (context, programProvider, _) {
        // Load active program on first build
        if (programProvider.activeProgram == null && !programProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            programProvider.loadActiveProgram();
          });
        }

        final program = programProvider.activeProgram;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'This Week',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (program != null)
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProgramDetailScreen(programId: program.id),
                        ),
                      );
                      if (context.mounted) {
                        programProvider.loadActiveProgram();
                      }
                    },
                    child: const Text(
                      'View Program',
                      style: TextStyle(
                        color: OnboardingTheme.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Offline cache banner
            if (programProvider.isFromCache)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: OnboardingTheme.accent.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: OnboardingTheme.accent.withAlpha(60)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_off, color: OnboardingTheme.accent, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Showing cached data — you\'re offline',
                          style: TextStyle(
                            color: OnboardingTheme.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (programProvider.isLoading && program == null)
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: OnboardingTheme.card,
                  borderRadius: BorderRadius.circular(14),
                ),
              )
            else if (program == null)
              _buildNoProgramCard(context)
            else
              _buildProgramDaysList(context, program),
          ],
        );
      },
    );
  }

  Widget _buildNoProgramCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onViewPrograms(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: OnboardingTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: OnboardingTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: OnboardingTheme.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: OnboardingTheme.accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Let's add a program",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Choose a template or create your own training plan',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: OnboardingTheme.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'View Programs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramDaysList(BuildContext context, program) {
    return Column(
      children: [
        // Program name header chip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: OnboardingTheme.accent.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: OnboardingTheme.accent.withAlpha(60)),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: OnboardingTheme.accent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  program.name,
                  style: const TextStyle(
                    color: OnboardingTheme.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${program.days.length} days',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),

        // Day rows
        ...program.days.map<Widget>((day) => _buildProgramDayRow(context, day)),
      ],
    );
  }

  Widget _buildProgramDayRow(BuildContext context, day) {
    final exerciseNames = (day.exercises as List)
        .take(3)
        .map((e) => e.exerciseName as String)
        .toList();
    final remaining = (day.exercises as List).length - 3;
    final subtitle = exerciseNames.isEmpty
        ? 'No exercises'
        : remaining > 0
            ? '${exerciseNames.join(', ')} +$remaining more'
            : exerciseNames.join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProgramDetailScreen(
                  programId: context
                      .read<ProgramProvider>()
                      .activeProgram!
                      .id),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: OnboardingTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: OnboardingTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: OnboardingTheme.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.dayNumber}',
                  style: const TextStyle(
                    color: OnboardingTheme.accent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.dayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LogWorkoutScreen(
                        programDay: day as ProgramDayModel,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: OnboardingTheme.accent.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: OnboardingTheme.accent.withAlpha(60)),
                  ),
                  child: const Icon(Icons.play_arrow,
                      color: OnboardingTheme.accent, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentWorkouts(WorkoutProvider provider) {
    final recent = provider.workouts.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Workouts',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: widget.onSwitchToHistory,
              child: const Text(
                'View All',
                style: TextStyle(
                  color: OnboardingTheme.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.isLoading && recent.isEmpty)
          ...List.generate(3, (_) => _shimmerRow())
        else if (recent.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: OnboardingTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: OnboardingTheme.border),
            ),
            child: const Center(
              child: Text(
                'No workouts yet',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ),
          )
        else
          ...recent.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _recentRow(w),
              )),
      ],
    );
  }

  Widget _recentRow(WorkoutModel w) {
    final ago = _timeAgo(w.date);
    double totalVol = 0;
    for (final s in w.sets) {
      totalVol += s.weightKg * s.reps;
    }
    final volStr = totalVol > 0
        ? '${NumberFormat('#,##0').format(totalVol)} kg'
        : '—';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(workoutId: w.id),
          ),
        ).then((_) {
          // Refresh list on return
          if (mounted) {
            context.read<WorkoutProvider>().loadWorkouts();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OnboardingTheme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    WorkoutUtils.displayName(w),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$ago · ${w.totalSets} sets · ${WorkoutUtils.formatDuration(w.durationSeconds)} · $volStr',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  if (w.exercises.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      w.exercises.map((e) => e.name).take(3).join(' · ') + 
                        (w.exercises.length > 3 ? ' · +${w.exercises.length - 3} more' : ''),
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _shimmerRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 14) return '1 week ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }
}

