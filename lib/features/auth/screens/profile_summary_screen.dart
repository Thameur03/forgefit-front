import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/onboarding_widgets.dart';

class ProfileSummaryScreen extends StatefulWidget {
  const ProfileSummaryScreen({super.key});

  @override
  State<ProfileSummaryScreen> createState() => _ProfileSummaryScreenState();
}

class _ProfileSummaryScreenState extends State<ProfileSummaryScreen>
    with TickerProviderStateMixin {
  // ── Staggered row fade-in ────────────────────────────────────────────────
  static const int _rowCount = 7;
  late final AnimationController _stagger;
  late final List<Animation<double>> _fadeAnims;

  // ── Get Started button state ─────────────────────────────────────────────
  bool _success = false;

  @override
  void initState() {
    super.initState();

    // Total stagger: 7 rows × 100 ms apart, each row fades over 250 ms
    // Controller span = 700 ms + 250 ms = 950 ms
    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _fadeAnims = List.generate(_rowCount, (i) {
      final start = i * 0.105;          // 100 ms between rows (100/950 ≈ 0.105)
      final end = (start + 0.263).clamp(0.0, 1.0); // 250 ms fade (250/950)
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _stagger,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _stagger.forward();
  }

  @override
  void dispose() {
    _stagger.dispose();
    super.dispose();
  }

  Future<void> _getStarted() async {
    final op = context.read<OnboardingProvider>();
    final auth = context.read<AuthProvider>();

    op.clearError();
    final success = await op.register(auth);

    if (!mounted) return;

    if (success) {
      setState(() => _success = true);
      op.reset();

      // Short delay to show checkmark
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      // Beta: email verification is disabled — navigate to login with success message.
      // EmailVerificationScreen is intentionally NOT navigated to during beta.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please log in.'),
          backgroundColor: Color(0xFF3B82F6),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (r) => false,
      );
    }
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

              OnboardingHeader(current: 5, total: 5),
              const SizedBox(height: 16),

              OnboardingProgressBar(current: 5, total: 5),
              const SizedBox(height: 32),

              // ── Heading ────────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnims[0],
                child: const Column(
                  children: [
                    Text(
                      'Your Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Everything looks good — we\'re\nready to personalize your journey.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Summary card ───────────────────────────────────────────
              Consumer<OnboardingProvider>(
                builder: (context, op, child) {
                  final rows = [
                    _SummaryRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: op.email.isNotEmpty ? op.email : '—',
                      animation: _fadeAnims[1],
                      onTap: () => Navigator.pushNamed(context, '/register'),
                    ),
                    _SummaryRow(
                      icon: Icons.person_outline,
                      label: 'Full Name',
                      value: op.fullName.isNotEmpty ? op.fullName : '—',
                      animation: _fadeAnims[2],
                      onTap: () => Navigator.pushNamed(context, '/personal-info'),
                    ),
                    _SummaryRow(
                      icon: Icons.cake_outlined,
                      label: 'Date of Birth',
                      value: op.dateOfBirth.isNotEmpty ? op.dateOfBirth : '—',
                      animation: _fadeAnims[3],
                      onTap: () => Navigator.pushNamed(context, '/personal-info'),
                    ),
                    _SummaryRow(
                      icon: Icons.people_outline,
                      label: 'Gender',
                      value: op.gender,
                      animation: _fadeAnims[3],
                      onTap: () => Navigator.pushNamed(context, '/personal-info'),
                    ),
                    _SummaryRow(
                      icon: Icons.height,
                      label: 'Height',
                      value: '${op.heightCm.round()} cm',
                      animation: _fadeAnims[4],
                      onTap: () => Navigator.pushNamed(context, '/physical-metrics'),
                    ),
                    _SummaryRow(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Weight',
                      value: '${op.weightKg.round()} kg',
                      animation: _fadeAnims[5],
                      onTap: () => Navigator.pushNamed(context, '/physical-metrics'),
                    ),
                    _SummaryRow(
                      icon: Icons.fitness_center,
                      label: 'Fitness Level',
                      value: op.fitnessLevel,
                      animation: _fadeAnims[6],
                      onTap: () => Navigator.pushNamed(context, '/fitness-level'),
                    ),
                  ];

                  return Container(
                    decoration: BoxDecoration(
                      color: OnboardingTheme.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: OnboardingTheme.border),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < rows.length; i++) ...[
                          rows[i],
                          if (i < rows.length - 1)
                            const Divider(
                                color: Colors.white10, height: 1),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── Error banner ───────────────────────────────────────────
              Consumer<OnboardingProvider>(
                builder: (context, op, child) {
                  if (op.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.redAccent.withAlpha(60)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.redAccent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                op.errorMessage!,
                                style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // ── Get Started button ─────────────────────────────────────
              Consumer<OnboardingProvider>(
                builder: (context, op, child) {
                  return OnboardingPulseButton(
                    label: op.errorMessage != null && !op.isLoading ? 'Retry' : 'Get Started',
                    showArrow: false,
                    isLoading: op.isLoading,
                    isSuccess: _success,
                    onPressed: _getStarted,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary row ──────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: OnboardingTheme.accent.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon,
                      color: OnboardingTheme.accent, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit, color: Colors.white38, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
