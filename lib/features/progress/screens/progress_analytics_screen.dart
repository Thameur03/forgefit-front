import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/widgets/onboarding_widgets.dart';
import '../../nutrition/providers/nutrition_stats_provider.dart';
import '../../nutrition/screens/nutrition_stats_screen.dart';
import '../../progress/providers/progress_provider.dart';
import '../../progress/screens/stats_screen.dart';
import '../providers/ai_coach_provider.dart';
import 'ai_coach_screen.dart';

// ── Unified Progress & Analytics Screen ─────────────────────────────────────
// Hosts Workout and Nutrition analytics behind an internal segmented tab.
// This is the entry point from Profile → Progress & Analytics.

enum _AnalyticsTab { workout, nutrition, labInsights }

class ProgressAnalyticsScreen extends StatefulWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  State<ProgressAnalyticsScreen> createState() =>
      _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends State<ProgressAnalyticsScreen> {
  _AnalyticsTab _tab = _AnalyticsTab.workout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pre-load workout analytics on open (default tab)
      context.read<ProgressProvider>().loadProgressAnalytics();
      // Pre-load nutrition stats silently so switching feels instant
      final np = context.read<NutritionStatsProvider>();
      if (np.stats == null && !np.isLoading) {
        np.loadStats();
      }
      // Pre-load AI coach data
      context.read<AICoachProvider>().loadSummary(days: 7);
    });
  }

  // ── Design helpers ──────────────────────────────────────────────────────

  Widget _iconBtn(IconData icon, VoidCallback onTap, {double iconSize = 20}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: OnboardingTheme.border),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }

  // ── Segmented tab control ────────────────────────────────────────────────

  Widget _tabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tabButton('Workout', _AnalyticsTab.workout,
              Icons.fitness_center_rounded),
          const SizedBox(width: 4),
          _tabButton('Nutrition', _AnalyticsTab.nutrition,
              Icons.restaurant_menu_rounded),
          const SizedBox(width: 4),
          _tabButton('Insights', _AnalyticsTab.labInsights,
              Icons.insights_rounded),
        ],
      ),
    );
  }

  Widget _tabButton(String label, _AnalyticsTab tab, IconData icon) {
    final selected = _tab == tab;
    return GestureDetector(
      onTap: () => setState(() => _tab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? OnboardingTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 15,
                color: selected ? Colors.white : Colors.white38),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontSize: 14,
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _iconBtn(
                    Icons.arrow_back_ios_new_rounded,
                    () => Navigator.pop(context),
                    iconSize: 18,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Progress & Analytics',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // ── Segmented tab bar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_tabBar()],
              ),
            ),

            // ── Content (IndexedStack preserves state) ─────────────
            Expanded(
              child: IndexedStack(
                index: _tab.index,
                children: [
                  const WorkoutStatsContent(),
                  const NutritionStatsContent(),
                  const AICoachContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
