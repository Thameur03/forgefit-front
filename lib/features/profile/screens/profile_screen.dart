import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../../progress/providers/stats_provider.dart';
import '../../progress/screens/stats_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stats = context.read<StatsProvider>();
      if (stats.currentStreakDays == 0) {
        stats.loadWorkoutStats();
      }
    });
  }

  String _initials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '?';
    final words = fullName.trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final stats = context.watch<StatsProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page title ────────────────────────────────────────────────
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // ── Section 1 — Identity Card ─────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: OnboardingTheme.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    // Gradient avatar
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            OnboardingTheme.gradientStart,
                            OnboardingTheme.gradientEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _initials(user?.fullName),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? '—',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Edit Profile — InkWell so ripple respects border radius
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () =>
                            Navigator.pushNamed(context, '/profile/edit'),
                        child: Container(
                          height: 44,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: OnboardingTheme.accent,
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: OnboardingTheme.accent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Section 2 — Stats Chips ──────────────────────────────────
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Chip 1 — Streak
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: OnboardingTheme.cardDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 22,
                            color: OnboardingTheme.accent,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stats.currentStreakDays}d',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Streak',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Chip 2 — Workouts
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: OnboardingTheme.cardDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.fitness_center_rounded,
                            size: 22,
                            color: OnboardingTheme.success,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            // TODO: replace with StatsProvider.totalWorkouts when available
                            '—',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Workouts',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Section 3 — Progress & Analytics ──────────────────────────
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StatsScreen(),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 18),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: OnboardingTheme.accent
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            color: OnboardingTheme.accent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progress & Analytics',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Volume, streaks, muscle map',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white38,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Section 4 — Logout ────────────────────────────────────────
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => _handleLogout(context),
                  child: Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: OnboardingTheme.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: OnboardingTheme.danger,
                        width: 1.5,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: OnboardingTheme.danger,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: OnboardingTheme.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OnboardingTheme.cardDark,
        title: const Text(
          'Log Out?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: OnboardingTheme.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', (_) => false);
      }
    }
  }
}
