import 'package:flutter/material.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_gif_widget.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final ExerciseResult? exercise;
  final String fallbackName;

  const ExerciseDetailScreen({
    super.key,
    this.exercise,
    this.fallbackName = 'Exercise Details',
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with TickerProviderStateMixin {
  // Staggered animation controllers
  late AnimationController _gifController;
  late AnimationController _infoController;
  late AnimationController _musclesController;
  late AnimationController _instructionsController;
  late AnimationController _footerController;

  late Animation<double> _gifFade;
  late Animation<Offset> _infoSlide;
  late Animation<double> _infoFade;
  late Animation<Offset> _musclesSlide;
  late Animation<double> _musclesFade;
  late Animation<Offset> _instructionsSlide;
  late Animation<double> _instructionsFade;
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _gifController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _gifFade =
        CurvedAnimation(parent: _gifController, curve: Curves.easeIn);

    _infoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _infoFade =
        CurvedAnimation(parent: _infoController, curve: Curves.easeIn);
    _infoSlide = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _infoController, curve: Curves.easeOut));

    _musclesController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _musclesFade =
        CurvedAnimation(parent: _musclesController, curve: Curves.easeIn);
    _musclesSlide = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _musclesController, curve: Curves.easeOut));

    _instructionsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _instructionsFade = CurvedAnimation(
        parent: _instructionsController, curve: Curves.easeIn);
    _instructionsSlide = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _instructionsController, curve: Curves.easeOut));

    _footerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _footerFade =
        CurvedAnimation(parent: _footerController, curve: Curves.easeIn);
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _gifController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _infoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _musclesController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _instructionsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _footerController.forward();
    });
  }

  @override
  void dispose() {
    _gifController.dispose();
    _infoController.dispose();
    _musclesController.dispose();
    _instructionsController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1)}';
    }).join(' ');
  }

  String _cleanStep(String s) {
    return s.replaceFirst(RegExp(r'^Step:\d+\s*'), '');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exercise == null) {
      return Scaffold(
        backgroundColor: OnboardingTheme.bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const Expanded(
                child: Center(
                  child: Text(
                    'No additional details available.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final ex = widget.exercise!;

    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // SECTION 1: GIF
                    FadeTransition(
                      opacity: _gifFade,
                      child: Container(
                        height: 280,
                        decoration: const BoxDecoration(
                          color: OnboardingTheme.cardDark,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(20)),
                        ),
                        child: ExerciseGifWidget(
                          gifUrl: ex.gifUrl,
                          height: 280,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // SECTION 2: Name + quick info
                    FadeTransition(
                      opacity: _infoFade,
                      child: SlideTransition(
                        position: _infoSlide,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _capitalize(ex.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final bp in ex.bodyParts)
                                    _quickChip(_capitalize(bp), true),
                                  for (final eq in ex.equipment)
                                    _quickChip(_capitalize(eq), false),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 3: Muscles Worked
                    FadeTransition(
                      opacity: _musclesFade,
                      child: SlideTransition(
                        position: _musclesSlide,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: OnboardingTheme.cardDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: OnboardingTheme.cardMid),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Muscles Worked',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                if (ex.targetMuscles.isNotEmpty) ...[
                                  Text(
                                    'PRIMARY',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(100),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: ex.targetMuscles
                                        .map((m) =>
                                            _muscleChip(_capitalize(m), true))
                                        .toList(),
                                  ),
                                ],
                                if (ex.secondaryMuscles.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Text(
                                    'SECONDARY',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(100),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: ex.secondaryMuscles
                                        .map((m) =>
                                            _muscleChip(_capitalize(m), false))
                                        .toList(),
                                  ),
                                ],
                                if (ex.targetMuscles.isEmpty &&
                                    ex.secondaryMuscles.isEmpty)
                                  const Text('—',
                                      style:
                                          TextStyle(color: Colors.white38)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SECTION 4: Instructions
                    if (ex.instructions.isNotEmpty)
                      FadeTransition(
                        opacity: _instructionsFade,
                        child: SlideTransition(
                          position: _instructionsSlide,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: OnboardingTheme.cardDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: OnboardingTheme.cardMid),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'How To Perform',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...ex.instructions
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final text = _cleanStep(entry.value);
                                    final isLast = index ==
                                        ex.instructions.length - 1;

                                    return Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: const BoxDecoration(
                                                color: OnboardingTheme.gradientStart,
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        top: 8),
                                                child: Text(
                                                  text,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (!isLast)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 19),
                                            child: Container(
                                              width: 2,
                                              height: 16,
                                              color: OnboardingTheme.cardMid,
                                            ),
                                          ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // SECTION 5: Footer
                    FadeTransition(
                      opacity: _footerFade,
                      child: const Center(
                        child: Text(
                          'Data provided by ExerciseDB',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.white60),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _quickChip(String label, bool isAccent) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAccent
            ? OnboardingTheme.gradientStart.withAlpha(20)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAccent
              ? OnboardingTheme.gradientStart.withAlpha(80)
              : Colors.white.withAlpha(30),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isAccent ? OnboardingTheme.gradientStart : Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _muscleChip(String label, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? OnboardingTheme.gradientStart : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isPrimary ? OnboardingTheme.gradientStart : OnboardingTheme.cardMid,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrimary ? Colors.white : Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
