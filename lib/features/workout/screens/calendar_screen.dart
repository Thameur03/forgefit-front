import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../providers/workout_provider.dart';
import '../models/workout_model.dart';
import 'workout_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _displayedMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WorkoutProvider>();
      if (provider.workouts.isEmpty) {
        provider.loadWorkouts();
      }
    });
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        child: Consumer<WorkoutProvider>(
          builder: (context, provider, _) {
            final workoutDates = provider.getWorkoutDates();
            final monthWorkouts =
                provider.getWorkoutsForMonth(_displayedMonth);
            final volume =
                provider.getTotalVolumeForMonth(_displayedMonth);

            return Column(
              children: [
                // Header with back + month navigation
                _buildHeader(),
                const SizedBox(height: 16),

                // Monthly stats
                _buildMonthStats(monthWorkouts.length, volume),
                const SizedBox(height: 20),

                // Calendar grid
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildCalendarGrid(workoutDates),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final monthLabel = DateFormat('MMMM yyyy').format(_displayedMonth);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Spacer(),
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Text(
            monthLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
          const Spacer(),
          const SizedBox(width: 48), // balance the back button
        ],
      ),
    );
  }

  Widget _buildMonthStats(int workoutCount, double volume) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OnboardingTheme.border),
        ),
        child: Row(
          children: [
            Expanded(child: _statCol('WORKOUTS', '$workoutCount')),
            Container(width: 1, height: 32, color: OnboardingTheme.border),
            Expanded(child: _statCol('KG VOL', _formatVolume(volume))),
            Container(width: 1, height: 32, color: OnboardingTheme.border),
            Expanded(child: _statCol('TOTAL TIME', '—')),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(100),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(Set<DateTime> workoutDates) {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Previous month fill
    final prevMonth = DateTime(year, month, 0); // last day of prev month
    final prevMonthDays = prevMonth.day;

    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        // Day labels
        Row(
          children: dayLabels
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          color: Colors.white.withAlpha(130),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),

        // Calendar rows
        ..._buildWeeks(
          daysInMonth: daysInMonth,
          startWeekday: startWeekday,
          prevMonthDays: prevMonthDays,
          year: year,
          month: month,
          todayDate: todayDate,
          workoutDates: workoutDates,
        ),
      ],
    );
  }

  List<Widget> _buildWeeks({
    required int daysInMonth,
    required int startWeekday,
    required int prevMonthDays,
    required int year,
    required int month,
    required DateTime todayDate,
    required Set<DateTime> workoutDates,
  }) {
    final weeks = <Widget>[];
    int dayCounter = 1;
    int nextMonthDay = 1;

    for (int week = 0; week < 6; week++) {
      if (dayCounter > daysInMonth && week > 0) break;

      final cells = <Widget>[];
      for (int d = 0; d < 7; d++) {
        final cellIndex = week * 7 + d;
        if (cellIndex < startWeekday) {
          // Previous month
          final prevDay = prevMonthDays - startWeekday + cellIndex + 1;
          cells.add(_calendarCell(
            day: prevDay,
            isCurrentMonth: false,
            isToday: false,
            isSelected: false,
            hasWorkout: false,
            onTap: null,
          ));
        } else if (dayCounter <= daysInMonth) {
          final currentDay = dayCounter;
          final date = DateTime(year, month, currentDay);
          final hasWorkout = workoutDates.contains(date);
          final isToday = date == todayDate;
          final isSelected = _selectedDay != null &&
              _selectedDay!.year == date.year &&
              _selectedDay!.month == date.month &&
              _selectedDay!.day == date.day;

          cells.add(_calendarCell(
            day: currentDay,
            isCurrentMonth: true,
            isToday: isToday,
            isSelected: isSelected,
            hasWorkout: hasWorkout,
            onTap: () => _onDayTapped(date, hasWorkout),
          ));
          dayCounter++;
        } else {
          // Next month
          cells.add(_calendarCell(
            day: nextMonthDay,
            isCurrentMonth: false,
            isToday: false,
            isSelected: false,
            hasWorkout: false,
            onTap: null,
          ));
          nextMonthDay++;
        }
      }

      weeks.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: cells),
      ));
    }

    return weeks;
  }

  Widget _calendarCell({
    required int day,
    required bool isCurrentMonth,
    required bool isToday,
    required bool isSelected,
    required bool hasWorkout,
    VoidCallback? onTap,
  }) {
    Color textColor;
    Color bgColor = Colors.transparent;
    Color? borderColor;

    if (!isCurrentMonth) {
      textColor = Colors.white.withAlpha(50);
    } else if (isSelected) {
      textColor = Colors.white;
      bgColor = OnboardingTheme.accent;
    } else if (isToday) {
      textColor = Colors.white;
      bgColor = OnboardingTheme.accent.withAlpha(40);
      borderColor = OnboardingTheme.accent;
    } else if (hasWorkout) {
      textColor = OnboardingTheme.accent;
    } else {
      textColor = Colors.white;
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 44,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: borderColor != null
                      ? Border.all(color: borderColor, width: 1.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: (isToday || isSelected || hasWorkout)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (hasWorkout && !isSelected)
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: const BoxDecoration(
                    color: OnboardingTheme.accent,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  void _onDayTapped(DateTime date, bool hasWorkout) {
    setState(() => _selectedDay = date);

    if (!hasWorkout) return;

    final provider = context.read<WorkoutProvider>();
    final dayWorkouts = provider.workouts.where((w) {
      return w.date.year == date.year &&
          w.date.month == date.month &&
          w.date.day == date.day;
    }).toList();

    if (dayWorkouts.isEmpty) return;

    // Sort by id descending to get latest
    dayWorkouts.sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id)));
    
    // Pass dayWorkouts to summary sheet to show count if multiple
    _showWorkoutSummarySheet(dayWorkouts, date);
  }

  void _showWorkoutSummarySheet(List<WorkoutModel> dayWorkouts, DateTime date) {
    if (dayWorkouts.isEmpty) return;
    
    final latestWorkout = dayWorkouts.first;
    
    double totalVol = 0;
    for (final ex in latestWorkout.exercises) {
      for (final s in ex.sets) {
        totalVol += s.weight * s.reps;
      }
    }

    // Use metadata from latestWorkout
    final durationStr = latestWorkout.durationSeconds > 0 
        ? '${latestWorkout.durationSeconds ~/ 60}' 
        : '—';
    final caloriesStr = latestWorkout.caloriesBurned > 0 
        ? '${latestWorkout.caloriesBurned}' 
        : '—';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: OnboardingTheme.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
            20, 12, 20,
            MediaQuery.of(context).padding.bottom + 32,
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
              const SizedBox(height: 20),

              // Title + completed badge
              Row(
                children: [
                  const Text(
                    'Workout Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: OnboardingTheme.success.withAlpha(80)),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        color: OnboardingTheme.success,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                dayWorkouts.length > 1
                  ? '${dayWorkouts.length} sessions today'
                  : DateFormat('EEEE, MMMM d').format(date),
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Workout card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OnboardingTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: OnboardingTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: OnboardingTheme.accent.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: OnboardingTheme.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (latestWorkout.name?.isNotEmpty == true)
                                ? latestWorkout.name!
                                : 'Workout Session',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '—',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _summaryStatCol(durationStr, 'MINUTES'),
                  ),
                  Expanded(
                    child: _summaryStatCol(
                      NumberFormat('#,##0').format(totalVol),
                      'KG LIFTED',
                    ),
                  ),
                  Expanded(
                    child: _summaryStatCol(caloriesStr, 'CALORIES'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // View Full Session button
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
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(
                            workoutId: latestWorkout.id,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'View Full Session',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryStatCol(String value, String label) {
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
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  String _formatVolume(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }
}
