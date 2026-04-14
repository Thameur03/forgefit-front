import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';

class PhysicalMetricsScreen extends StatefulWidget {
  const PhysicalMetricsScreen({super.key});

  @override
  State<PhysicalMetricsScreen> createState() => _PhysicalMetricsScreenState();
}

class _PhysicalMetricsScreenState extends State<PhysicalMetricsScreen> {
  // ── Weight state ───────────────────────────────────────────────────────────
  bool _weightInKg = true;
  double _weightKg = 75.0;

  final _weightCtrl = TextEditingController();
  final _weightFocus = FocusNode();

  // ── Height state ───────────────────────────────────────────────────────────
  bool _heightInCm = true;
  double _heightCm = 170.0;

  final _heightCtrl = TextEditingController();
  final _heightFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final op = context.read<OnboardingProvider>();
    if (op.weightKg > 0) _weightKg = op.weightKg;
    if (op.heightCm > 0) _heightCm = op.heightCm;

    _updateWeightCtrl();
    _updateHeightCtrl();

    _weightFocus.addListener(() {
      if (!_weightFocus.hasFocus) _updateWeightCtrl();
    });
    _heightFocus.addListener(() {
      if (!_heightFocus.hasFocus) _updateHeightCtrl();
    });
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _weightFocus.dispose();
    _heightCtrl.dispose();
    _heightFocus.dispose();
    super.dispose();
  }

  // ── Weight Logic ───────────────────────────────────────────────────────────
  void _updateWeightCtrl() {
    double w = _weightInKg ? _weightKg : (_weightKg * 2.20462);
    _weightCtrl.text = w.toStringAsFixed(1).replaceAll('.0', '').replaceAll('.', ',');
  }

  void _onWeightChanged(String val) {
    if (val.trim().isEmpty) return;
    double? parsed = double.tryParse(val.replaceAll(',', '.'));
    if (parsed == null) return;
    
    setState(() {
      if (_weightInKg) {
        _weightKg = parsed.clamp(20, 300);
      } else {
        _weightKg = (parsed / 2.20462).clamp(20, 300);
      }
    });
  }

  void _changeWeight(int delta) {
    setState(() {
      if (_weightInKg) {
        _weightKg = (_weightKg + delta).clamp(20, 300);
      } else {
        _weightKg = (_weightKg + delta / 2.20462).clamp(20, 300);
      }
      _updateWeightCtrl();
    });
  }

  // ── Height Logic ───────────────────────────────────────────────────────────
  void _updateHeightCtrl() {
    if (_heightInCm) {
      _heightCtrl.text = _heightCm.toStringAsFixed(1).replaceAll('.0', '').replaceAll('.', ',');
    } else {
      double totalInches = _heightCm / 2.54;
      int feet = (totalInches / 12).floor();
      int inches = (totalInches % 12).round();
      if (inches == 12) {
        feet += 1;
        inches = 0;
      }
      _heightCtrl.text = '$feet,$inches';
    }
  }

  void _onHeightChanged(String val) {
    if (val.trim().isEmpty) return;
    String normalized = val.replaceAll(',', '.');
    
    if (_heightInCm) {
      double? parsed = double.tryParse(normalized);
      if (parsed == null) return;
      setState(() {
        _heightCm = parsed.clamp(50, 300);
      });
    } else {
      // Parse as feet.inches
      List<String> parts = normalized.split('.');
      int feet = 0;
      int inches = 0;
      if (parts.isNotEmpty) {
        feet = int.tryParse(parts[0]) ?? 0;
        if (parts.length > 1) {
          inches = int.tryParse(parts[1]) ?? 0;
        }
      }
      setState(() {
        _heightCm = ((feet * 12 + inches) * 2.54).clamp(50, 300);
      });
    }
  }

  void _changeHeight(int delta) {
    setState(() {
      if (_heightInCm) {
        _heightCm = (_heightCm + delta).clamp(50, 300);
      } else {
        _heightCm = (_heightCm + delta * 2.54).clamp(50, 300);
      }
      _updateHeightCtrl();
    });
  }

  void _next() {
    final op = context.read<OnboardingProvider>();
    op.weightKg = _weightKg;
    op.heightCm = _heightCm;
    Navigator.pushNamed(context, '/fitness-level');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              OnboardingHeader(current: 3, total: 5),
              const SizedBox(height: 16),
              OnboardingProgressBar(current: 3, total: 5),
              const SizedBox(height: 32),

              const Text(
                'What are your physical\nmetrics?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This helps us personalize your fitness plan\nand calculate your BMI accurately.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13.5,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 28),

              // ── Weight card ──────────────────────────────────────────────
              _MetricCard(
                label: 'Weight',
                controller: _weightCtrl,
                focusNode: _weightFocus,
                onChanged: _onWeightChanged,
                unit: _weightInKg ? 'kg' : 'lbs',
                leftUnitLabel: 'kg',
                rightUnitLabel: 'lbs',
                isLeftSelected: _weightInKg,
                onToggle: (isLeft) {
                  setState(() => _weightInKg = isLeft);
                  _updateWeightCtrl();
                },
                onIncrement: () => _changeWeight(1),
                onDecrement: () => _changeWeight(-1),
              ),
              const SizedBox(height: 16),

              // ── Height card ──────────────────────────────────────────────
              _MetricCard(
                label: 'Height',
                controller: _heightCtrl,
                focusNode: _heightFocus,
                onChanged: _onHeightChanged,
                unit: _heightInCm ? 'cm' : 'ft in',
                leftUnitLabel: 'cm',
                rightUnitLabel: 'ft',
                isLeftSelected: _heightInCm,
                onToggle: (isLeft) {
                  setState(() => _heightInCm = isLeft);
                  _updateHeightCtrl();
                },
                onIncrement: () => _changeHeight(1),
                onDecrement: () => _changeHeight(-1),
              ),
              const SizedBox(height: 28),

               OnboardingPulseButton(
                label: 'Next',
                onPressed: _next,
              ),
              const SizedBox(height: 14),

               Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: OnboardingTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: OnboardingTheme.border),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: OnboardingTheme.accent, size: 17),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your metrics are kept private and only used to improve your exercise recommendations.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final String unit;
  final String leftUnitLabel;
  final String rightUnitLabel;
  final bool isLeftSelected;
  final ValueChanged<bool> onToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _MetricCard({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.unit,
    required this.leftUnitLabel,
    required this.rightUnitLabel,
    required this.isLeftSelected,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = OnboardingTheme.accent;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _UnitToggle(
                leftLabel: leftUnitLabel,
                rightLabel: rightUnitLabel,
                isLeftSelected: isLeftSelected,
                onToggle: onToggle,
                accentColor: accentColor,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _CircleButton(
                  icon: Icons.remove,
                  onTap: () {
                    focusNode.unfocus();
                    onDecrement();
                  },
                  accentColor: accentColor,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      IntrinsicWidth(
                        child: TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          onChanged: onChanged,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        unit,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _CircleButton(
                  icon: Icons.add,
                  onTap: () {
                    focusNode.unfocus();
                    onIncrement();
                  },
                  accentColor: accentColor,
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final bool isLeftSelected;
  final ValueChanged<bool> onToggle;
  final Color accentColor;

  const _UnitToggle({
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftSelected,
    required this.onToggle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: leftLabel,
            selected: isLeftSelected,
            accentColor: accentColor,
            onTap: () => onToggle(true),
            isLeft: true,
          ),
          _ToggleChip(
            label: rightLabel,
            selected: !isLeftSelected,
            accentColor: accentColor,
            onTap: () => onToggle(false),
            isLeft: false,
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isLeft;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(8) : Radius.zero,
            right: !isLeft ? const Radius.circular(8) : Radius.zero,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white38,
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: accentColor.withAlpha(30),
          shape: BoxShape.circle,
          border: Border.all(color: accentColor.withAlpha(80)),
        ),
        child: Icon(icon, color: accentColor, size: 20),
      ),
    );
  }
}
