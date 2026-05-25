import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../auth/widgets/onboarding_widgets.dart';
import '../models/nutrition_stats_model.dart';
import '../providers/nutrition_stats_provider.dart';

/// Nutrition Insights screen — mirrors the design language of StatsScreen.
class NutritionStatsScreen extends StatefulWidget {
  const NutritionStatsScreen({super.key});

  @override
  State<NutritionStatsScreen> createState() => _NutritionStatsScreenState();
}

class _NutritionStatsScreenState extends State<NutritionStatsScreen> {
  static const List<int> _periods = [7, 14, 30];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<NutritionStatsProvider>();
      if (p.stats == null && !p.isLoading) {
        p.loadStats();
      }
    });
  }

  // ── Design helpers ────────────────────────────────────────────────────────

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

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      );

  Widget _card({required Widget child, EdgeInsets padding = const EdgeInsets.all(16)}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: child,
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String sub,
    Color subColor = Colors.white38,
    String? badge,
    Color badgeColor = OnboardingTheme.accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          if (badge != null)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(badge,
                  style: TextStyle(
                      color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold)),
            )
          else
            Text(sub,
                style: TextStyle(color: subColor, fontSize: 10),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _changeBadge(double pct) {
    final positive = pct >= 0;
    final color = positive ? OnboardingTheme.success : OnboardingTheme.danger;
    final label = '${positive ? '+' : ''}${pct.toStringAsFixed(1)}%';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  // ── Time range chips ─────────────────────────────────────────────────────

  Widget _periodChips(NutritionStatsProvider provider) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: _periods.map((d) {
          final selected = provider.selectedDays == d;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${d}D'),
              selected: selected,
              onSelected: (_) => provider.setSelectedDays(d),
              selectedColor: OnboardingTheme.accent,
              backgroundColor: OnboardingTheme.card,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              checkmarkColor: Colors.white,
              side: BorderSide(color: OnboardingTheme.border),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _emptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: OnboardingTheme.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: OnboardingTheme.accent, size: 36),
              ),
              const SizedBox(height: 20),
              const Text('No nutrition data yet',
                  style: TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Log meals for a few days to unlock nutrition insights.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/nutrition/add-food',
                    arguments: 'breakfast'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      OnboardingTheme.gradientStart,
                      OnboardingTheme.gradientEnd
                    ]),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text('Log Food',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        child: Consumer<NutritionStatsProvider>(
          builder: (context, provider, _) {
            final stats = provider.stats;
            final loading = provider.isLoading;
            final hasData = stats != null && stats.loggedDays > 0;

            return CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                    child: Row(
                      children: [
                        _iconBtn(Icons.arrow_back_ios_new_rounded,
                            () => Navigator.pop(context),
                            iconSize: 18),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Nutrition Insights',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        _iconBtn(Icons.refresh_rounded,
                            () => provider.loadStats(days: provider.selectedDays)),
                      ],
                    ),
                  ),
                ),

                // ── Period chips ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                    child: _periodChips(provider),
                  ),
                ),

                // ── Loading ─────────────────────────────────────────────
                if (loading && stats == null)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: OnboardingTheme.accent),
                    ),
                  )
                // ── Empty state ──────────────────────────────────────────
                else if (!hasData && !loading)
                  _emptyState()
                // ── Content ──────────────────────────────────────────────
                else if (stats != null) ...[
                  // ── 4 top metric cards ─────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _buildTopCards(stats),
                    ),
                  ),

                  // ── Macro Split card ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _buildMacroSplitCard(stats),
                    ),
                  ),

                  // ── Trend card ─────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _buildTrendCard(stats),
                    ),
                  ),

                  // ── Insights card ──────────────────────────────────────
                  if (stats.insights.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: _buildInsightsCard(stats),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ── 4 top metric cards ────────────────────────────────────────────────────

  Widget _buildTopCards(NutritionDashboardStats s) {
    final calPct = s.calorieChangePercent;

    // Protein interpretation (not medical advice)
    String proteinSub;
    if (s.proteinPerKg != null) {
      final pkg = s.proteinPerKg!;
      if (pkg < 1.2) {
        proteinSub = 'Low for active individuals';
      } else if (pkg <= 1.6) {
        proteinSub = 'Moderate intake';
      } else if (pkg <= 2.2) {
        proteinSub = 'Strong range for strength training';
      } else {
        proteinSub = 'High protein intake';
      }
    } else {
      proteinSub = 'Add body weight to unlock g/kg';
    }

    final proteinValue = s.proteinPerKg != null
        ? '${s.averageProteinG.toStringAsFixed(0)} g/day\n${s.proteinPerKg!.toStringAsFixed(1)} g/kg'
        : '${s.averageProteinG.toStringAsFixed(0)} g/day';

    final consistencyPct = s.loggingConsistencyPercent;
    final consistencyColor = consistencyPct >= 80
        ? OnboardingTheme.success
        : consistencyPct >= 50
            ? OnboardingTheme.ringOrange
            : OnboardingTheme.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calories + Protein row
        Row(
          children: [
            Expanded(
              child: _card(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Average Calories',
                        style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      '${_fmtCal(s.averageCalories)} kcal',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _changeBadge(calPct),
                        const SizedBox(width: 6),
                        Text('vs prev period',
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _card(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Protein',
                        style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      proteinValue,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.35),
                    ),
                    const SizedBox(height: 6),
                    Text(proteinSub,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 10),
                        maxLines: 2),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Logging consistency + Calorie consistency row
        Row(
          children: [
            Expanded(
              child: _metricCard(
                icon: Icons.event_available_rounded,
                iconColor: consistencyColor,
                label: 'Logging Consistency',
                value:
                    '${s.loggedDays} / ${s.periodDays} days',
                sub:
                    '${s.loggingConsistencyPercent.toStringAsFixed(0)}% of period',
                subColor: consistencyColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                icon: Icons.show_chart_rounded,
                iconColor: OnboardingTheme.ringBlue,
                label: 'Calorie Consistency',
                value: s.calorieConsistency.label,
                sub: s.calorieConsistency.coefficientOfVariation != null
                    ? 'Varies ~${(s.calorieConsistency.coefficientOfVariation! * 100).toStringAsFixed(0)}% each day'
                    : 'Log ≥3 days to unlock',
                subColor: Colors.white54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Macro Split card ──────────────────────────────────────────────────────

  Widget _buildMacroSplitCard(NutritionDashboardStats s) {
    final ms = s.macroSplit;
    final hasData =
        ms.proteinPercent + ms.carbsPercent + ms.fatPercent > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Macro Split'),
        const SizedBox(height: 12),
        _card(
          child: hasData
              ? Row(
                  children: [
                    // Donut
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 28,
                          sections: [
                            PieChartSectionData(
                              value: ms.proteinPercent,
                              color: OnboardingTheme.ringBlue,
                              radius: 18,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: ms.carbsPercent,
                              color: OnboardingTheme.ringOrange,
                              radius: 18,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: ms.fatPercent,
                              color: OnboardingTheme.ringGreen,
                              radius: 18,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Legend
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _macroLegendRow('Protein',
                              ms.proteinPercent, OnboardingTheme.ringBlue),
                          const SizedBox(height: 8),
                          _macroLegendRow('Carbs',
                              ms.carbsPercent, OnboardingTheme.ringOrange),
                          const SizedBox(height: 8),
                          _macroLegendRow('Fat',
                              ms.fatPercent, OnboardingTheme.ringGreen),
                        ],
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No macro data yet',
                        style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _macroLegendRow(String label, double pct, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13))),
        Text('${pct.toStringAsFixed(0)}%',
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── Trend card ────────────────────────────────────────────────────────────

  Widget _buildTrendCard(NutritionDashboardStats s) {
    final points = s.dailyPoints;
    final hasData = points.any((p) => p.calories > 0);

    final maxY = hasData
        ? points
                .map((p) => p.calories)
                .reduce((a, b) => a > b ? a : b) *
            1.25
        : 100.0;
    final safeMax = maxY <= 0 ? 100.0 : maxY;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionTitle('Calorie Trend'),
            const Spacer(),
            Text('${s.periodDays} days',
                style:
                    const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            children: [
              SizedBox(
                height: 140,
                child: !hasData
                    ? const Center(
                        child: Text(
                          'Log meals to see your calorie trend.',
                          style:
                              TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          maxY: safeMax,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: safeMax / 4,
                            getDrawingHorizontalLine: (_) => const FlLine(
                                color: Colors.white10, strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => OnboardingTheme.cardDark,
                              getTooltipItem: (group, _, rod, __) =>
                                  BarTooltipItem(
                                '${rod.toY.round()} kcal',
                                const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 38,
                                interval: safeMax / 4,
                                getTitlesWidget: (val, _) {
                                  if (val == 0) {
                                    return const Text('0',
                                        style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 9));
                                  }
                                  return Text(
                                    _fmtAxisCal(val),
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 9),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 20,
                                getTitlesWidget: (val, _) {
                                  final idx = val.toInt();
                                  if (idx < 0 || idx >= points.length) {
                                    return const SizedBox.shrink();
                                  }
                                  if (idx == 0 || idx == points.length - 1) {
                                    return Text(
                                      DateFormat('M/d')
                                          .format(points[idx].date),
                                      style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 9),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          barGroups: points.asMap().entries.map((e) {
                            final hasLog = e.value.calories > 0;
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.calories,
                                  color: hasLog
                                      ? OnboardingTheme.accent.withAlpha(200)
                                      : Colors.white.withAlpha(15),
                                  width: points.length <= 14 ? 14 : 8,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Insights card ─────────────────────────────────────────────────────────

  Widget _buildInsightsCard(NutritionDashboardStats s) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded,
                  color: OnboardingTheme.accent, size: 16),
              SizedBox(width: 6),
              Text('Insights',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...s.insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('·  ',
                      style: TextStyle(
                          color: OnboardingTheme.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(insight,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13, height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Format helpers ────────────────────────────────────────────────────────

  static String _fmtCal(double v) {
    if (v >= 1000) {
      return NumberFormat('#,##0').format(v.round());
    }
    return v.round().toString();
  }

  static String _fmtAxisCal(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.round().toString();
  }
}

// ── NutritionStatsContent ─────────────────────────────────────────────────────
// Body-only version — no Scaffold, no AppBar, no header row.
// Embedded inside ProgressAnalyticsScreen's IndexedStack.
// Shows partial stats when loggedDays >= 1 (not a strict empty state).

class NutritionStatsContent extends StatefulWidget {
  const NutritionStatsContent({super.key});

  @override
  State<NutritionStatsContent> createState() => _NutritionStatsContentState();
}

class _NutritionStatsContentState extends State<NutritionStatsContent> {
  static const List<int> _periods = [7, 14, 30];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<NutritionStatsProvider>();
      if (p.stats == null && !p.isLoading) {
        p.loadStats();
      }
    });
  }

  // ── Helpers (shared with _NutritionStatsScreenState) ──────────────────────

  Widget _card({required Widget child,
      EdgeInsets padding = const EdgeInsets.all(16)}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: child,
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String sub,
    Color subColor = Colors.white38,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: subColor, fontSize: 10),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _changeBadge(double pct) {
    final positive = pct >= 0;
    final color = positive ? OnboardingTheme.success : OnboardingTheme.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('${positive ? '+' : ''}${pct.toStringAsFixed(1)}%',
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _periodChips(NutritionStatsProvider provider) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: _periods.map((d) {
          final selected = provider.selectedDays == d;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${d}D'),
              selected: selected,
              onSelected: (_) => provider.setSelectedDays(d),
              selectedColor: OnboardingTheme.accent,
              backgroundColor: OnboardingTheme.card,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              checkmarkColor: Colors.white,
              side: BorderSide(color: OnboardingTheme.border),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptySliver() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: OnboardingTheme.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.restaurant_menu_rounded,
                    color: OnboardingTheme.accent, size: 30),
              ),
              const SizedBox(height: 16),
              const Text('No nutrition data yet',
                  style: TextStyle(
                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Log meals from the Nutrition tab to unlock insights.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionStatsProvider>(
      builder: (context, provider, _) {
        final stats = provider.stats;
        final loading = provider.isLoading;
        // Show partial stats whenever loggedDays >= 1; only hide at 0 days.
        final hasAnyData = stats != null &&
            (stats.loggedDays > 0 || stats.averageCalories > 0);

        return CustomScrollView(
          slivers: [
            // period chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: _periodChips(provider),
              ),
            ),

            // loading
            if (loading && stats == null)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: OnboardingTheme.accent),
                ),
              )
            // empty
            else if (!hasAnyData && !loading)
              _emptySliver()
            // content
            else if (stats != null) ...[
              // low-data hint
              if (stats.loggedDays < 3)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: OnboardingTheme.accent.withAlpha(18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: OnboardingTheme.accent.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: OnboardingTheme.accent, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You have ${stats.loggedDays} logged '
                              '${stats.loggedDays == 1 ? 'day' : 'days'}. '
                              'Log ${3 - stats.loggedDays} more for consistency analysis.',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── metric cards ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: _card(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Avg Calories',
                                    style: TextStyle(
                                        color: Colors.white54, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  '${_fmtCal(stats.averageCalories)} kcal',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Row(children: [
                                  _changeBadge(stats.calorieChangePercent),
                                  const SizedBox(width: 6),
                                  const Text('vs prev',
                                      style: TextStyle(
                                          color: Colors.white38, fontSize: 9)),
                                ]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _card(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Protein',
                                    style: TextStyle(
                                        color: Colors.white54, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  stats.proteinPerKg != null
                                      ? '${stats.averageProteinG.toStringAsFixed(0)} g\n'
                                        '${stats.proteinPerKg!.toStringAsFixed(1)} g/kg'
                                      : '${stats.averageProteinG.toStringAsFixed(0)} g/day',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: _metricCard(
                            icon: Icons.event_available_rounded,
                            iconColor: stats.loggingConsistencyPercent >= 80
                                ? OnboardingTheme.success
                                : stats.loggingConsistencyPercent >= 50
                                    ? OnboardingTheme.ringOrange
                                    : OnboardingTheme.danger,
                            label: 'Logging',
                            value: '${stats.loggedDays}/${stats.periodDays} d',
                            sub: '${stats.loggingConsistencyPercent.toStringAsFixed(0)}%',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _metricCard(
                            icon: Icons.show_chart_rounded,
                            iconColor: OnboardingTheme.ringBlue,
                            label: 'Consistency',
                            value: stats.calorieConsistency.label,
                            sub: stats.calorieConsistency
                                        .coefficientOfVariation !=
                                    null
                                ? '~${(stats.calorieConsistency.coefficientOfVariation! * 100).toStringAsFixed(0)}% daily variation'
                                : '≥3 days to unlock',
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),

              // ── macro split ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _card(
                    child: Row(children: [
                      SizedBox(
                        width: 90, height: 90,
                        child: PieChart(PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 24,
                          sections: [
                            PieChartSectionData(
                                value: stats.macroSplit.proteinPercent,
                                color: OnboardingTheme.ringBlue,
                                radius: 16, showTitle: false),
                            PieChartSectionData(
                                value: stats.macroSplit.carbsPercent,
                                color: OnboardingTheme.ringOrange,
                                radius: 16, showTitle: false),
                            PieChartSectionData(
                                value: stats.macroSplit.fatPercent,
                                color: OnboardingTheme.ringGreen,
                                radius: 16, showTitle: false),
                          ],
                        )),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _macroRow('Protein',
                                stats.macroSplit.proteinPercent,
                                OnboardingTheme.ringBlue),
                            const SizedBox(height: 6),
                            _macroRow('Carbs',
                                stats.macroSplit.carbsPercent,
                                OnboardingTheme.ringOrange),
                            const SizedBox(height: 6),
                            _macroRow('Fat',
                                stats.macroSplit.fatPercent,
                                OnboardingTheme.ringGreen),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),

              // ── calorie trend bar chart ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildTrendSliver(stats),
                ),
              ),

              // ── backend insights ─────────────────────────────────────
              if (stats.insights.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.insights_rounded,
                                color: OnboardingTheme.accent, size: 15),
                            SizedBox(width: 6),
                            Text('Insights',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 10),
                          ...stats.insights.map((insight) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('·  ',
                                        style: TextStyle(
                                            color: OnboardingTheme.accent,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(insight,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              height: 1.4)),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTrendSliver(NutritionDashboardStats s) {
    final points = s.dailyPoints;
    final hasData = points.any((p) => p.calories > 0);
    final maxY = hasData
        ? points.map((p) => p.calories).reduce((a, b) => a > b ? a : b) * 1.25
        : 100.0;
    final safeMax = maxY <= 0 ? 100.0 : maxY;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Calorie Trend',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${s.periodDays} days',
                style: const TextStyle(
                    color: Colors.white38, fontSize: 11)),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: !hasData
                ? const Center(
                    child: Text('Log meals to see calorie trend.',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 12)))
                : BarChart(BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    maxY: safeMax,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: safeMax / 3,
                      getDrawingHorizontalLine: (_) => const FlLine(
                          color: Colors.white10, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => OnboardingTheme.cardDark,
                        getTooltipItem: (group, _, rod, __) =>
                            BarTooltipItem(
                          '${rod.toY.round()} kcal',
                          const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 18,
                          getTitlesWidget: (val, _) {
                            final idx = val.toInt();
                            if (idx < 0 || idx >= points.length) {
                              return const SizedBox.shrink();
                            }
                            if (idx == 0 || idx == points.length - 1) {
                              return Text(
                                DateFormat('M/d').format(points[idx].date),
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 8),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    barGroups: points.asMap().entries.map((e) {
                      final hasLog = e.value.calories > 0;
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.calories,
                            color: hasLog
                                ? OnboardingTheme.accent.withAlpha(200)
                                : Colors.white.withAlpha(15),
                            width: points.length <= 14 ? 12 : 7,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3)),
                          ),
                        ],
                      );
                    }).toList(),
                  )),
          ),
        ],
      ),
    );
  }

  Widget _macroRow(String label, double pct, Color color) {
    return Row(children: [
      Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(
          child: Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12))),
      Text('${pct.toStringAsFixed(0)}%',
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
  }

  static String _fmtCal(double v) {
    if (v >= 1000) return NumberFormat('#,##0').format(v.round());
    return v.round().toString();
  }
}
