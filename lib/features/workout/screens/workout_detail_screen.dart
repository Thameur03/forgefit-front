import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/widgets/onboarding_widgets.dart'; // For Theme colors
import '../providers/workout_provider.dart';
import '../models/workout_model.dart';
import 'edit_session_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  bool _isLoading = true;
  WorkoutModel? _workout;

  // Grouped by exercise Name
  final Map<String, List<WorkoutSetDetail>> _groupedSets = {};

  @override
  void initState() {
    super.initState();
    _loadWorkoutDetail();
  }

  Future<void> _loadWorkoutDetail() async {
    setState(() => _isLoading = true);
    final provider = context.read<WorkoutProvider>();
    
    await provider.loadWorkoutDetails(widget.workoutId);
    _workout = provider.currentWorkout;
    
    // Group sets
    _groupedSets.clear();
    if (_workout != null) {
      for (var s in _workout!.sets) {
        if (!_groupedSets.containsKey(s.exerciseName)) {
          _groupedSets[s.exerciseName] = [];
        }
        _groupedSets[s.exerciseName]!.add(s);
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: OnboardingTheme.bg,
        body: Center(child: CircularProgressIndicator(color: OnboardingTheme.accent)),
      );
    }
    
    if (_workout == null) {
      return Scaffold(
        backgroundColor: OnboardingTheme.bg,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text("Workout not found", style: TextStyle(color: Colors.white))),
      );
    }

    // Build list of keys
    final exerciseNames = _groupedSets.keys.toList();

    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    
                    ...List.generate(exerciseNames.length, (index) {
                      final exName = exerciseNames[index];
                      final exSets = _groupedSets[exName]!;
                      return _AnimatedExerciseCard(
                        delayMs: index * 80,
                        exerciseName: exName,
                        sets: exSets,
                      );
                    }),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  String _buildSubtitle(WorkoutModel w) {
    final parts = <String>[];
    parts.add('${_monthName(w.date.month)} ${w.date.day}');
    if (w.durationSeconds > 0) {
      final m = w.durationSeconds ~/ 60;
      parts.add('$m min');
    }
    if (w.caloriesBurned > 0) {
      parts.add('${w.caloriesBurned} kcal');
    }
    return parts.join(' · ');
  }

  Widget _buildHeader() {
    final title = _workout?.name ?? 'My Workout';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditSessionScreen(
                    workoutId: widget.workoutId,
                    workoutName: title,
                  ),
                ),
              ).then((_) => _loadWorkoutDetail()),
              child: const Icon(
                Icons.edit,
                color: Colors.white38,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _buildSubtitle(_workout!),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '—';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m < 60) {
      return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
    }
    final h = m ~/ 60;
    final rem = m % 60;
    return rem > 0 ? '${h}h ${rem}m' : '${h}h';
  }

  Widget _buildSummaryCard() {
    // Calculate PR occurrences in this workout
    int prCount = 0;
    _groupedSets.forEach((exName, sets) {
      if (sets.isEmpty) return;
      double maxWeight = 0;
      double maxLastWeight = -1; // -1 means no last session
      for (var s in sets) {
        if (s.weightKg > maxWeight) maxWeight = s.weightKg;
        if (s.lastSession != null) {
          final lw = (s.lastSession!['weight_kg'] ?? 0).toDouble();
          if (lw > maxLastWeight) maxLastWeight = lw;
        }
      }
      if (maxWeight > 0) {
        if (maxLastWeight < 0 || maxWeight > maxLastWeight) {
          prCount++;
        }
      }
    });

    final durStr = _formatDuration(_workout!.durationSeconds);
    final vol = _workout!.totalVolumeKg;
    final volStr = vol >= 1000 ? '${(vol / 1000).toStringAsFixed(1)}k' : vol.toStringAsFixed(0);
    final kcalStr = _workout!.caloriesBurned > 0 ? '${_workout!.caloriesBurned}' : '—';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SESSION SUMMARY',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem('DURATION', durStr, ''),
              _divider(),
              _statItem('VOLUME', volStr, vol >= 1000 ? '' : 'kg'),
              _divider(),
              _statItem('CALORIES', kcalStr, kcalStr == '—' ? '' : 'kcal'),
              _divider(),
              _statItem('PRS', '$prCount', '', prCount > 0 ? OnboardingTheme.accent : Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, String unit, [Color? valColor]) {
    valColor ??= Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                color: valColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white12,
    );
  }

  String _monthName(int m) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (m >= 1 && m <= 12) return names[m - 1];
    return '';
  }
}

class _AnimatedExerciseCard extends StatefulWidget {
  final int delayMs;
  final String exerciseName;
  final List<WorkoutSetDetail> sets;

  const _AnimatedExerciseCard({
    required this.delayMs,
    required this.exerciseName,
    required this.sets,
  });

  @override
  State<_AnimatedExerciseCard> createState() => _AnimatedExerciseCardState();
}

class _AnimatedExerciseCardState extends State<_AnimatedExerciseCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    double exVol = 0;
    double maxWeight = 0;
    int maxReps = 0;
    for (var s in widget.sets) {
      exVol += (s.weightKg * s.reps);
      if (s.weightKg > maxWeight) {
        maxWeight = s.weightKg;
        maxReps = s.reps;
      }
    }

    final oneRM = (maxWeight * (1 + maxReps / 30)).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exerciseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '—', // Muscle group not available
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Volume',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${exVol.toStringAsFixed(0)} kg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const SizedBox(width: 30, child: Text('SET', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(child: Center(child: Text('KG', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('REPS', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)))),
                const SizedBox(width: 30), // Alignment for PR badge
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...widget.sets.asMap().entries.map((entry) {
            final idx = entry.key;
            final s = entry.value;
            final isHighestWeight = s.weightKg == maxWeight && maxWeight > 0;
            // Only badge the LAST occurrence of the highest weight to match behavior
            final isLastHighest = isHighestWeight && widget.sets.lastIndexWhere((x) => x.weightKg == maxWeight) == idx;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${idx + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        s.weightKg.toStringAsFixed(s.weightKg.truncateToDouble() == s.weightKg ? 0 : 1),
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${s.reps}',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    child: isLastHighest ? _ScalePopBadge() : null,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rest time: —',
                  style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 12),
                ),
                Text(
                  '1RM: $oneRM kg',
                  style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScalePopBadge extends StatefulWidget {
  @override
  State<_ScalePopBadge> createState() => _ScalePopBadgeState();
}

class _ScalePopBadgeState extends State<_ScalePopBadge> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scale = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: OnboardingTheme.accent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          'PR',
          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
