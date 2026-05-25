import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../models/muscle_group.dart';
import '../models/muscle_analytics_model.dart';
import '../models/muscle_volume_model.dart';
import '../providers/progress_provider.dart';
import '../widgets/muscle_map_widget.dart';
import '../widgets/muscle_insights_sheet.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PROGRESS & ANALYTICS SCREEN
// Design matches WorkoutListScreen / TodayTab language exactly.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().loadProgressAnalytics();
    });
  }

  // ── Design helpers ───────────────────────────────────────────────────────────

  /// Matches the calendar icon button in WorkoutListScreen exactly.
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

  /// Section title matching TodayTab ("Quick Start", "This Week").
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Standard app card container.
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

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        child: Consumer<ProgressProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              slivers: [
                // ── Header row — matches Workouts top bar ──────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _iconBtn(
                          Icons.refresh_rounded,
                          () => provider.loadProgressAnalytics(force: true),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Loading ────────────────────────────────────────────────
                if (provider.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: OnboardingTheme.accent),
                    ),
                  )
                else ...[
                  // ── Muscle Map card ────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _buildMuscleMapCard(context, provider),
                    ),
                  ),

                  // ── This Week ─────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _buildThisWeekSection(provider),
                    ),
                  ),

                  // ── Weekly Volume Trend ───────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _buildVolumeTrendSection(provider),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Muscle Map card ──────────────────────────────────────────────────────────
  // Fixed 290 px height so MuscleMapWidget's internal Expanded is bounded.

  Widget _buildMuscleMapCard(BuildContext context, ProgressProvider provider) {
    final muscleData = provider.muscleAnalytics.entries.map((e) {
      return MuscleVolumeModel(
        muscleGroup: e.key.painterKey,
        totalVolumeKg: e.value.currentWeekVolumeKg,
        totalSets: e.value.currentWeekSets,
        percentage: 0,
        previousVolumeKg: e.value.previousWeekVolumeKg,
        trendPercent: e.value.volumeChangePercent,
      );
    }).toList();

    return SizedBox(
      height: 290,
      child: Container(
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OnboardingTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Muscle Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tap a muscle for insights',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  // "This week" accent chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.accent.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: OnboardingTheme.accent.withAlpha(60)),
                    ),
                    child: const Text(
                      'This week',
                      style: TextStyle(
                        color: OnboardingTheme.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: OnboardingTheme.border, height: 1),
            // MuscleMapWidget fills remaining bounded space
            Expanded(
              child: MuscleMapWidget(
                muscleData: muscleData,
                onMuscleTap: (muscleKey) {
                  final group = MuscleGroupX.fromPainterKey(muscleKey);
                  if (group != null) {
                    showMuscleInsightsSheet(context, group);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── This Week section ────────────────────────────────────────────────────────

  Widget _buildThisWeekSection(ProgressProvider provider) {
    final ov = provider.overview;
    final volume = ov?.currentWeekTotalVolumeKg ?? 0;
    final prevVolume = ov?.previousWeekTotalVolumeKg ?? 0;
    final sets = ov?.currentWeekTotalSets ?? 0;
    final workouts = ov?.workoutsThisWeek ?? 0;
    final volPct = _percentChange(volume, prevVolume);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('This Week'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                icon: Icons.fitness_center_rounded,
                label: 'Volume',
                value: _fmtVol(volume),
                sub: '${volPct >= 0 ? '+' : ''}${volPct.round()}% vs last week',
                subColor: volPct >= 0
                    ? OnboardingTheme.success
                    : OnboardingTheme.danger,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                icon: Icons.repeat_rounded,
                label: 'Sets',
                value: '$sets',
                sub: 'sets logged',
                subColor: Colors.white38,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                icon: Icons.calendar_today_rounded,
                label: 'Workouts',
                value: '$workouts',
                sub: 'this week',
                subColor: Colors.white38,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Metric card — matches icon-container style from TodayTab (_buildNoProgramCard).
  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color subColor,
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
              color: OnboardingTheme.accent.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: OnboardingTheme.accent, size: 16),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(color: subColor, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Weekly Volume Trend section ──────────────────────────────────────────────

  Widget _buildVolumeTrendSection(ProgressProvider provider) {
    final trend = provider.overview?.totalVolumeTrend ?? [];
    final ov = provider.overview;
    final currentVol = ov?.currentWeekTotalVolumeKg ?? 0;
    final prevVol = ov?.previousWeekTotalVolumeKg ?? 0;
    final pct = _percentChange(currentVol, prevVol);
    final hasData = trend.any((p) => p.volumeKg > 0);
    final double maxY = hasData
        ? trend
                .map((p) => p.volumeKg)
                .reduce((a, b) => a > b ? a : b) *
            1.25
        : 100.0;
    final safeMaxY = maxY <= 0 ? 100.0 : maxY;
    final thisWeek = _mondayOfNow();
    final interpretation = _globalTrendInterpretation(pct, trend);
    final pctPositive = pct >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Weekly Volume Trend'),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sub-header row: "Last 8 weeks" + % chip
              Row(
                children: [
                  const Text(
                    'Last 8 weeks',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (pctPositive
                              ? OnboardingTheme.success
                              : OnboardingTheme.danger)
                          .withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${pctPositive ? '+' : ''}${pct.round()}%',
                      style: TextStyle(
                        color: pctPositive
                            ? OnboardingTheme.success
                            : OnboardingTheme.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Chart with explicit fixed height
              SizedBox(
                height: 130,
                child: trend.isEmpty || !hasData
                    ? const Center(
                        child: Text(
                          'Log workouts to see your volume trend.',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 12),
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          maxY: safeMaxY,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: safeMaxY / 4,
                            getDrawingHorizontalLine: (_) => const FlLine(
                                color: Colors.white10, strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) =>
                                  OnboardingTheme.cardDark,
                              getTooltipItem: (group, _, rod, __) =>
                                  BarTooltipItem(
                                _fmtVol(rod.toY),
                                const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                interval: safeMaxY / 4,
                                getTitlesWidget: (val, meta) {
                                  if (val == 0) {
                                    return const Text('0',
                                        style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 9));
                                  }
                                  return Text(
                                    _fmtAxisVol(val),
                                    style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 9),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 20,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx < 0 ||
                                      idx >= trend.length) {
                                    return const SizedBox.shrink();
                                  }
                                  if (idx == 0 ||
                                      idx == trend.length - 1) {
                                    return Text(
                                      DateFormat('M/d').format(
                                          trend[idx].weekStart),
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
                          barGroups: trend.asMap().entries.map((e) {
                            final isCurrentWeek =
                                !e.value.weekStart.isBefore(thisWeek);
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.volumeKg,
                                  color: isCurrentWeek
                                      ? OnboardingTheme.success
                                      : OnboardingTheme.accent
                                          .withAlpha(180),
                                  width: 14,
                                  borderRadius:
                                      const BorderRadius.vertical(
                                          top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),

              const SizedBox(height: 10),

              // Insight line
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.insights_rounded,
                      color: OnboardingTheme.accent, size: 13),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      interpretation,
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static DateTime _mondayOfNow() {
    final d = DateTime.now();
    final today = DateTime(d.year, d.month, d.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  static String _fmtVol(double v) {
    if (v >= 1000) {
      return '${NumberFormat('#,##0').format(v.round())} kg';
    }
    return '${v.round()} kg';
  }

  static String _fmtAxisVol(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.round().toString();
  }

  static double _percentChange(double current, double previous) {
    if (previous == 0 && current == 0) return 0;
    if (previous == 0 && current > 0) return 100;
    return ((current - previous) / previous) * 100;
  }

  static String _globalTrendInterpretation(
      double pct, List<MuscleWeeklyPoint> trend) {
    final recent = trend.where((p) => p.volumeKg > 0).toList();
    String direction = '';
    if (recent.length >= 3) {
      final last = recent.last.volumeKg;
      final mid = recent[recent.length ~/ 2].volumeKg;
      final first = recent.first.volumeKg;
      if (last > mid && mid > first) {
        direction = ' · 4-wk trend: rising';
      } else if (last < mid && mid < first) {
        direction = ' · 4-wk trend: declining';
      } else {
        direction = ' · 4-wk trend: stable';
      }
    }
    if (pct > 35) {
      return 'Volume increased sharply this week. Watch recovery.$direction';
    }
    if (pct > 10) return 'Volume is trending upward steadily.$direction';
    if (pct >= -10) {
      return 'Volume is stable compared to last week.$direction';
    }
    if (pct >= -30) return 'Volume dipped this week.$direction';
    return 'Volume dropped significantly. May be a deload or missed training.$direction';
  }
}

// ── WorkoutStatsContent ───────────────────────────────────────────────────────
// Body-only version of StatsScreen — no Scaffold/AppBar.
// Used inside ProgressAnalyticsScreen's IndexedStack.

class WorkoutStatsContent extends StatefulWidget {
  const WorkoutStatsContent({super.key});

  @override
  State<WorkoutStatsContent> createState() => _WorkoutStatsContentState();
}

class _WorkoutStatsContentState extends State<WorkoutStatsContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().loadProgressAnalytics();
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: OnboardingTheme.accent),
          );
        }

        final ov = provider.overview;
        final volume = ov?.currentWeekTotalVolumeKg ?? 0;
        final prevVolume = ov?.previousWeekTotalVolumeKg ?? 0;
        final sets = ov?.currentWeekTotalSets ?? 0;
        final workouts = ov?.workoutsThisWeek ?? 0;
        final pct = _pctChange(volume, prevVolume);

        final trend = provider.overview?.totalVolumeTrend ?? [];
        final hasData = trend.any((p) => p.volumeKg > 0);
        final double maxY = hasData
            ? trend.map((p) => p.volumeKg).reduce((a, b) => a > b ? a : b) *
                1.25
            : 100.0;
        final safeMax = maxY <= 0 ? 100.0 : maxY;
        final thisWeek = _mondayOfNow();
        final trendPct = _pctChange(volume, prevVolume);
        final interpretation =
            _globalTrendInterpretation(trendPct, trend);

        return CustomScrollView(
          slivers: [
            // ── This Week metrics ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('This Week',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _miniMetric(
                          Icons.fitness_center_rounded,
                          'Volume',
                          _fmtVol(volume),
                          '${pct >= 0 ? '+' : ''}${pct.round()}% vs last wk',
                          pct >= 0
                              ? OnboardingTheme.success
                              : OnboardingTheme.danger,
                        )),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _miniMetric(
                          Icons.repeat_rounded,
                          'Sets',
                          '$sets',
                          'sets logged',
                          Colors.white38,
                        )),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _miniMetric(
                          Icons.calendar_today_rounded,
                          'Workouts',
                          '$workouts',
                          'this week',
                          Colors.white38,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Muscle Map ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: SizedBox(
                  height: 290,
                  child: Container(
                    decoration: BoxDecoration(
                      color: OnboardingTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: OnboardingTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(14, 14, 14, 10),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Muscle Map',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 2),
                                    Text('Tap a muscle for insights',
                                        style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: OnboardingTheme.accent
                                      .withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: OnboardingTheme.accent
                                          .withAlpha(60)),
                                ),
                                child: const Text('This week',
                                    style: TextStyle(
                                        color: OnboardingTheme.accent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                            color: OnboardingTheme.border, height: 1),
                        Expanded(
                          child: MuscleMapWidget(
                            muscleData: provider.muscleAnalytics.entries
                                .map((e) => MuscleVolumeModel(
                                      muscleGroup: e.key.painterKey,
                                      totalVolumeKg:
                                          e.value.currentWeekVolumeKg,
                                      totalSets: e.value.currentWeekSets,
                                      percentage: 0,
                                      previousVolumeKg:
                                          e.value.previousWeekVolumeKg,
                                      trendPercent:
                                          e.value.volumeChangePercent,
                                    ))
                                .toList(),
                            onMuscleTap: (key) {
                              final group =
                                  MuscleGroupX.fromPainterKey(key);
                              if (group != null) {
                                showMuscleInsightsSheet(context, group);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Weekly Volume Trend ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weekly Volume Trend',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Last 8 weeks',
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (trendPct >= 0
                                          ? OnboardingTheme.success
                                          : OnboardingTheme.danger)
                                      .withAlpha(25),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${trendPct >= 0 ? '+' : ''}${trendPct.round()}%',
                                  style: TextStyle(
                                      color: trendPct >= 0
                                          ? OnboardingTheme.success
                                          : OnboardingTheme.danger,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 130,
                            child: trend.isEmpty || !hasData
                                ? const Center(
                                    child: Text(
                                        'Log workouts to see volume trend.',
                                        style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 12)))
                                : BarChart(BarChartData(
                                    alignment:
                                        BarChartAlignment.spaceEvenly,
                                    maxY: safeMax,
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: safeMax / 4,
                                      getDrawingHorizontalLine: (_) =>
                                          const FlLine(
                                              color: Colors.white10,
                                              strokeWidth: 1),
                                    ),
                                    borderData:
                                        FlBorderData(show: false),
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData:
                                          BarTouchTooltipData(
                                        getTooltipColor: (_) =>
                                            OnboardingTheme.cardDark,
                                        getTooltipItem:
                                            (group, _, rod, __) =>
                                                BarTooltipItem(
                                          _fmtVol(rod.toY),
                                          const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: false)),
                                      topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: false)),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 36,
                                          interval: safeMax / 4,
                                          getTitlesWidget: (val, _) {
                                            if (val == 0) {
                                              return const Text('0',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.white38,
                                                      fontSize: 9));
                                            }
                                            return Text(
                                              _fmtAxisVol(val),
                                              style: const TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 9),
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
                                            if (idx < 0 ||
                                                idx >= trend.length) {
                                              return const SizedBox
                                                  .shrink();
                                            }
                                            if (idx == 0 ||
                                                idx ==
                                                    trend.length - 1) {
                                              return Text(
                                                DateFormat('M/d').format(
                                                    trend[idx].weekStart),
                                                style: const TextStyle(
                                                    color: Colors.white38,
                                                    fontSize: 9),
                                              );
                                            }
                                            return const SizedBox
                                                .shrink();
                                          },
                                        ),
                                      ),
                                    ),
                                    barGroups: trend
                                        .asMap()
                                        .entries
                                        .map((e) {
                                      final isCurrent = !e.value
                                          .weekStart
                                          .isBefore(thisWeek);
                                      return BarChartGroupData(
                                        x: e.key,
                                        barRods: [
                                          BarChartRodData(
                                            toY: e.value.volumeKg,
                                            color: isCurrent
                                                ? OnboardingTheme
                                                    .success
                                                : OnboardingTheme.accent
                                                    .withAlpha(180),
                                            width: 14,
                                            borderRadius:
                                                const BorderRadius
                                                    .vertical(
                                                    top: Radius
                                                        .circular(4)),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  )),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.insights_rounded,
                                  color: OnboardingTheme.accent,
                                  size: 13),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  interpretation,
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }

  static DateTime _mondayOfNow() {
    final d = DateTime.now();
    final today = DateTime(d.year, d.month, d.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  static double _pctChange(double current, double previous) {
    if (previous == 0 && current == 0) return 0;
    if (previous == 0 && current > 0) return 100;
    return ((current - previous) / previous) * 100;
  }

  static String _fmtVol(double v) {
    if (v >= 1000) {
      return '${NumberFormat('#,##0').format(v.round())} kg';
    }
    return '${v.round()} kg';
  }

  static String _fmtAxisVol(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.round().toString();
  }

  static String _globalTrendInterpretation(
      double pct, List<MuscleWeeklyPoint> trend) {
    final recent = trend.where((p) => p.volumeKg > 0).toList();
    String direction = '';
    if (recent.length >= 3) {
      final last = recent.last.volumeKg;
      final mid = recent[recent.length ~/ 2].volumeKg;
      final first = recent.first.volumeKg;
      if (last > mid && mid > first) {
        direction = ' · 4-wk trend: rising';
      } else if (last < mid && mid < first) {
        direction = ' · 4-wk trend: declining';
      } else {
        direction = ' · 4-wk trend: stable';
      }
    }
    if (pct > 35) return 'Volume increased sharply. Watch recovery.$direction';
    if (pct > 10) return 'Volume is trending upward steadily.$direction';
    if (pct >= -10) return 'Volume is stable compared to last week.$direction';
    if (pct >= -30) return 'Volume dipped this week.$direction';
    return 'Volume dropped significantly. May be a deload.$direction';
  }

  Widget _miniMetric(IconData icon, String label, String value,
      String sub, Color subColor) {
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
              color: OnboardingTheme.accent.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: OnboardingTheme.accent, size: 16),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(sub,
              style: TextStyle(color: subColor, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
