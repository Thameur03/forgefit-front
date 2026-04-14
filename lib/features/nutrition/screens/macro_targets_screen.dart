import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MacroTargetsScreen extends StatefulWidget {
  const MacroTargetsScreen({super.key});

  @override
  State<MacroTargetsScreen> createState() => _MacroTargetsScreenState();
}

class _MacroTargetsScreenState extends State<MacroTargetsScreen> {
  double _calorieGoal = 2600;
  // Internal pct values stored as 0–100 range for easier slider math
  double _proteinPct = 27.7;
  double _carbsPct = 46.2;
  double _fatPct = 27.7;
  bool _isSaving = false;

  /// Tracks which macros are locked (pinned)
  final Set<String> _locked = {};

  bool get proteinLocked => _locked.contains('protein');
  bool get carbsLocked => _locked.contains('carbs');
  bool get fatLocked => _locked.contains('fat');

  static const Color _proteinColor = Color(0xFF4A90E2);
  static const Color _carbsColor = Color(0xFFF5A623);
  static const Color _fatColor = Color(0xFF50C878);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _calorieGoal = prefs.getDouble('macro_calorie_goal') ?? 2600;
      // Stored as 0–1, convert to 0–100
      _proteinPct = (prefs.getDouble('macro_protein_pct') ?? 0.277) * 100;
      _carbsPct = (prefs.getDouble('macro_carbs_pct') ?? 0.462) * 100;
      _fatPct = (prefs.getDouble('macro_fat_pct') ?? 0.277) * 100;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('macro_calorie_goal', _calorieGoal);
    // Store back as 0–1
    await prefs.setDouble('macro_protein_pct', _proteinPct / 100);
    await prefs.setDouble('macro_carbs_pct', _carbsPct / 100);
    await prefs.setDouble('macro_fat_pct', _fatPct / 100);
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
    }
  }

  // ── Computed gram/kcal values ───────────────────────────────────────────────

  int get _proteinGrams => (_calorieGoal * (_proteinPct / 100) / 4).round();
  int get _carbsGrams => (_calorieGoal * (_carbsPct / 100) / 4).round();
  int get _fatGrams => (_calorieGoal * (_fatPct / 100) / 9).round();

  int get _proteinPctInt => _proteinPct.round();
  int get _carbsPctInt => _carbsPct.round();
  int get _fatPctInt => _fatPct.round();
  int get _totalPct => _proteinPctInt + _carbsPctInt + _fatPctInt;
  bool get _isTotalValid => _totalPct == 100;

  // ── Lock toggle ─────────────────────────────────────────────────────────────

  void _toggleLock(String macroKey) {
    if (_locked.contains(macroKey)) {
      setState(() => _locked.remove(macroKey));
    } else {
      if (_locked.length >= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'At least one macro must stay unlocked to redistribute.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      setState(() => _locked.add(macroKey));
    }
  }

  // ── Slider helpers ──────────────────────────────────────────────────────────

  double _getPct(String macro) {
    if (macro == 'protein') return _proteinPct;
    if (macro == 'carbs') return _carbsPct;
    return _fatPct;
  }

  void _setPct(String macro, double val) {
    final clamped = val.clamp(0.0, 60.0);
    if (macro == 'protein') {
      _proteinPct = clamped;
    } else if (macro == 'carbs') {
      _carbsPct = clamped;
    } else {
      _fatPct = clamped;
    }
  }

  // ── Redistribution logic ────────────────────────────────────────────────────

  void _onSliderChanged(String changed, double newPct) {
    setState(() {
      // Free macros: not locked AND not the one being changed
      final free = ['protein', 'carbs', 'fat']
          .where((m) => m != changed && !_locked.contains(m))
          .toList();

      if (free.isEmpty) return;

      _setPct(changed, newPct);

      // Sum of all locked macros + the changed one
      final fixed =
          _locked.fold(0.0, (sum, m) => sum + _getPct(m)) + newPct;
      final remaining = (100.0 - fixed).clamp(0.0, 100.0);

      if (free.length == 1) {
        _setPct(free[0], remaining);
      } else {
        // Two free macros — redistribute proportionally
        final freeSum = free.fold(0.0, (sum, m) => sum + _getPct(m));
        if (freeSum == 0) {
          for (final m in free) {
            _setPct(m, remaining / free.length);
          }
        } else {
          for (final m in free) {
            _setPct(m, remaining * (_getPct(m) / freeSum));
          }
        }
      }
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Macro Targets'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
              child: const Text('Save',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Daily calorie goal ────────────────────────────
                Text(
                  'DAILY CALORIE GOAL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withAlpha(128),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                            text: _calorieGoal.round().toString(),
                          )..selection = TextSelection.collapsed(
                              offset:
                                  _calorieGoal.round().toString().length),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (v) {
                            final parsed = double.tryParse(v);
                            if (parsed != null && parsed > 0) {
                              setState(() => _calorieGoal = parsed);
                            }
                          },
                        ),
                      ),
                      Text(
                        'kcal',
                        style: TextStyle(
                          color: Colors.white.withAlpha(102),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adjusting this updates macro gram targets automatically based on percentages.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(102),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Macro sliders ─────────────────────────────────
                _MacroSliderCard(
                  label: 'Protein',
                  badge: 'High Priority',
                  badgeColor: _proteinColor,
                  color: _proteinColor,
                  grams: _proteinGrams,
                  kcal: (_proteinGrams * 4),
                  pct: _proteinPct,
                  locked: proteinLocked,
                  onLockToggle: () => _toggleLock('protein'),
                  onChanged: (v) => _onSliderChanged('protein', v),
                ),
                const SizedBox(height: 12),
                _MacroSliderCard(
                  label: 'Carbohydrates',
                  badge: 'Moderate',
                  badgeColor: _carbsColor,
                  color: _carbsColor,
                  grams: _carbsGrams,
                  kcal: (_carbsGrams * 4),
                  pct: _carbsPct,
                  locked: carbsLocked,
                  onLockToggle: () => _toggleLock('carbs'),
                  onChanged: (v) => _onSliderChanged('carbs', v),
                ),
                const SizedBox(height: 12),
                _MacroSliderCard(
                  label: 'Fats',
                  badge: 'Standard',
                  badgeColor: Colors.grey,
                  color: _fatColor,
                  grams: _fatGrams,
                  kcal: (_fatGrams * 9),
                  pct: _fatPct,
                  locked: fatLocked,
                  onLockToggle: () => _toggleLock('fat'),
                  onChanged: (v) => _onSliderChanged('fat', v),
                ),
              ],
            ),
          ),

          // ── Sticky bottom summary bar ─────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border:
                  Border(top: BorderSide(color: Colors.white.withAlpha(26))),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL MACROS',
                  style: TextStyle(
                    color: Colors.white.withAlpha(128),
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '$_totalPct%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isTotalValid
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _isTotalValid ? Colors.green : Colors.red,
                      size: 22,
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Remaining',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                        Text(
                          '${(100 - _totalPct).abs()}%',
                          style:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Three-color macro bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        Flexible(
                          flex: _proteinPctInt.clamp(0, 100),
                          child: Container(color: _proteinColor),
                        ),
                        Flexible(
                          flex: _carbsPctInt.clamp(0, 100),
                          child: Container(color: _carbsColor),
                        ),
                        Flexible(
                          flex: _fatPctInt.clamp(0, 100),
                          child: Container(color: _fatColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _LegendDot(color: _proteinColor, label: 'PROTEIN'),
                    _LegendDot(color: _carbsColor, label: 'CARBS'),
                    _LegendDot(color: _fatColor, label: 'FAT'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Macro Slider Card ─────────────────────────────────────────────────────────

class _MacroSliderCard extends StatelessWidget {
  final String label;
  final String badge;
  final Color badgeColor;
  final Color color;
  final int grams;
  final int kcal;
  final double pct; // 0–100
  final bool locked;
  final VoidCallback onLockToggle;
  final ValueChanged<double> onChanged;

  const _MacroSliderCard({
    required this.label,
    required this.badge,
    required this.badgeColor,
    required this.color,
    required this.grams,
    required this.kcal,
    required this.pct,
    required this.locked,
    required this.onLockToggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pctInt = pct.round();
    final sliderColor = locked ? Colors.grey : color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: locked
              ? Colors.white.withAlpha(50)
              : Colors.white.withAlpha(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: sliderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: locked
                          ? Colors.white.withAlpha(153)
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$grams ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: locked
                                ? Colors.white.withAlpha(153)
                                : Colors.white,
                          ),
                        ),
                        const TextSpan(
                          text: 'g',
                          style: TextStyle(
                              fontSize: 14, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$kcal kcal',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              // ── Lock button ──────────────────────────────────────
              IconButton(
                icon: Icon(
                  locked ? Icons.lock : Icons.lock_open,
                  size: 18,
                  color: locked
                      ? theme.colorScheme.primary
                      : Colors.grey,
                ),
                onPressed: onLockToggle,
                tooltip: locked ? 'Unlock macro' : 'Lock macro',
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: sliderColor,
              inactiveTrackColor: locked
                  ? Colors.white.withAlpha(20)
                  : Colors.white.withAlpha(40),
              thumbColor: locked ? Colors.grey.shade400 : Colors.white,
              overlayColor: sliderColor.withAlpha(40),
              trackHeight: 4,
              // Hide thumb when locked for cleaner visual
              thumbShape: locked
                  ? const RoundSliderThumbShape(enabledThumbRadius: 6)
                  : const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: pct,
              min: 5,
              max: 60,
              divisions: 55,
              // null onChanged = greyed out automatically by Flutter
              onChanged: locked ? null : onChanged,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (locked) ...[
                  Icon(
                    Icons.lock,
                    size: 12,
                    color: theme.colorScheme.primary.withAlpha(180),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  '$pctInt%',
                  style: TextStyle(
                    color: sliderColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white54),
        ),
      ],
    );
  }
}
