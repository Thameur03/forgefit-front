import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../models/program_model.dart';
import '../models/scheduled_workout_model.dart';
import '../providers/program_provider.dart';
import '../providers/schedule_provider.dart';

class ScheduleWorkoutSheet extends StatefulWidget {
  final DateTime selectedDate;
  final ScheduledWorkoutModel? existingScheduled;

  const ScheduleWorkoutSheet({
    super.key,
    required this.selectedDate,
    this.existingScheduled,
  });

  @override
  State<ScheduleWorkoutSheet> createState() => _ScheduleWorkoutSheetState();
}

class _ScheduleWorkoutSheetState extends State<ScheduleWorkoutSheet> {
  bool _isScheduling = false;
  bool _isUnscheduling = false;

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == todayDate) return 'Today, ${DateFormat('MMM d').format(date)}';
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  String _exercisePreview(List<ProgramExerciseModel> exercises) {
    if (exercises.isEmpty) return 'No exercise preview available';
    final names = exercises.take(2).map((e) => e.exerciseName).toList();
    final remaining = exercises.length - 2;
    if (remaining > 0) {
      return '${names.join(', ')} +$remaining more';
    }
    return names.join(', ');
  }

  Future<void> _confirmUnschedule(ScheduledWorkoutModel scheduled) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OnboardingTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Unschedule workout?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Remove "${scheduled.dayName}" from ${_formatDate(widget.selectedDate)}?',
          style: const TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Unschedule',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isUnscheduling = true);
    final scheduleProvider = context.read<ScheduleProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final success = await scheduleProvider.deleteScheduled(scheduled.id);

    if (!mounted) return;
    setState(() => _isUnscheduling = false);

    if (success) {
      navigator.pop(); // close bottom sheet
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Workout unscheduled'),
          backgroundColor: OnboardingTheme.card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Could not unschedule workout: ${scheduleProvider.error ?? 'Unknown error'}',
          ),
          backgroundColor: OnboardingTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _doSchedule(
    BuildContext context,
    ProgramDayModel day,
    ScheduleProvider scheduleProvider,
    bool hasExisting,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (hasExisting) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: OnboardingTheme.card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Replace scheduled workout?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This date already has a scheduled workout. Replace it with "${day.dayName}"?',
            style: const TextStyle(color: Colors.white60),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white60)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Replace',
                  style: TextStyle(color: OnboardingTheme.accent)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _isScheduling = true);
    final result = await scheduleProvider.scheduleWorkout(
      date: widget.selectedDate,
      programDayId: day.id,
    );
    if (!mounted) return;
    setState(() => _isScheduling = false);

    if (result != null) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              '${day.dayName} scheduled for ${_formatDate(widget.selectedDate)}'),
          backgroundColor: OnboardingTheme.card,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              'Could not schedule workout: ${scheduleProvider.error ?? 'Unknown error'}'),
          backgroundColor: OnboardingTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildCurrentScheduledCard(
      BuildContext context, ScheduledWorkoutModel existing) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar icon badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.event_available_rounded,
              color: Colors.blueAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Scheduled Workout',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  existing.dayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  existing.programName,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 1),
                Text(
                  _formatDate(widget.selectedDate),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  _exercisePreview(existing.exercises),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Unschedule X button
          if (_isUnscheduling)
            const SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => _confirmUnschedule(existing),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withAlpha(25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.redAccent.withAlpha(80)),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final existing = widget.existingScheduled;

    return Consumer2<ProgramProvider, ScheduleProvider>(
      builder: (context, programProvider, scheduleProvider, _) {
        final program = programProvider.activeProgram;
        final hasExisting = existing != null ||
            scheduleProvider.hasScheduledOn(widget.selectedDate);

        return SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: OnboardingTheme.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.fromLTRB(
              20, 12, 20,
              (bottomInset > 0 ? bottomInset : 16) + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
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

                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Schedule Workout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: OnboardingTheme.card,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white60, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Selected date subtitle
                Text(
                  _formatDate(widget.selectedDate),
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
                const SizedBox(height: 20),

                if (_isScheduling)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                          color: OnboardingTheme.accent),
                    ),
                  )
                else if (program == null) ...[
                  // No active program empty state
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: OnboardingTheme.border),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            color: Colors.white.withAlpha(50), size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'No active program',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Activate a program first to schedule workouts.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // ── Case B: date has a scheduled workout ──────────────────
                  if (existing != null) ...[
                    _buildCurrentScheduledCard(context, existing),
                    const SizedBox(height: 12),
                    // Warning: selecting another day will replace
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.orange.withAlpha(80)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.orange, size: 15),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This date already has a scheduled workout. Selecting one will replace it.',
                                style: TextStyle(
                                    color: Colors.orange, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // ── Case A: no scheduled workout — show active program chip ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: OnboardingTheme.accent.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: OnboardingTheme.accent.withAlpha(60)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt,
                              color: OnboardingTheme.accent, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            program.name,
                            style: const TextStyle(
                              color: OnboardingTheme.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Program day cards (always shown)
                  ...program.days.map((day) {
                    final exerciseNames = day.exercises
                        .take(3)
                        .map((e) => e.exerciseName)
                        .toList();
                    final remaining = day.exercises.length - 3;
                    final subtitle = exerciseNames.isEmpty
                        ? 'No exercises yet'
                        : remaining > 0
                            ? '${exerciseNames.join(', ')} +$remaining more'
                            : exerciseNames.join(', ');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => _doSchedule(
                            context, day, scheduleProvider, hasExisting),
                        child: Container(
                          padding: const EdgeInsets.all(14),
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
                                        fontWeight: FontWeight.w600,
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
                              const Icon(Icons.chevron_right_rounded,
                                  color: Colors.white38),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
