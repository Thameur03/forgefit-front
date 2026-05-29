import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/nutrition_provider.dart';
import '../models/nutrition_model.dart';
import '../screens/add_food_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../workout/providers/workout_provider.dart';
import '../../../core/network/api_client.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  DateTime _selectedDate = DateTime.now();

  // Macro goals from SharedPreferences
  double _calorieGoal = 2600;
  int _proteinGoal = 180;
  int _carbsGoal = 300;
  int _fatGoal = 90;

  // Tapped donut segment — null = nothing selected
  String? _selectedMacro;

  // Meal names: 4 fixed + custom from SharedPreferences
  List<String> _mealNames = ['breakfast', 'lunch', 'dinner', 'snacks'];

  static const Color _proteinColor = Color(0xFF4A90E2);
  static const Color _carbsColor = Color(0xFFF5A623);
  static const Color _fatColor = Color(0xFF50C878);

  @override
  void initState() {
    super.initState();
    _loadMealNames();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Wake Railway before loading — prevents cold-start zeros
      try {
        await context.read<ApiClient>().get('/health');
      } catch (_) {}
      if (mounted) {
        await context.read<NutritionProvider>().loadTodayNutrition();
        _loadMacroGoals();
      }
    });
  }

  // ── Per-user SharedPreferences key helpers ────────────────────────────────

  String _userId() {
    // user.id is a non-nullable String once the user is loaded.
    final user = context.read<AuthProvider>().currentUser;
    final scope = user != null ? user.id : (user?.email ?? 'guest');
    debugPrint('[NutritionScreen] pref scope userId=$scope');
    return scope;
  }

  String _mealNamesKey()   => 'custom_meal_names_user_${_userId()}';
  String _calorieKey()     => 'macro_calorie_goal_user_${_userId()}';
  String _proteinPctKey()  => 'macro_protein_pct_user_${_userId()}';
  String _carbsPctKey()    => 'macro_carbs_pct_user_${_userId()}';
  String _fatPctKey()      => 'macro_fat_pct_user_${_userId()}';

  Future<void> _loadMacroGoals() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final storedGoal = prefs.getDouble(_calorieKey()) ?? 2600;
    if (storedGoal > 10000 || storedGoal < 500) {
      await prefs.setDouble(_calorieKey(), 2600);
      await prefs.setDouble(_proteinPctKey(), 0.277);
      await prefs.setDouble(_carbsPctKey(), 0.462);
      await prefs.setDouble(_fatPctKey(), 0.277);
    }

    setState(() {
      _calorieGoal = (prefs.getDouble(_calorieKey()) ?? 2600)
          .clamp(500.0, 10000.0);
      final proteinPct = prefs.getDouble(_proteinPctKey()) ?? 0.277;
      final carbsPct   = prefs.getDouble(_carbsPctKey())   ?? 0.462;
      final fatPct     = prefs.getDouble(_fatPctKey())     ?? 0.277;
      _proteinGoal = (_calorieGoal * proteinPct / 4).round();
      _carbsGoal   = (_calorieGoal * carbsPct   / 4).round();
      _fatGoal     = (_calorieGoal * fatPct     / 9).round();
    });
  }

  Future<void> _loadMealNames() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = prefs.getStringList(_mealNamesKey()) ?? [];
    debugPrint('[NutritionScreen] loading meal names key=${_mealNamesKey()} custom=$custom');
    if (!mounted) return;
    setState(() {
      _mealNames = ['breakfast', 'lunch', 'dinner', 'snacks', ...custom];
    });
  }

  String _dateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sel = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day);
    final diff = today.difference(sel).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM d').format(_selectedDate);
  }

  void _changeDate(int delta) {
    final newDate = _selectedDate.add(Duration(days: delta));
    final now = DateTime.now();
    if (newDate.isAfter(now)) return;
    setState(() => _selectedDate = newDate);
    final provider = context.read<NutritionProvider>();
    final dateStr = DateFormat('yyyy-MM-dd').format(newDate);
    final today = DateTime(now.year, now.month, now.day);
    final sel = DateTime(newDate.year, newDate.month, newDate.day);
    if (sel == today) {
      provider.loadTodayNutrition();
    } else {
      provider.loadNutritionForDate(dateStr);
    }
  }

  static const Map<String, _MealConfig> _fixedMealConfigs = {
    'breakfast': _MealConfig('Breakfast', 'breakfast', Icons.free_breakfast),
    'lunch': _MealConfig('Lunch', 'lunch', Icons.lunch_dining),
    'dinner': _MealConfig('Dinner', 'dinner', Icons.restaurant),
    'snacks': _MealConfig('Snacks', 'snacks', Icons.cookie),
  };

  _MealConfig _configForKey(String key) {
    if (_fixedMealConfigs.containsKey(key)) return _fixedMealConfigs[key]!;
    // Custom meal
    final label = key.isNotEmpty
        ? key[0].toUpperCase() + key.substring(1)
        : key;
    return _MealConfig(label, key, Icons.restaurant_menu);
  }

  List<NutritionModel> _logsForMeal(
      List<NutritionModel> logs, String mealKey) {
    return logs.where((l) {
      final lm = l.mealType.toLowerCase();
      if (mealKey == 'snacks') return lm == 'snack' || lm == 'snacks';
      return lm == mealKey.toLowerCase();
    }).toList();
  }

  void _showMacroSources(String macro, List<NutritionModel> logs) {
    final sorted = [...logs]..sort((a, b) {
        final aVal = macro == 'protein'
            ? a.protein
            : macro == 'carbs'
                ? a.carbs
                : a.fat;
        final bVal = macro == 'protein'
            ? b.protein
            : macro == 'carbs'
                ? b.carbs
                : b.fat;
        return bVal.compareTo(aVal);
      });

    final color = macro == 'protein'
        ? _proteinColor
        : macro == 'carbs'
            ? _carbsColor
            : _fatColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${macro[0].toUpperCase()}${macro.substring(1)} Sources',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: sorted.isEmpty
                ? const Center(child: Text('No foods logged today'))
                : ListView.builder(
                    itemCount: sorted.length,
                    itemBuilder: (_, i) {
                      final food = sorted[i];
                      final val = macro == 'protein'
                          ? food.protein
                          : macro == 'carbs'
                              ? food.carbs
                              : food.fat;
                      return ListTile(
                        title: Text(food.foodName),
                        subtitle: Text(food.mealType),
                        trailing: Text(
                          '${val.toStringAsFixed(1)}g',
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ).whenComplete(() => setState(() => _selectedMacro = null));
  }

  void _showAddCustomMealDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('New Meal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: 'e.g. Pre-workout, Midnight snack'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final prefs = await SharedPreferences.getInstance();
              final key   = _mealNamesKey();
              final custom = prefs.getStringList(key) ?? [];
              custom.add(name.toLowerCase());
              await prefs.setStringList(key, custom);
              debugPrint('[NutritionScreen] saved meal names key=$key names=$custom');
              if (mounted) Navigator.pop(context);
              _loadMealNames();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<NutritionProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                // ── Header ──────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 16, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        'Nutrition',
                        style:
                            theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // ── Micronutrient dashboard button ──────────
                      IconButton(
                        icon: Icon(
                          Icons.science_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        tooltip: 'Today\'s Nutrients',
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/nutrition/micronutrients',
                        ),
                      ),
                      const SizedBox(width: 4),
                      _DateNavigator(
                        label: _dateLabel(),
                        onPrev: () => _changeDate(-1),
                        onNext: () => _changeDate(1),
                        canGoForward: DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                            ) !=
                            DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                            ),
                      ),
                    ],
                  ),
                ),

                // ── Calorie progress bar ─────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _CalorieProgressBar(
                    consumed: provider.todaySummary?.totalCalories
                            .round() ??
                        0,
                    goal: _calorieGoal.round(),
                    primaryColor: theme.colorScheme.primary,
                  ),
                ),

                // ── Scrollable body ──────────────────────────────
                Expanded(
                  child: _buildBody(context, provider, theme),
                ),
              ],
            );
          },
        ),
      ),

      // ── Add Food FAB ─────────────────────────────────────────
      bottomSheet: _buildAddFoodButton(context, theme),
    );
  }

  Widget _buildBody(
      BuildContext context, NutritionProvider provider, ThemeData theme) {
    if (provider.isLoading && provider.todaySummary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null &&
        provider.todaySummary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load nutrition data',
                style:
                    TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<NutritionProvider>().loadTodayNutrition(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final dateKeyStr = NutritionProvider.dateKey(_selectedDate);
    final summary = provider.summaryForDate(dateKeyStr);
    final logs = provider.logsForDate(dateKeyStr);
    final protein = summary?.totalProtein ?? 0.0;
    final carbs = summary?.totalCarbs ?? 0.0;
    final fat = summary?.totalFat ?? 0.0;
    final consumed = summary?.totalCalories ?? 0.0;

    return RefreshIndicator(
      onRefresh: () async {
        final now = DateTime.now();
        final selDay = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day);
        final today = DateTime(now.year, now.month, now.day);
        if (selDay == today) {
          await provider.loadTodayNutrition();
        } else {
          await provider.loadNutritionForDate(
              NutritionProvider.dateKey(_selectedDate));
        }
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // ── Tappable Donut Chart ─────────────────────────────
          _DonutChart(
            protein: protein,
            carbs: carbs,
            fat: fat,
            consumed: consumed.round(),
            goal: _calorieGoal.round(),
            proteinColor: _proteinColor,
            carbsColor: _carbsColor,
            fatColor: _fatColor,
            selectedMacro: _selectedMacro,
            calorieColor: _getCalorieColor(consumed, _calorieGoal),
            onMacroTap: (macro) {
              setState(() {
                _selectedMacro =
                    _selectedMacro == macro ? null : macro;
              });
              if (_selectedMacro != null) {
                _showMacroSources(_selectedMacro!, logs);
              }
            },
          ),

          // ── EDIT GOALS between chart and legend ──────────────
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                await Navigator.pushNamed(
                    context, '/nutrition/macro-targets');
                _loadMacroGoals();
              },
              child: Text(
                'EDIT GOALS',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // ── Macro Legend ─────────────────────────────────────
          _MacroLegend(
            protein: protein,
            carbs: carbs,
            fat: fat,
            proteinGoal: _proteinGoal,
            carbsGoal: _carbsGoal,
            fatGoal: _fatGoal,
            proteinColor: _proteinColor,
            carbsColor: _carbsColor,
            fatColor: _fatColor,
          ),

          const SizedBox(height: 16),

          // ── Recovery card ────────────────────────────────────
          Consumer<WorkoutProvider>(
            builder: (ctx, workoutProvider, _) {
              final today = DateTime.now();
              final hasWorkoutToday =
                  workoutProvider.workouts.any((w) =>
                      w.date.year == today.year &&
                      w.date.month == today.month &&
                      w.date.day == today.day);
              if (!hasWorkoutToday) return const SizedBox.shrink();
              return _RecoveryCard(
                  protein: protein, proteinGoal: _proteinGoal);
            },
          ),

          const SizedBox(height: 8),

          // ── Meals section header ─────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meals',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
              IconButton(
                icon: Icon(Icons.add,
                    color: theme.colorScheme.primary),
                onPressed: _showAddCustomMealDialog,
                tooltip: 'Add custom meal',
              ),
            ],
          ),

          const SizedBox(height: 4),

          // ── Meal cards (fixed + custom) ──────────────────────
          ..._mealNames.map((key) {
            final config = _configForKey(key);
            final mealLogs = _logsForMeal(logs, key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MealCard(
                meal: config,
                logs: mealLogs,
                proteinColor: _proteinColor,
                carbsColor: _carbsColor,
                fatColor: _fatColor,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddFoodScreen(
                        initialMeal: key,
                        selectedDate: _selectedDate,
                      ),
                    ),
                  ).then((_) => setState(() {})),
                onDeleteLog: (log) async {
                  await context.read<NutritionProvider>().deleteLog(
                        log.id,
                        forDate: _selectedDate,
                      );
                },
                onEditLog: (log) => _showEditFoodSheet(context, log),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Traffic-light color for the calorie number in the donut center.
  static Color _getCalorieColor(double consumed, double goal) {
    if (goal <= 0) return Colors.white;
    final ratio = consumed / goal;
    if (ratio >= 0.6 && ratio <= 1.2) return const Color(0xFF50C878);
    if ((ratio >= 0.4 && ratio < 0.6) || (ratio > 1.2 && ratio <= 1.4)) {
      return const Color(0xFFF5A623);
    }
    return const Color(0xFFEF4444);
  }

  // ── Edit food entry bottom sheet ─────────────────────────────────────────

  void _showEditFoodSheet(BuildContext ctx, NutritionModel log) {
    final caloriesCtrl =
        TextEditingController(text: log.calories.toStringAsFixed(0));
    final proteinCtrl =
        TextEditingController(text: log.protein.toStringAsFixed(1));
    final carbsCtrl =
        TextEditingController(text: log.carbs.toStringAsFixed(1));
    final fatCtrl =
        TextEditingController(text: log.fat.toStringAsFixed(1));

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Theme.of(ctx).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(log.foodName,
                style: Theme.of(ctx).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _editField('Calories', caloriesCtrl)),
              const SizedBox(width: 8),
              Expanded(child: _editField('Protein (g)', proteinCtrl)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _editField('Carbs (g)', carbsCtrl)),
              const SizedBox(width: 8),
              Expanded(child: _editField('Fat (g)', fatCtrl)),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final updated = NutritionModel(
                    id: log.id,
                    foodName: log.foodName,
                    consumedAt: log.consumedAt,
                    mealType: log.mealType,
                    amount: log.amount,
                    unit: log.unit,
                    calories:
                        double.tryParse(caloriesCtrl.text) ?? log.calories,
                    protein:
                        double.tryParse(proteinCtrl.text) ?? log.protein,
                    carbs: double.tryParse(carbsCtrl.text) ?? log.carbs,
                    fat: double.tryParse(fatCtrl.text) ?? log.fat,
                    fdcId: log.fdcId,
                  );
                  Navigator.pop(sheetCtx);
                  await ctx.read<NutritionProvider>().logFood(updated);
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildAddFoodButton(BuildContext context, ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddFoodScreen(
                // empty string = show meal picker before saving
                initialMeal: '',
                selectedDate: _selectedDate,
              ),
            ),
          ).then((_) => setState(() {})),
          icon: const Icon(Icons.add),
          label: const Text('Add Food'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
            textStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// ── Helper data class ──────────────────────────────────────────────────────────

class _MealConfig {
  final String label;
  final String key;
  final IconData icon;
  const _MealConfig(this.label, this.key, this.icon);
}

// ── Date Navigator ────────────────────────────────────────────────────────────

class _DateNavigator extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool canGoForward;

  const _DateNavigator({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.canGoForward,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(minWidth: 28, minHeight: 28),
            iconSize: 20,
          ),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          IconButton(
            icon: Icon(Icons.chevron_right,
                color: canGoForward
                    ? null
                    : Colors.white.withAlpha(51)),
            onPressed: canGoForward ? onNext : null,
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(minWidth: 28, minHeight: 28),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

// ── Calorie Progress Bar ──────────────────────────────────────────────────────

class _CalorieProgressBar extends StatelessWidget {
  final int consumed;
  final int goal;
  final Color primaryColor;

  const _CalorieProgressBar({
    required this.consumed,
    required this.goal,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction =
        goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Calories',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.white.withAlpha(153))),
            Text('$consumed / $goal kcal',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.white.withAlpha(153))),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: Colors.white.withAlpha(26),
            color: primaryColor,
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

// ── Donut Chart (tappable) ────────────────────────────────────────────────────

class _DonutChart extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final int consumed;
  final int goal;
  final Color proteinColor;
  final Color carbsColor;
  final Color fatColor;
  final String? selectedMacro;
  final Color calorieColor;
  final void Function(String macro) onMacroTap;

  const _DonutChart({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.consumed,
    required this.goal,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
    required this.selectedMacro,
    required this.calorieColor,
    required this.onMacroTap,
  });

  double _radius(String macro) =>
      selectedMacro == macro ? 38.0 : 28.0;

  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fat;
    final isEmpty = total == 0;

    final sections = isEmpty
        ? [
            PieChartSectionData(
              value: 1,
              color: Colors.white.withAlpha(26),
              radius: 28,
              showTitle: false,
            ),
          ]
        : [
            // index 0 = protein
            PieChartSectionData(
              value: protein,
              color: proteinColor,
              radius: _radius('protein'),
              showTitle: false,
            ),
            // index 1 = carbs
            PieChartSectionData(
              value: carbs,
              color: carbsColor,
              radius: _radius('carbs'),
              showTitle: false,
            ),
            // index 2 = fat
            PieChartSectionData(
              value: fat,
              color: fatColor,
              radius: _radius('fat'),
              showTitle: false,
            ),
          ];

    const macros = ['protein', 'carbs', 'fat'];

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: isEmpty ? 0 : 3,
              centerSpaceRadius: 80,
              startDegreeOffset: -90,
              pieTouchData: isEmpty
                  ? PieTouchData(enabled: false)
                  : PieTouchData(
                      touchCallback:
                          (FlTouchEvent event, pieTouchResponse) {
                        if (event is FlTapUpEvent) {
                          final index = pieTouchResponse
                              ?.touchedSection
                              ?.touchedSectionIndex;
                          if (index != null &&
                              index >= 0 &&
                              index < macros.length) {
                            onMacroTap(macros[index]);
                          }
                        }
                      },
                    ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 600),
                style: TextStyle(
                  color: calorieColor,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                child: Text('$consumed'),
              ),
              Text(
                '/ $goal KCAL',
                style: TextStyle(
                    color: Colors.white.withAlpha(128),
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Macro Legend ──────────────────────────────────────────────────────────────

class _MacroLegend extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;
  final Color proteinColor;
  final Color carbsColor;
  final Color fatColor;

  const _MacroLegend({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MacroRow(
            label: 'Protein',
            dotColor: proteinColor,
            consumed: protein,
            goal: proteinGoal),
        const SizedBox(height: 8),
        _MacroRow(
            label: 'Carbs',
            dotColor: carbsColor,
            consumed: carbs,
            goal: carbsGoal),
        const SizedBox(height: 8),
        _MacroRow(
            label: 'Fats',
            dotColor: fatColor,
            consumed: fat,
            goal: fatGoal),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final Color dotColor;
  final double consumed;
  final int goal;

  const _MacroRow({
    required this.label,
    required this.dotColor,
    required this.consumed,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOver = consumed > goal;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(label, style: theme.textTheme.bodyMedium),
        const Spacer(),
        Text(
          '${consumed.round()}',
          style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isOver ? Colors.red : Colors.white),
        ),
        Text(' / ${goal}g',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.white.withAlpha(102))),
      ],
    );
  }
}

// ── Recovery Card ─────────────────────────────────────────────────────────────

class _RecoveryCard extends StatelessWidget {
  final double protein;
  final int proteinGoal;
  const _RecoveryCard({required this.protein, required this.proteinGoal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deficit = proteinGoal > 0
        ? ((proteinGoal - protein) / proteinGoal * 100).round()
        : 0;
    final isGood = deficit <= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4).withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.monitor_heart_outlined,
                color: Color(0xFF00BCD4), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('RECOVERY ANALYSIS',
                    style: TextStyle(
                        color: Color(0xFF00BCD4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8)),
                const SizedBox(height: 4),
                isGood
                    ? const Text(
                        'Protein intake on track for optimal recovery.',
                        style: TextStyle(
                            fontSize: 13, color: Colors.green))
                    : RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white),
                          children: [
                            const TextSpan(text: 'Protein intake '),
                            TextSpan(
                                text: '$deficit% below',
                                style: const TextStyle(
                                    color: Colors.red)),
                            const TextSpan(
                                text:
                                    ' optimal recovery threshold.'),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meal Card ─────────────────────────────────────────────────────────────────

class _MealCard extends StatelessWidget {
  final _MealConfig meal;
  final List<NutritionModel> logs;
  final Color proteinColor;
  final Color carbsColor;
  final Color fatColor;
  final VoidCallback onTap;
  final void Function(NutritionModel log) onDeleteLog;
  final void Function(NutritionModel log) onEditLog;

  const _MealCard({
    required this.meal,
    required this.logs,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
    required this.onTap,
    required this.onDeleteLog,
    required this.onEditLog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCal =
        logs.fold<double>(0, (s, l) => s + l.calories);
    final totalProtein =
        logs.fold<double>(0, (s, l) => s + l.protein);
    final totalCarbs =
        logs.fold<double>(0, (s, l) => s + l.carbs);
    final totalFat = logs.fold<double>(0, (s, l) => s + l.fat);
    final macroTotal = totalProtein + totalCarbs + totalFat;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(meal.icon,
                    color: Colors.white.withAlpha(153), size: 20),
                const SizedBox(width: 10),
                Text(meal.label,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${totalCal.round()} kcal',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            if (logs.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...logs.map((log) {
                return Dismissible(
                  key: Key('food_${log.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white, size: 20),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: theme.colorScheme.surface,
                        title: const Text('Delete entry?'),
                        content: Text('Remove ${log.foodName} from ${log.mealType}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => onDeleteLog(log),
                  child: GestureDetector(
                    onLongPress: () => onEditLog(log),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              log.foodName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withAlpha(200),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${log.calories.round()} kcal',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              if (macroTotal > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 5,
                    child: Row(
                      children: [
                        Flexible(
                          flex: (totalProtein * 100).round(),
                          child: Container(color: proteinColor),
                        ),
                        Flexible(
                          flex: (totalCarbs * 100).round(),
                          child: Container(color: carbsColor),
                        ),
                        Flexible(
                          flex: (totalFat * 100).round(),
                          child: Container(color: fatColor),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else ...[
              const SizedBox(height: 6),
              Text(
                'No items — tap to add food',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withAlpha(77)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
