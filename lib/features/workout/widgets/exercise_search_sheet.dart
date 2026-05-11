import 'dart:async';
import 'package:flutter/material.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../providers/workout_provider.dart';
import '../screens/exercise_detail_screen.dart';
import '../widgets/exercise_gif_widget.dart';

// ── Search Bottom Sheet (Debounced) ──────────────────────────────────────────

class ExerciseSearchSheet extends StatefulWidget {
  final WorkoutProvider provider;
  final VoidCallback onExerciseAdded;
  final Function(String, {String muscle}) onManualAdd;
  final int? replaceIndex;

  const ExerciseSearchSheet({
    super.key,
    required this.provider,
    required this.onExerciseAdded,
    required this.onManualAdd,
    this.replaceIndex,
  });

  @override
  State<ExerciseSearchSheet> createState() => ExerciseSearchSheetState();
}

class ExerciseSearchSheetState extends State<ExerciseSearchSheet> {
  final _searchController = TextEditingController();
  List<ExerciseResult> _results = [];
  bool _isSearching = false;
  String? _errorMessage;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _runSearch(String query) async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });
    try {
      final r = await widget.provider.searchExercises(query);
      if (mounted) {
        setState(() {
          _results = r;
          _isSearching = false;
          if (r.isEmpty && query.length >= 2) {
            // No results but not an error
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _isSearching = false;
          _errorMessage = 'Search failed. Check your connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: OnboardingTheme.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom),
      child: Column(
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
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Add Exercise',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Search field
          Container(
            decoration: BoxDecoration(
              color: OnboardingTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: OnboardingTheme.border),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search exercises...',
                hintStyle: TextStyle(color: Colors.white38),
                prefixIcon: Icon(Icons.search, color: Colors.white38, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) {
                  _debounce!.cancel();
                }
                _debounce = Timer(
                  const Duration(milliseconds: 500),
                  () {
                    if (value.length >= 2) {
                      _runSearch(value);
                    } else {
                      setState(() => _results = []);
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Results Count
          if (!_isSearching && _searchController.text.length >= 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${_results.length} exercises found',
                style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          // Results
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(
                      color: OnboardingTheme.accent,
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: OnboardingTheme.danger.withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: OnboardingTheme.danger.withAlpha(60)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.wifi_off, color: OnboardingTheme.danger, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(color: OnboardingTheme.danger, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    widget.onManualAdd(_searchController.text);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Add "${_searchController.text}" manually',
                                    style: const TextStyle(
                                      color: OnboardingTheme.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fitness_center,
                                    color: Colors.white.withAlpha(40), size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  _searchController.text.isEmpty
                                      ? 'Type to search exercises...'
                                      : 'No results for \'${_searchController.text}\'',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Manual add
                                if (_searchController.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      widget.onManualAdd(_searchController.text);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Add "${_searchController.text}" manually',
                                      style: const TextStyle(
                                        color: OnboardingTheme.accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final exercise = _results[i];

                          return InkWell(
                            key: ValueKey(exercise.id),
                            onTap: () {
                              if (widget.replaceIndex != null) {
                                widget.provider.replaceExercise(
                                  widget.replaceIndex!,
                                  exercise.name,
                                  muscle: exercise.targetMuscles.isNotEmpty
                                      ? exercise.targetMuscles.first
                                      : '—',
                                  gifUrl: exercise.gifUrl,
                                  exerciseResult: exercise,
                                );
                              } else {
                                widget.provider.addExercise(
                                  exercise.name,
                                  muscle: exercise.targetMuscles.isNotEmpty
                                      ? exercise.targetMuscles.first
                                      : '—',
                                  gifUrl: exercise.gifUrl,
                                  exerciseResult: exercise,
                                );
                              }
                              widget.onExerciseAdded();
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ExerciseDetailScreen(
                                            exercise: exercise,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ExerciseGifWidget(
                                      gifUrl: exercise.gifUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),  // close GestureDetector
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          exercise.targetMuscles
                                              .take(2)
                                              .join(' · '),
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12),
                                        ),
                                        if (exercise.equipment.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            exercise.equipment.first,
                                            style: const TextStyle(
                                                color: OnboardingTheme.accent,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.add_circle_outline,
                                    color: OnboardingTheme.accent,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
