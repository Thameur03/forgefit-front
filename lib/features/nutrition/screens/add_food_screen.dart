import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/nutrition_provider.dart';
import '../models/nutrition_model.dart';
import 'barcode_scanner_screen.dart';

/// Maps UI meal key → backend meal_name string
String toBackendMealName(String meal) {
  const map = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
    'snacks': 'Snack', // backend singular
  };
  // For custom meals, capitalize first letter
  return map[meal.toLowerCase()] ??
      (meal.isNotEmpty
          ? meal[0].toUpperCase() + meal.substring(1)
          : meal);
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

// ── Logged item (holds raw food map + mutable quantity) ──────────────────────

class _LoggedItem {
  final String id;
  final Map<String, dynamic> food;
  double quantity;

  _LoggedItem({required this.id, required this.food, this.quantity = 100.0});

  double get _factor => quantity / 100.0;
  double get kcal    => ((food['calories']   ?? 0) as num).toDouble() * _factor;
  double get protein => ((food['protein_g']  ?? 0) as num).toDouble() * _factor;
  double get carbs   => ((food['carbs_g']    ?? 0) as num).toDouble() * _factor;
  double get fat     => ((food['fat_g']      ?? 0) as num).toDouble() * _factor;
  String get name    => (food['food_name'] ?? food['name'] ?? 'Unknown') as String;
}

class AddFoodScreen extends StatefulWidget {
  final String initialMeal;
  const AddFoodScreen({super.key, required this.initialMeal});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _activeFilter = 'All';
  String _query = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  int _addedCount = 0;

  final List<_LoggedItem> _loggedItems = [];

  List<Map<String, dynamic>> _frequentFoods = [];
  bool _loadingHistory = true;

  final Map<String, Map<String, dynamic>> _commonFoodCache = {};
  final Set<String> _failedLookups = {};
  bool _loadingCommonSources = false;

  List<Map<String, dynamic>> _favoriteFoods = [];

  static const List<String> _filters = [
    'All', 'Protein', 'Carbs', 'Fats', 'Favorites',
  ];

  static const Map<String, List<String>> _commonFoodsByFilter = {
    'Protein': ['Egg Whites', 'Greek Yogurt', 'Salmon Fillet', 'Tempeh', 'Cottage Cheese'],
    'Carbs':   ['Brown Rice', 'Oats', 'Sweet Potato', 'Banana', 'Whole Wheat Bread'],
    'Fats':    ['Avocado', 'Almonds', 'Olive Oil', 'Peanut Butter', 'Walnuts'],
    'All':     ['Chicken Breast', 'Brown Rice', 'Avocado', 'Oats', 'Egg Whites', 'Almonds', 'Greek Yogurt'],
  };

  List<String> get _currentCommonFoodNames {
    if (_activeFilter == 'Favorites') return [];
    return _commonFoodsByFilter[_activeFilter] ??
        _commonFoodsByFilter['All']!;
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadFavorites();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _loadCommonSources());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_failedLookups.isNotEmpty) {
      _retryFailedLookups();
    }
  }

  Future<void> _retryFailedLookups() async {
    final toRetry = Set<String>.from(_failedLookups);
    for (final name in toRetry) {
      if (!mounted) return;
      final results =
          await context.read<NutritionProvider>().searchFood(name);
      if (results.isNotEmpty &&
          (results.first['calories'] as num? ?? 0) > 0) {
        if (mounted) {
          setState(() {
            _commonFoodCache[name] = results.first;
            _failedLookups.remove(name);
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    final provider = context.read<NutritionProvider>();
    final logs = await provider.loadNutritionHistory(days: 30);

    final freq = <String, int>{};
    final sample = <String, NutritionModel>{};
    for (final log in logs) {
      freq[log.foodName] = (freq[log.foodName] ?? 0) + 1;
      sample[log.foodName] ??= log;
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (mounted) {
      setState(() {
        _frequentFoods = sorted.take(5).map((e) {
          final log = sample[e.key]!;
          return {
            'name': log.foodName,
            'calories': log.calories,
            'protein_g': log.protein,
            'carbs_g': log.carbs,
            'fat_g': log.fat,
          };
        }).toList();
        _loadingHistory = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorite_foods') ?? [];
    if (mounted) {
      setState(() {
        _favoriteFoods = favs.map((f) {
          try {
            return jsonDecode(f) as Map<String, dynamic>;
          } catch (_) {
            return <String, dynamic>{};
          }
        }).where((m) => m.isNotEmpty).toList();
      });
    }
  }

  Future<void> _loadCommonSources() async {
    if (!mounted) return;
    setState(() => _loadingCommonSources = true);
    final provider = context.read<NutritionProvider>();
    final allNames = {
      ...?_commonFoodsByFilter['All'],
      ...?_commonFoodsByFilter['Protein'],
      ...?_commonFoodsByFilter['Carbs'],
      ...?_commonFoodsByFilter['Fats'],
    };
    for (final name in allNames) {
      if (_commonFoodCache.containsKey(name)) continue;
      final results = await provider.searchFood(name);
      if (mounted) {
        final first = results.isNotEmpty ? results.first : null;
        if (first != null && (first['calories'] as num? ?? 0) > 0) {
          setState(() => _commonFoodCache[name] = first);
        } else {
          // Don't cache failures — mark for retry
          _failedLookups.add(name);
        }
      }
    }
    if (mounted) setState(() => _loadingCommonSources = false);
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer =
        Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _query = value;
          _searchResults = [];
          _isSearching = value.isNotEmpty;
        });
        if (value.isNotEmpty) _runSearch(value);
      }
    });
  }

  Future<void> _runSearch(String query) async {
    final provider = context.read<NutritionProvider>();
    final results = await provider.searchFood(query);
    if (mounted && _query == query) {
      setState(() => _searchResults = results);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _isSearching = false;
      _searchResults = [];
    });
  }

  // Whole card tap → go to food detail
  void _openFoodDetail(Map<String, dynamic> foodData) {
    Navigator.pushNamed(
      context,
      '/nutrition/food-detail',
      arguments: {
        'foodData': foodData,
        'targetMeal': widget.initialMeal,
      },
    ).then((_) => _loadFavorites());
  }

  // + button tap → quick-add bottom sheet
  void _showQuickAddSheet(Map<String, dynamic> food) {
    int quantity = 100;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final cal = (food['calories'] as num? ?? 0) / 100 * quantity;
          final pro =
              (food['protein_g'] as num? ?? 0) / 100 * quantity;
          final carbs =
              (food['carbs_g'] as num? ?? 0) / 100 * quantity;
          final fat =
              (food['fat_g'] as num? ?? 0) / 100 * quantity;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2)),
                ),
                Text(
                  food['name'] as String? ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${cal.toStringAsFixed(0)} kcal  •  '
                  '${pro.toStringAsFixed(1)}g P  •  '
                  '${carbs.toStringAsFixed(1)}g C  •  '
                  '${fat.toStringAsFixed(1)}g F',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => setSheetState(() =>
                          quantity = (quantity - 10).clamp(1, 9999)),
                      icon: const Icon(
                          Icons.remove_circle_outline),
                    ),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                            text: quantity.toString()),
                        decoration:
                            const InputDecoration(isDense: true),
                        onSubmitted: (v) => setSheetState(() =>
                            quantity = (int.tryParse(v) ?? quantity)
                                .clamp(1, 9999)),
                      ),
                    ),
                    const Text(' g',
                        style: TextStyle(color: Colors.grey)),
                    IconButton(
                      onPressed: () => setSheetState(() =>
                          quantity = (quantity + 10).clamp(1, 9999)),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      if (cal <= 0) {
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'Calories must be greater than 0'),
                            backgroundColor: Colors.red,
                          ));
                        }
                        return;
                      }
                      final body = {
                        'food_name': food['name'],
                        'meal_name':
                            toBackendMealName(widget.initialMeal),
                        'calories': cal,
                        'protein_g': pro,
                        'carbs_g': carbs,
                        'fat_g': fat,
                      };
                      try {
                        await context
                            .read<NutritionProvider>()
                            .postNutritionLog(body);
                        if (mounted) {
                          setState(() {
                            _addedCount++;
                            _loggedItems.add(_LoggedItem(
                              id: UniqueKey().toString(),
                              food: food,
                              quantity: quantity.toDouble(),
                            ));
                          });
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                            content: Text(
                                'Added to ${_capitalize(widget.initialMeal)}'),
                            backgroundColor: Colors.green,
                          ));
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                            content: Text('Failed: $e'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                    ),
                    child: Text(
                        'Add to ${_capitalize(widget.initialMeal)}'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onBarcodeTap() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (_) => const BarcodeScannerScreen()),
    );
    if (scannedCode != null && mounted) {
      final result = await _lookupBarcode(scannedCode);
      if (result != null && mounted) {
        _openFoodDetail(result);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Product not found. Try searching manually.')),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _lookupBarcode(
      String barcode) async {
    try {
      final response = await Dio().get(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
        options: Options(
            receiveTimeout: const Duration(seconds: 8)),
      );
      if (response.data['status'] == 1) {
        final product =
            response.data['product'] as Map<String, dynamic>;
        final nutriments =
            product['nutriments'] as Map<String, dynamic>? ??
                {};
        return {
          'fdc_id': barcode,
          'name': product['product_name'] ?? 'Unknown Product',
          'brand': product['brands'] ?? '',
          'calories':
              (nutriments['energy-kcal_100g'] as num?)
                      ?.toDouble() ??
                  0.0,
          'protein_g':
              (nutriments['proteins_100g'] as num?)
                      ?.toDouble() ??
                  0.0,
          'carbs_g':
              (nutriments['carbohydrates_100g'] as num?)
                      ?.toDouble() ??
                  0.0,
          'fat_g':
              (nutriments['fat_100g'] as num?)?.toDouble() ??
                  0.0,
        };
      }
    } catch (_) {}

    if (mounted) {
      final results =
          await context.read<NutritionProvider>().searchFood(barcode);
      return results.isNotEmpty ? results.first : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<NutritionProvider>().loadTodayNutrition();
            Navigator.pop(context);
          },
        ),
        title: const Text('Add Food'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: _loggedItems.isEmpty ? null : _showSaveMealSheet,
            icon: Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: _loggedItems.isEmpty ? Colors.white24 : Colors.blue,
            ),
            label: Text(
              'Save',
              style: TextStyle(
                color: _loggedItems.isEmpty ? Colors.white24 : Colors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _onBarcodeTap,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search foods or nutrients',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
            ),
          ),

          // ── Filter chips ────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filters[i];
                final isActive = _activeFilter == f;
                return ChoiceChip(
                  label: Text(f),
                  selected: isActive,
                  onSelected: (_) =>
                      setState(() => _activeFilter = f),
                  selectedColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surface,
                  labelStyle: TextStyle(
                    color: isActive
                        ? Colors.white
                        : Colors.white70,
                    fontWeight: isActive
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                  checkmarkColor: Colors.white,
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ── Logged items panel ──────────────────────────────────
          _buildLoggedItemsPanel(),

          // ── Body ────────────────────────────────────────────────
          Expanded(
            child: _isSearching
                ? _buildSearchResults(theme)
                : _buildDiscovery(theme),
          ),

          // ── Done bar (appears after first successful add) ──────
          if (_addedCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: theme.colorScheme.surface,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  'Done — $_addedCount item${_addedCount > 1 ? 's' : ''} added to ${_capitalize(widget.initialMeal)}',
                ),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF50C878)),
                onPressed: () {
                  context.read<NutritionProvider>().loadTodayNutrition();
                  Navigator.pop(context);
                },
              ),
            ),
        ],
      ),
    );
  }

  // ── Quick Discovery ───────────────────────────────────────────────────────

  Widget _buildDiscovery(ThemeData theme) {
    if (_activeFilter == 'Favorites') {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text('SAVED FAVORITES',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withAlpha(128),
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          if (_favoriteFoods.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'No favorites yet. Tap the \u2665 on any food to save it.',
                style: TextStyle(
                    color: Colors.white.withAlpha(77),
                    fontSize: 13),
              ),
            )
          else
            ..._favoriteFoods.map((food) => _FoodRow(
                  foodData: food,
                  onCardTap: () => _openFoodDetail(food),
                  onAddTap: () => _showQuickAddSheet(food),
                )),
        ],
      );
    }

    final filterLabel = _activeFilter == 'All'
        ? ''
        : '${_activeFilter.toUpperCase()} ';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text('YOUR FREQUENT ${filterLabel}SOURCES',
            style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withAlpha(128),
                letterSpacing: 1)),
        const SizedBox(height: 8),
        if (_loadingHistory)
          const Center(child: CircularProgressIndicator())
        else if (_frequentFoods.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'No history yet. Start logging food to see your frequent sources.',
              style: TextStyle(
                  color: Colors.white.withAlpha(77),
                  fontSize: 13),
            ),
          )
        else
          ..._frequentFoods.map((food) => _FoodRow(
                foodData: food,
                onCardTap: () => _openFoodDetail(food),
                onAddTap: () => _showQuickAddSheet(food),
              )),

        const SizedBox(height: 20),

        Text('COMMON ${filterLabel}SOURCES',
            style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withAlpha(128),
                letterSpacing: 1)),
        const SizedBox(height: 8),
        if (_loadingCommonSources)
          const Center(child: CircularProgressIndicator())
        else
          ..._currentCommonFoodNames.map((name) {
            final cached = _commonFoodCache[name];
            final isFailed = _failedLookups.contains(name);
            final displayData = cached ??
                {
                  'name': name,
                  'calories': 0.0,
                  'protein_g': 0.0,
                  'carbs_g': 0.0,
                  'fat_g': 0.0
                };
            return _FoodRow(
              foodData: displayData,
              onCardTap: () {
                if (cached != null) {
                  _openFoodDetail(cached);
                } else if (!isFailed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Loading…')),
                  );
                }
              },
              onAddTap: () {
                if (cached != null) {
                  _showQuickAddSheet(cached);
                }
              },
            );
          }),
      ],
    );
  }

  // ── Search Results ────────────────────────────────────────────────────────

  Widget _buildSearchResults(ThemeData theme) {
    if (_searchResults.isEmpty && _query.isNotEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No results for "$_query"',
          style: TextStyle(color: Colors.white.withAlpha(102)),
        ),
      );
    }
    final topResults = _searchResults.take(3).toList();
    final moreResults =
        _searchResults.skip(3).take(10).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text('TOP RESULTS',
            style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withAlpha(128),
                letterSpacing: 1)),
        const SizedBox(height: 8),
        ...topResults.map((food) => _FoodRow(
              foodData: food,
              showBrand: true,
              onCardTap: () => _openFoodDetail(food),
              onAddTap: () => _showQuickAddSheet(food),
            )),
        if (moreResults.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('MORE RESULTS',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withAlpha(128),
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          ...moreResults.map((food) => _FoodRow(
                foodData: food,
                showBrand: true,
                onCardTap: () => _openFoodDetail(food),
                onAddTap: () => _showQuickAddSheet(food),
              )),
        ],
        const SizedBox(height: 24),
        Center(
          child: Text(
            "Can't find it? Scan the barcode with the camera icon above.",
            style: TextStyle(
                color: Colors.white.withAlpha(77), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // ── Logged items panel ────────────────────────────────────────────────────

  Widget _buildLoggedItemsPanel() {
    if (_loggedItems.isEmpty) return const SizedBox.shrink();

    final totalKcal    = _loggedItems.fold(0.0, (s, i) => s + i.kcal);
    final totalProtein = _loggedItems.fold(0.0, (s, i) => s + i.protein);
    final totalCarbs   = _loggedItems.fold(0.0, (s, i) => s + i.carbs);
    final totalFat     = _loggedItems.fold(0.0, (s, i) => s + i.fat);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Colors.blue, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Logged (${_loggedItems.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          ..._loggedItems.map((item) => _buildLoggedItemRow(item)),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _macroChip('${totalKcal.toStringAsFixed(0)} kcal', Colors.white),
                _macroChip('P ${totalProtein.toStringAsFixed(1)}g', const Color(0xFF4FC3F7)),
                _macroChip('C ${totalCarbs.toStringAsFixed(1)}g', const Color(0xFFFFB74D)),
                _macroChip('F ${totalFat.toStringAsFixed(1)}g', const Color(0xFFCE93D8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedItemRow(_LoggedItem item) {
    final controller = TextEditingController(text: item.quantity.toStringAsFixed(0));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.kcal.toStringAsFixed(0)} kcal · P${item.protein.toStringAsFixed(1)} C${item.carbs.toStringAsFixed(1)} F${item.fat.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            height: 32,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                suffix: const Text('g', style: TextStyle(color: Colors.white38, fontSize: 11)),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (val) {
                final q = double.tryParse(val);
                if (q != null && q > 0) {
                  setState(() => item.quantity = q);
                }
              },
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _loggedItems.removeWhere((e) => e.id == item.id)),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _macroChip(String label, Color color) {
    return Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600));
  }

  void _showSaveMealSheet() {
    String selectedMeal = toBackendMealName(widget.initialMeal);
    final mealOptions = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Save Meal',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_loggedItems.length} item${_loggedItems.length == 1 ? '' : 's'} · '
                  '${_loggedItems.fold(0.0, (s, i) => s + i.kcal).toStringAsFixed(0)} kcal total',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 20),
                const Text('Meal Type', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: mealOptions.map((m) {
                    final selected = selectedMeal == m;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedMeal = m),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? Colors.blue : const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? Colors.blue : Colors.white12,
                          ),
                        ),
                        child: Text(
                          m,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white60,
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final provider = context.read<NutritionProvider>();
                      for (final item in List.of(_loggedItems)) {
                        final body = {
                          'food_name': item.name,
                          'fdc_id': item.food['fdc_id'],
                          'meal_name': selectedMeal,
                          'amount': item.quantity,
                          'unit': 'g',
                          'calories': item.kcal,
                          'protein_g': item.protein,
                          'carbs_g': item.carbs,
                          'fat_g': item.fat,
                        };
                        await provider.postNutritionLog(body);
                      }
                      if (mounted) {
                        setState(() => _loggedItems.clear());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$selectedMeal saved!'),
                            backgroundColor: Colors.green.shade700,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text('Save Meal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

// ── Food Row with separate card tap and + tap ─────────────────────────────────

class _FoodRow extends StatelessWidget {
  final Map<String, dynamic> foodData;
  final VoidCallback onCardTap;  // whole card → food detail
  final VoidCallback onAddTap;   // + button → quick-add sheet
  final bool showBrand;

  const _FoodRow({
    required this.foodData,
    required this.onCardTap,
    required this.onAddTap,
    this.showBrand = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = foodData['name'] as String? ?? '';
    final brand = foodData['brand'] as String? ?? '';
    final calories = (foodData['calories'] as num?)?.toDouble() ?? 0.0;
    final protein = (foodData['protein_g'] as num?)?.toDouble() ?? 0.0;

    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showBrand && brand.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(brand,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(
                                color: Colors.white.withAlpha(102),
                                fontSize: 11)),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${calories.round()} kcal  •  '
                    '${protein.toStringAsFixed(1)}g protein',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withAlpha(128)),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: protein > 0
                          ? (protein / 50).clamp(0.0, 1.0)
                          : 0,
                      backgroundColor: Colors.white.withAlpha(26),
                      color: const Color(0xFF4A90E2),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // + button — does NOT navigate; opens quick-add sheet
            GestureDetector(
              onTap: onAddTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A90E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
