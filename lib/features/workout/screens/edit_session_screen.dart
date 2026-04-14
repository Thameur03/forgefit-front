import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../providers/workout_provider.dart';
import '../models/workout_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../widgets/exercise_gif_widget.dart';

class _MutableSet {
  String? originalId;
  int reps;
  double kg;
  bool isDirty;

  _MutableSet({this.originalId, required this.reps, required this.kg, this.isDirty = false});
}

class _MutableExercise {
  String name;
  List<_MutableSet> sets;

  _MutableExercise({required this.name, required this.sets});
}

class EditSessionScreen extends StatefulWidget {
  final String workoutId;
  final String workoutName;

  const EditSessionScreen({super.key, required this.workoutId, required this.workoutName});

  @override
  State<EditSessionScreen> createState() => _EditSessionScreenState();
}

class _EditSessionScreenState extends State<EditSessionScreen> {
  late TextEditingController _nameCtrl;
  DateTime _date = DateTime.now();
  List<_MutableExercise> _exercises = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.workoutName);
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<WorkoutProvider>();
    
    // Attempt to parse out date/time from the current workout if it exists
    List<WorkoutSetDetail> sets = [];
    if (provider.currentWorkout != null && provider.currentWorkout!.id == widget.workoutId) {
      _date = provider.currentWorkout!.date;
      sets = provider.currentWorkout!.sets;
    }
    
    // Group into mutable exercises
    final Map<String, List<_MutableSet>> grouped = {};
    for (var s in sets) {
      if (!grouped.containsKey(s.exerciseName)) {
        grouped[s.exerciseName] = [];
      }
      grouped[s.exerciseName]!.add(_MutableSet(
        originalId: s.id,
        reps: s.reps,
        kg: s.weightKg,
        isDirty: false,
      ));
    }
    
    _exercises = grouped.entries.map((e) => _MutableExercise(name: e.key, sets: e.value)).toList();
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    
    try {
      final apiClient = context.read<ApiClient>();
      final wp = context.read<WorkoutProvider>();
      
      // 1. PUT /workouts/{id} with notes
      final originalDate = wp.currentWorkout?.date;
      final dateChanged = originalDate != null && 
        (_date.year != originalDate.year || 
         _date.month != originalDate.month || 
         _date.day != originalDate.day);
         
      final body = {
        'name': _nameCtrl.text.trim(),
        'notes': _nameCtrl.text.trim(),
      };
      
      if (dateChanged) {
        body['date'] = _date.toIso8601String().split('T')[0];
      }

      await apiClient.put('${ApiConstants.workouts}${widget.workoutId}', data: body);
      
      // 2. For each modified/added set: POST
      // We will identify new sets or dirty sets.
      for (var ex in _exercises) {
        for (var s in ex.sets) {
          if (s.originalId == null || s.isDirty) {
            // Optional: delete old set if modifying an existing one, though instruction 
            // strictly says "For each modified/added set: POST /workouts/{id}/sets". 
            // We'll delete original if dirty so we don't duplicate.
            if (s.originalId != null && s.isDirty) {
              await wp.deleteSet(widget.workoutId, s.originalId!);
            }
            
            await wp.logSet(
              workoutId: widget.workoutId,
              exerciseName: ex.name,
              reps: s.reps,
              weightKg: s.kg,
            );
          }
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session saved!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
        setState(() => _isSaving = false);
      }
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
                  children: [
                    const SizedBox(height: 16),
                    _buildNameCard(),
                    const SizedBox(height: 24),
                    ..._exercises.asMap().entries.map((e) => _buildExerciseCard(e.key)),
                    const SizedBox(height: 24),
                    _buildAddExerciseBtn(),
                    const SizedBox(height: 48),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const Text(
            'Edit Session',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (_isSaving)
            const Padding(padding: EdgeInsets.only(right: 16), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: OnboardingTheme.accent)))
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save', style: TextStyle(color: OnboardingTheme.accent, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildNameCard() {
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
            'WORKOUT NAME',
            style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text('DATE', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     GestureDetector(
                       onTap: () async {
                         final res = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                         if (res != null) setState(() => _date = res);
                       },
                       child: Text(DateFormat('MMM dd, yyyy').format(_date), style: const TextStyle(color: Colors.white, fontSize: 16)),
                     ),
                     const SizedBox(height: 8),
                     const Divider(color: Colors.white12, height: 1),
                   ],
                 ),
               ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int exIdx) {
    final ex = _exercises[exIdx];
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ex.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Colors.white60),
                  color: OnboardingTheme.card,
                  onSelected: (val) async {
                    if (val == 'delete') {
                      final exerciseToDelete = _exercises[exIdx];
                      setState(() {
                        _exercises.removeAt(exIdx);
                      });
                      
                      final provider = context.read<WorkoutProvider>();
                      for (var s in exerciseToDelete.sets) {
                        if (s.originalId != null && s.originalId!.isNotEmpty) {
                          await provider.deleteSet(widget.workoutId, s.originalId!);
                        }
                      }
                    }
                  },
                  itemBuilder: (_) => [
                     const PopupMenuItem(value: 'delete', child: Text('Delete Exercise', style: TextStyle(color: Colors.redAccent))),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const SizedBox(width: 30, child: Text('SET', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(child: Center(child: Text('KG', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('REPS', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)))),
                const SizedBox(width: 30),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...ex.sets.asMap().entries.map((entry) {
            final sIdx = entry.key;
            final s = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Container(
                      width: 24, height: 24,
                      decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('${sIdx + 1}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCellField(
                      initial: s.kg.toStringAsFixed(s.kg.truncateToDouble() == s.kg ? 0 : 1),
                      onChanged: (val) {
                        s.kg = double.tryParse(val) ?? 0;
                        s.isDirty = true;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCellField(
                      initial: s.reps.toString(),
                      onChanged: (val) {
                        s.reps = int.tryParse(val) ?? 0;
                        s.isDirty = true;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      if (s.originalId != null && s.originalId!.isNotEmpty) {
                        final provider = context.read<WorkoutProvider>();
                        
                        // Optimistic removal
                        setState(() {
                          ex.sets.removeAt(sIdx);
                        });
                        
                        bool ok = await provider.deleteSet(widget.workoutId, s.originalId!);
                        if (!ok && mounted) {
                          // Restore on failure
                          setState(() {
                            ex.sets.insert(sIdx, s);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to delete set'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        setState(() {
                          ex.sets.removeAt(sIdx);
                        });
                      }
                    },
                    child: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                  )
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              setState(() {
                final lastSet = ex.sets.isNotEmpty ? ex.sets.last : null;
                ex.sets.add(_MutableSet(
                  reps: lastSet?.reps ?? 0,
                  kg: lastSet?.kg ?? 0,
                  isDirty: true,
                ));
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              alignment: Alignment.center,
              child: const Text(
                '+ ADD SET',
                style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCellField({required String initial, required Function(String) onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: OnboardingTheme.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        initialValue: initial,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAddExerciseBtn() {
    return InkWell(
      onTap: () async {
        final result = await _showExerciseSearch();
        if (result != null && result.isNotEmpty) {
          setState(() {
            _exercises.add(_MutableExercise(name: result, sets: [_MutableSet(reps: 0, kg: 0, isDirty: true)]));
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white12, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add_circle_outline, color: Colors.white60, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Exercise',
              style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showExerciseSearch() {
    final searchController = TextEditingController();
    List<ExerciseResult> results = [];
    bool isSearching = false;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (innerCtx, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: OnboardingTheme.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search exercises...',
                        hintStyle: TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.search, color: Colors.white38, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (q) async {
                        if (q.length < 2) {
                          setSheetState(() => results = []);
                          return;
                        }
                        setSheetState(() => isSearching = true);
                        final r = await context.read<WorkoutProvider>().searchExercises(q);
                        setSheetState(() {
                          results = r;
                          isSearching = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Results
                  Expanded(
                    child: isSearching
                        ? const Center(child: CircularProgressIndicator(color: OnboardingTheme.accent))
                        : results.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.fitness_center, color: Colors.white.withAlpha(40), size: 48),
                                    const SizedBox(height: 12),
                                    Text(
                                      searchController.text.isEmpty ? 'Type to search exercises' : 'No exercises found',
                                      style: const TextStyle(color: Colors.white38),
                                    ),
                                    const SizedBox(height: 16),
                                    if (searchController.text.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(innerCtx, searchController.text);
                                        },
                                        child: Text(
                                          'Add "${searchController.text}" manually',
                                          style: const TextStyle(color: OnboardingTheme.accent, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: results.length,
                                itemBuilder: (_, i) {
                                  final exercise = results[i];

                                  return InkWell(
                                    onTap: () {
                                      Navigator.pop(innerCtx, exercise.name);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        children: [
                                          ExerciseGifWidget(
                                            gifUrl: exercise.gifUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  exercise.name,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  exercise.targetMuscles.take(2).join(' · '),
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
          },
        );
      },
    );
  }
}
