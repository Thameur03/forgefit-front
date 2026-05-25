import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/nutrition_provider.dart';
import '../../../core/network/api_client.dart';
import 'add_food_screen.dart' show buildNutritionPayload;


class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> foodData;
  final String targetMeal;
  /// Null = today. Passed down from NutritionScreen so the food is saved
  /// under the date the user is currently viewing.
  final DateTime? selectedDate;

  const FoodDetailScreen({
    super.key,
    required this.foodData,
    required this.targetMeal,
    this.selectedDate,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 100; // grams
  late final TextEditingController _quantityController;
  bool _isSaving = false;
  bool _isFavorite = false;

  // Base values per 100g (backend always returns per-100g after the fix)
  late final String _foodName;
  late final String _brand;
  late final double _baseCalories;
  late final double _baseProtein;
  late final double _baseCarbs;
  late final double _baseFat;
  late final int? _fdcId;

  // Micronutrients
  List<Map<String, dynamic>> _nutrients = [];
  bool _loadingNutrients = false;

  // Favorites preference key
  static const _favKey = 'favorite_foods';

  // Nutrient groups
  static const _groups = <String, List<int>>{
    'Minerals': [1087, 1089, 1090, 1091, 1092, 1093, 1095, 1098],
    'Fat-Soluble Vitamins': [1106, 1109, 1114, 1185],
    'Water-Soluble Vitamins': [1162, 1165, 1166, 1167, 1175, 1177, 1178],
    'Other': [1079],
  };

  @override
  void initState() {
    super.initState();
    final food = widget.foodData;
    _foodName = food['name'] as String? ?? 'Unknown Food';
    _brand    = food['brand'] as String? ?? '';
    _baseCalories = (food['calories'] as num?)?.toDouble() ?? 0.0;
    _baseProtein  = (food['protein_g'] as num?)?.toDouble() ?? 0.0;
    _baseCarbs    = (food['carbs_g'] as num?)?.toDouble() ?? 0.0;
    _baseFat      = (food['fat_g'] as num?)?.toDouble() ?? 0.0;
    _fdcId        = food['fdc_id'] == null ? null : int.tryParse(food['fdc_id'].toString());
    _quantityController = TextEditingController(text: '100');
    _checkFavorite();
    _fetchNutrients();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  // ── Nutrient fetch ──────────────────────────────────────────────────────────

  Future<void> _fetchNutrients() async {
    final fdcId = widget.foodData['fdc_id'];
    if (fdcId == null) return;
    setState(() => _loadingNutrients = true);
    try {
      final response = await context
          .read<ApiClient>()
          .get('/food/$fdcId/nutrients');
      if (mounted) {
        setState(() {
          _nutrients =
              List<Map<String, dynamic>>.from(response.data as List? ?? []);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _nutrients = []);
    } finally {
      if (mounted) setState(() => _loadingNutrients = false);
    }
  }

  // ── Scaled values (backend values are per 100g) ─────────────────────────────

  double get _calories => (_baseCalories / 100) * _quantity;
  double get _protein  => (_baseProtein  / 100) * _quantity;
  double get _carbs    => (_baseCarbs    / 100) * _quantity;
  double get _fat      => (_baseFat      / 100) * _quantity;

  void _changeQuantity(int delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(1, 9999);
      _quantityController.text = _quantity.toString();
    });
  }

  void _onQuantitySubmitted(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= 1) {
      setState(() {
        _quantity = parsed.clamp(1, 9999);
        _quantityController.text = _quantity.toString();
      });
    } else {
      _quantityController.text = _quantity.toString();
    }
  }

  // ── Favorites ───────────────────────────────────────────────────────────────

  Future<void> _checkFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_favKey) ?? [];
    final id = _fdcId?.toString() ?? _foodName;
    final isFav = favs.any((f) {
      try {
        final m = jsonDecode(f) as Map<String, dynamic>;
        return m['fdc_id']?.toString() == id;
      } catch (_) {
        return false;
      }
    });
    if (mounted) setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_favKey) ?? [];
    final id = _fdcId?.toString() ?? _foodName;

    if (_isFavorite) {
      favs.removeWhere((f) {
        try {
          final m = jsonDecode(f) as Map<String, dynamic>;
          return m['fdc_id']?.toString() == id;
        } catch (_) {
          return false;
        }
      });
    } else {
      favs.add(jsonEncode(widget.foodData));
    }

    await prefs.setStringList(_favKey, favs);
    if (mounted) setState(() => _isFavorite = !_isFavorite);
  }

  // ── Add to meal ─────────────────────────────────────────────────────────────

  Future<void> _addToMeal() async {
    if (_calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Calories must be greater than 0'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_isSaving) return;
    setState(() => _isSaving = true);

    // Resolve meal: if targetMeal is empty (shouldn't normally happen once
    // the meal picker is wired up) fall back to 'breakfast' as a safe default.
    final mealKey = widget.targetMeal.trim().isEmpty
        ? 'breakfast'
        : widget.targetMeal.trim();

    final provider = context.read<NutritionProvider>();
    final targetDate = widget.selectedDate ?? DateTime.now();

    // Use the shared payload builder — guaranteed non-empty meal_name,
    // explicit date, no extra UI-only fields.
    final body = buildNutritionPayload(
      selectedDate: targetDate,
      mealKey:      mealKey,
      food:         {
        'name':    _foodName,
        'fdc_id':  _fdcId,
        // Passing scaled values so the builder uses them directly.
        // The builder expects raw food values but we override the
        // calories/protein/carbs/fat params below.
      },
      calories: _calories,
      protein:  _protein,
      carbs:    _carbs,
      fat:      _fat,
    );

    debugPrint('[FoodDetail] selectedDate=${widget.selectedDate} '
        'mealKey=$mealKey payload=$body');

    try {
      await provider.postNutritionLog(body, selectedDate: targetDate);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ── Micronutrient group widgets ─────────────────────────────────────────────

  List<Widget> _buildNutrientGroups() {
    final widgets = <Widget>[];

    for (final entry in _groups.entries) {
      final groupNutrients = _nutrients
          .where((n) => (_groups[entry.key] ?? []).contains(n['id'] as int?))
          .toList();
      if (groupNutrients.isEmpty) continue;

      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
        child: Text(
          entry.key.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ));

      for (final n in groupNutrients) {
        // Scale by current quantity (nutrients are per 100g)
        final baseAmount = (n['amount'] as num?)?.toDouble() ?? 0.0;
        final scaled = baseAmount / 100 * _quantity;
        final rdaRaw = n['rda'];
        final rda = rdaRaw is num ? rdaRaw.toDouble() : 0.0;
        final pct = rda > 0 ? (scaled / rda * 100) : 0.0;
        final pctClamped = pct.clamp(0.0, 100.0);
        final unit = n['unit'] as String? ?? '';

        final barColor = pct >= 100
            ? Colors.green
            : pct >= 50
                ? const Color(0xFF4A90E2)
                : Colors.grey;

        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      n['name'] as String? ?? '',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '${scaled.toStringAsFixed(1)}$unit',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 42,
                    child: Text(
                      '${pct.toStringAsFixed(0)}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        color: barColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: pctClamped / 100,
                  minHeight: 3,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
        ));
      }
    }
    return widgets;
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mealLabel = _capitalize(widget.targetMeal);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(_foodName, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            if (_brand.isNotEmpty) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _brand,
                  style: TextStyle(
                      color: Colors.white.withAlpha(102), fontSize: 13),
                ),
              ),
            ],

            // ── Calorie display ───────────────────────────────────
            const SizedBox(height: 24),
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${_calories.round()} ',
                      style: const TextStyle(
                        color: Color(0xFF4A90E2),
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: 'kcal',
                      style: TextStyle(
                          color: Colors.white60,
                          fontSize: 22,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Quantity picker ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _changeQuantity(-1),
                  onLongPress: () => _changeQuantity(-10),
                  child: _RoundButton(icon: Icons.remove),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 88,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.white.withAlpha(77)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.white.withAlpha(77)),
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed >= 1) {
                        setState(() => _quantity = parsed);
                      }
                    },
                    onSubmitted: _onQuantitySubmitted,
                    onEditingComplete: () =>
                        _onQuantitySubmitted(_quantityController.text),
                  ),
                ),
                const SizedBox(width: 8),
                Text('g',
                    style:
                        TextStyle(color: Colors.white.withAlpha(128))),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _changeQuantity(1),
                  onLongPress: () => _changeQuantity(10),
                  child: _RoundButton(icon: Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const Divider(height: 1, color: Colors.white12),
            const SizedBox(height: 20),

            // ── Macro breakdown ───────────────────────────────────
            Text(
              'MACRO BREAKDOWN',
              style: TextStyle(
                color: Colors.white.withAlpha(128),
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            _MacroBarRow(
              label: 'Protein',
              value: _protein,
              color: const Color(0xFF4A90E2),
              maxGrams: _baseProtein.clamp(1, 200),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _MacroBarRow(
                    label: 'Carbs',
                    value: _carbs,
                    color: const Color(0xFFF5A623),
                    maxGrams: _baseCarbs.clamp(1, 200),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MacroBarRow(
                    label: 'Fats',
                    value: _fat,
                    color: const Color(0xFF50C878),
                    maxGrams: _baseFat.clamp(1, 200),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Micronutrients  ─────────────────────────────────────
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: ExpansionTile(
                  title: const Text(
                    'Micronutrients',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  leading: const Icon(Icons.science_outlined,
                      color: Color(0xFF4A90E2)),
                  initiallyExpanded: false,
                  childrenPadding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: _loadingNutrients
                      ? [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ]
                      : _nutrients.isEmpty
                          ? [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No micronutrient data available',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ]
                          : _buildNutrientGroups(),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Add to meal — above system nav bar ───────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _addToMeal,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Add to $mealLabel',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _RoundButton extends StatelessWidget {
  final IconData icon;
  const _RoundButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.white.withAlpha(51)),
      ),
      child: Icon(icon, size: 22),
    );
  }
}

class _MacroBarRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double maxGrams;

  const _MacroBarRow({
    required this.label,
    required this.value,
    required this.color,
    required this.maxGrams,
  });

  @override
  Widget build(BuildContext context) {
    final fraction =
        maxGrams > 0 ? (value / maxGrams).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70)),
            Text(
              '${value.toStringAsFixed(1)}g',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: Colors.white.withAlpha(26),
            color: color,
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
