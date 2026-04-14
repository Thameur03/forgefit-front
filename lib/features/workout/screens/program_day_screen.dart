import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../models/program_model.dart';
import '../providers/program_provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_gif_widget.dart';

class ProgramDayScreen extends StatefulWidget {
  final ProgramDayModel day;
  final int programId;

  const ProgramDayScreen({
    super.key,
    required this.day,
    required this.programId,
  });

  @override
  State<ProgramDayScreen> createState() => _ProgramDayScreenState();
}

class _ProgramDayScreenState extends State<ProgramDayScreen> {
  late List<ProgramExerciseModel> _exercises;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.day.exercises);
  }

  // ── Add Exercise via API Search ────────────────────────────────────────────

  Future<void> _showAddExerciseSheet() async {
    final searchController = TextEditingController();
    List<ExerciseResult> results = [];
    bool isSearching = false;
    String? errorMessage;
    Timer? debounce;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            void runSearch(String query) async {
              debounce?.cancel();
              if (query.length < 2) {
                setSheetState(() { results = []; errorMessage = null; });
                return;
              }
              debounce = Timer(const Duration(milliseconds: 400), () async {
                setSheetState(() { isSearching = true; errorMessage = null; });
                try {
                  final r = await context.read<WorkoutProvider>().searchExercises(query);
                  if (ctx.mounted) {
                    setSheetState(() { results = r; isSearching = false; });
                  }
                } catch (_) {
                  if (ctx.mounted) {
                    setSheetState(() {
                      results = [];
                      isSearching = false;
                      errorMessage = 'Could not load exercises. Try again.';
                    });
                  }
                }
              });
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(ctx).size.height * 0.75,
                decoration: const BoxDecoration(
                  color: OnboardingTheme.bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Add Exercise',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: OnboardingTheme.card,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.close, color: Colors.white60, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Search field
                    Container(
                      decoration: BoxDecoration(
                        color: OnboardingTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: OnboardingTheme.border),
                      ),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Search exercises...',
                          hintStyle: TextStyle(color: Colors.white38),
                          prefixIcon: Icon(Icons.search, color: Colors.white38, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: runSearch,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Results area
                    Expanded(
                      child: isSearching
                          ? const Center(child: CircularProgressIndicator(color: OnboardingTheme.accent))
                          : errorMessage != null
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.wifi_off, color: OnboardingTheme.danger, size: 36),
                                      const SizedBox(height: 10),
                                      Text(errorMessage!,
                                          style: const TextStyle(color: OnboardingTheme.danger, fontSize: 13)),
                                    ],
                                  ),
                                )
                              : results.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.fitness_center,
                                              color: Colors.white.withAlpha(40), size: 48),
                                          const SizedBox(height: 12),
                                          Text(
                                            searchController.text.isEmpty
                                                ? 'Type to search exercises...'
                                                : 'No exercises found',
                                            style: const TextStyle(color: Colors.white38),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: results.length,
                                      itemBuilder: (_, i) {
                                        final ex = results[i];
                                        return InkWell(
                                          onTap: () async {
                                            Navigator.pop(ctx);
                                            // Check for duplicate
                                            final alreadyExists = _exercises.any(
                                              (e) => e.exerciseName.trim().toLowerCase() ==
                                                  ex.name.trim().toLowerCase(),
                                            );
                                            if (alreadyExists && mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('"${ex.name}" is already in this day'),
                                                  backgroundColor: OnboardingTheme.card,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                              return;
                                            }
                                            final added = await context
                                                .read<ProgramProvider>()
                                                .addExerciseToDay(
                                                  widget.day.id,
                                                  exerciseName: ex.name,
                                                  sets: 3,
                                                  reps: 8,
                                                );
                                            if (added != null && mounted) {
                                              setState(() {
                                                _exercises.add(added);
                                                _hasChanges = true;
                                              });
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: Row(
                                              children: [
                                                ExerciseGifWidget(
                                                    gifUrl: ex.gifUrl,
                                                    width: 56,
                                                    height: 56,
                                                    fit: BoxFit.cover,
                                                  ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(ex.name,
                                                          style: const TextStyle(
                                                              color: Colors.white, fontWeight: FontWeight.bold)),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        ex.targetMuscles.take(2).join(' · '),
                                                        style: const TextStyle(
                                                            color: Colors.white60, fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Icon(Icons.add_circle_outline,
                                                    color: OnboardingTheme.accent),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    debounce?.cancel();
  }

  // ── Remove Exercise ────────────────────────────────────────────────────────

  Future<void> _removeExercise(ProgramExerciseModel ex) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: OnboardingTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Exercise?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Remove "${ex.exerciseName}" from this day?',
            style: const TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: OnboardingTheme.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await context
        .read<ProgramProvider>()
        .removeExerciseFromDay(widget.day.id, ex.id);

    if (success && mounted) {
      setState(() {
        _exercises.removeWhere((e) => e.id == ex.id);
        _hasChanges = true;
      });
    }
  }

  // ── Save Day ───────────────────────────────────────────────────────────────

  Future<void> _saveDay() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      // The exercises are already persisted individually via addExerciseToDay /
      // removeExerciseFromDay. The "Save Day" button is a user-facing confirmation step
      // and signals success when all changes have been properly staged.
      await Future.delayed(const Duration(milliseconds: 300)); // short feedback delay
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Day saved successfully'),
            backgroundColor: OnboardingTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save. Try again.'),
            backgroundColor: OnboardingTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      appBar: AppBar(
        backgroundColor: OnboardingTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context, _hasChanges),
        ),
        title: Text(
          widget.day.dayName,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: OnboardingTheme.accent),
            onPressed: _showAddExerciseSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center, color: Colors.white.withAlpha(40), size: 48),
                        const SizedBox(height: 16),
                        const Text('No exercises yet',
                            style: TextStyle(color: Colors.white60, fontSize: 15)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _showAddExerciseSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: OnboardingTheme.accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Add Exercise',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final ex = _exercises[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: OnboardingTheme.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: OnboardingTheme.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: OnboardingTheme.accent.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                    color: OnboardingTheme.accent, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ex.exerciseName,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 3),
                                  Text('${ex.sets} sets × ${ex.reps} reps',
                                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _removeExercise(ex),
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: OnboardingTheme.danger.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.remove, color: OnboardingTheme.danger, size: 16),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // ── Save Day Button ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveDay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OnboardingTheme.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Day',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
