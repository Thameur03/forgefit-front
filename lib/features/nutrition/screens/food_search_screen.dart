import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/nutrition_model.dart';
import 'dart:async';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    final results = await context.read<NutritionProvider>().searchFood(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _showAddFoodDialog(Map<String, dynamic> food) {
    String selectedMealType = 'Snack';
    final amountController = TextEditingController(text: '100');
    bool isSaving = false;

    // Use a StatefulBuilder to manage state inside the dialog
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: Text(food['name'] ?? 'Unknown Food'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Per 100g: ${(food['calories'] ?? 0)} kcal • P: ${food['protein_g'] ?? 0}g C: ${food['carbs_g'] ?? 0}g F: ${food['fat_g'] ?? 0}g',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedMealType,
                    decoration: const InputDecoration(
                      labelText: 'Meal',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => selectedMealType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount (g)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        setStateDialog(() => isSaving = true);
                        
                        final amount = double.tryParse(amountController.text) ?? 100;
                        final ratio = amount / 100; // Assuming API returns per 100g

                        final model = NutritionModel(
                          id: '',
                          foodName: food['name'] ?? 'Unknown',
                          consumedAt: DateTime.now(),
                          mealType: selectedMealType,
                          amount: amount,
                          unit: 'g',
                          calories: ((food['calories'] ?? 0) * ratio).round(),
                          protein: ((food['protein_g'] ?? 0.0) * ratio),
                          carbs: ((food['carbs_g'] ?? 0.0) * ratio),
                          fat: ((food['fat_g'] ?? 0.0) * ratio),
                        );

                        final success = await context
                            .read<NutritionProvider>()
                            .logFood(model);

                        if (success && context.mounted) {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Go back to nutrition screen
                        } else {
                          setStateDialog(() => isSaving = false);
                          // Show error
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator())
                    : const Text('Add Food'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search food...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty && _searchController.text.isNotEmpty
              ? const Center(child: Text('No results found'))
              : _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: theme.colorScheme.onSurface.withAlpha(51),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search the USDA database',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(153),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withAlpha(26),
                      ),
                      itemBuilder: (context, index) {
                        final food = _searchResults[index];
                        return ListTile(
                          title: Text(food['name'] ?? 'Unknown'),
                          subtitle: Text(
                            '${food['calories'] ?? 0} kcal | P: ${food['protein_g'] ?? 0}g C: ${food['carbs_g'] ?? 0}g F: ${food['fat_g'] ?? 0}g (per 100g)',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withAlpha(153),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () => _showAddFoodDialog(food),
                          ),
                          onTap: () => _showAddFoodDialog(food),
                        );
                      },
                    ),
    );
  }
}
