import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../providers/workout_provider.dart';
import '../models/workout_model.dart';
import '../screens/workout_detail_screen.dart';
import '../utils/workout_utils.dart';

class HistoryTab extends StatefulWidget {
  final void Function(String) onShowComingSoon;

  const HistoryTab({super.key, required this.onShowComingSoon});

  @override
  State<HistoryTab> createState() => HistoryTabState();
}

class HistoryTabState extends State<HistoryTab> {
  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    print('=== WorkoutListScreen _HistoryTabState initState called ===');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ignore: avoid_print
      print('=== Calling loadWorkouts() from _HistoryTabState ===');
      context.read<WorkoutProvider>().loadWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.workouts.isEmpty) {
          return _buildShimmer();
        }

        if (provider.errorMessage != null && provider.workouts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off,
                      color: Colors.white.withAlpha(60), size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to load workout history',
                    style: TextStyle(color: Colors.white60, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadWorkouts(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OnboardingTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.workouts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center,
                      color: Colors.white.withAlpha(40), size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'No workouts yet.\nStart your first workout!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        }

        // Monthly summary
        final now = DateTime.now();
        final thisMonthWorkouts = provider.getWorkoutsForMonth(now);
        final volume = provider.getTotalVolumeForMonth(now);

        // Group by date
        final grouped = <String, List<WorkoutModel>>{};
        for (final w in provider.workouts) {
          final key = DateFormat('MMM dd').format(w.date).toUpperCase();
          grouped.putIfAbsent(key, () => []).add(w);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly summary card
              MonthSummaryCard(
                workoutCount: thisMonthWorkouts.length,
                volume: volume,
                onTap: () => widget.onShowComingSoon('Monthly stats'),
              ),
              const SizedBox(height: 20),

              // Grouped workout list
              ...grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...entry.value.map((w) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _historyCard(w),
                        )),
                    const SizedBox(height: 8),
                  ],
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _historyCard(WorkoutModel w) {
    // ignore: avoid_print  
    print('=== card ${w.id} showing calories: ${w.caloriesBurned} ===');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(workoutId: w.id),
          ),
        ).then((_) {
          // Re-fetch workouts list when coming back
          if (mounted) {
            context.read<WorkoutProvider>().loadWorkouts();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OnboardingTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    WorkoutUtils.displayName(w),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              WorkoutUtils.muscleGroups(w).isNotEmpty ? WorkoutUtils.muscleGroups(w) : '—',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white38, size: 14),
                const SizedBox(width: 4),
                Text(WorkoutUtils.formatDuration(w.durationSeconds),
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.local_fire_department, color: Colors.white38, size: 14),
                const SizedBox(width: 4),
                Text(w.caloriesBurned > 0 ? '${w.caloriesBurned} kcal' : '— kcal',
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const Spacer(),
                if (w.totalVolumeKg > 1000)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.accent.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: OnboardingTheme.accent.withAlpha(60)),
                    ),
                    child: const Text(
                      'PR',
                      style: TextStyle(
                        color: OnboardingTheme.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: OnboardingTheme.card,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: OnboardingTheme.card,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MONTH SUMMARY CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class MonthSummaryCard extends StatelessWidget {
  final int workoutCount;
  final double volume;
  final VoidCallback onTap;

  const MonthSummaryCard({
    super.key,
    required this.workoutCount,
    required this.volume,
    required this.onTap,
  });

  String _formatVolume(double v) {
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}k';
    }
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OnboardingTheme.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'THIS MONTH',
                  style: TextStyle(
                    color: Colors.white.withAlpha(130),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: Colors.white24, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statCol('Workouts', '$workoutCount'),
                ),
                Expanded(
                  child: _statCol('Total Time', '—'),
                ),
                Expanded(
                  child: _statCol('Volume', _formatVolume(volume)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCol(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(100),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
