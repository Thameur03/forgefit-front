import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';

class FitnessLevelScreen extends StatefulWidget {
  const FitnessLevelScreen({super.key});

  @override
  State<FitnessLevelScreen> createState() => _FitnessLevelScreenState();
}

class _FitnessLevelScreenState extends State<FitnessLevelScreen> {
  String _selectedLevel = 'Intermediate';

  static const _levels = [
    _FitnessLevel(
      title: 'Beginner',
      description: 'New to training or returning after a long break.',
    ),
    _FitnessLevel(
      title: 'Intermediate',
      description: 'You train regularly and understand basic exercises.',
    ),
    _FitnessLevel(
      title: 'Advanced',
      description: 'Experienced with structured training and progressive overload.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final op = context.read<OnboardingProvider>();
    if (op.fitnessLevel.isNotEmpty) {
      _selectedLevel = op.fitnessLevel;
    }
  }

  void _continue() {
    final op = context.read<OnboardingProvider>();
    op.fitnessLevel = _selectedLevel;
    Navigator.pushNamed(context, '/profile-summary');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              OnboardingHeader(current: 4, total: 5),
              const SizedBox(height: 16),
              OnboardingProgressBar(current: 4, total: 5),
              const SizedBox(height: 36),

              // ── Icon ──────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: OnboardingTheme.cardAlt,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: OnboardingTheme.accent.withAlpha(60),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: OnboardingTheme.accent,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              const Text(
                "What's your fitness\nlevel?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This helps us recommend workouts that\nmatch your experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13.5,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 28),

              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _levels.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final level = _levels[i];
                    final selected = level.title == _selectedLevel;
                    return _LevelCard(
                      title: level.title,
                      description: level.description,
                      selected: selected,
                      onTap: () => setState(() => _selectedLevel = level.title),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              OnboardingPulseButton(
                label: 'Continue',
                onPressed: _continue,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FitnessLevel {
  final String title;
  final String description;
  const _FitnessLevel({required this.title, required this.description});
}

class _LevelCard extends StatefulWidget {
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const accentColor = OnboardingTheme.accent;
    const cardColor = OnboardingTheme.card;
    const cardBorder = OnboardingTheme.border;

    final scale = _isPressed ? 0.97 : (widget.selected ? 1.02 : 1.0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: widget.selected ? accentColor.withAlpha(20) : cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.selected ? accentColor : cardBorder,
              width: widget.selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.selected) ...[
                const SizedBox(width: 12),
                const Icon(
                  Icons.check_circle_outline,
                  color: accentColor,
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
