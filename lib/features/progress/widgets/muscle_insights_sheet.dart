import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../models/muscle_group.dart';
import '../models/muscle_analytics_model.dart';
import '../providers/progress_provider.dart';

// ── Public show function ──────────────────────────────────────────────────────

void showMuscleInsightsSheet(BuildContext context, MuscleGroup muscle) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      // Extra bottom inset so content clears the Android gesture nav bar
      final bottomInset = MediaQuery.of(sheetCtx).viewPadding.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 0),
        child: _MuscleInsightsSheet(muscle: muscle),
      );
    },
  );
}

// ── Bottom sheet widget ───────────────────────────────────────────────────────

class _MuscleInsightsSheet extends StatelessWidget {
  final MuscleGroup muscle;
  const _MuscleInsightsSheet({required this.muscle});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, provider, _) {
        final analytics = provider.muscleAnalytics[muscle];

        // Use FractionallySizedBox to provide bounded height to the sheet.
        // This eliminates the unbounded height constraint error.
        return FractionallySizedBox(
          heightFactor: 0.88,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: const BoxDecoration(
              color: OnboardingTheme.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Drag handle & header (fixed, never scrolls) ──────────────
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              muscle.insightsTitle,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'This week vs previous week',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                              color: OnboardingTheme.card,
                              borderRadius: BorderRadius.circular(17)),
                          child: const Icon(Icons.close,
                              color: Colors.white54, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: OnboardingTheme.border, height: 1),

                // ── Scrollable content (Expanded gives it the remaining space) ─
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: analytics == null || !analytics.hasData
                        ? _buildEmptyState()
                        : _buildContent(context, analytics),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        Icon(Icons.fitness_center_rounded,
            color: Colors.white.withAlpha(50), size: 48),
        const SizedBox(height: 16),
        const Text('No data yet',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Log exercises for ${muscle.label} to unlock insights.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(height: 24),
        _suggestedCard(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _suggestedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Suggested exercises',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...muscle.suggestedExercises.map(
            (ex) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline,
                      color: OnboardingTheme.accent, size: 16),
                  const SizedBox(width: 8),
                  Text(ex,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Full content ────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, MuscleAnalytics a) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Sets first, Volume second (user preference)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _statCard(
                  label: 'Sets',
                  value: '${a.currentWeekSets}',
                  valueUnit: 'sets',
                  sub: 'Previous: ${a.previousWeekSets} sets',
                  subPositive: a.currentWeekSets >= a.previousWeekSets,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  label: 'Volume',
                  value: _fmtVol(a.currentWeekVolumeKg),
                  valueUnit: '',
                  sub: _fmtPercent(a.volumeChangePercent),
                  subPositive: a.volumeChangePercent >= 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2. Heaviest Lift card (only shown when PRs exist)
        if (a.personalRecords.isNotEmpty) ...[
          _heaviestLiftCard(a.personalRecords.first),
          const SizedBox(height: 10),
        ],

        // 3. 8-week trend chart with Y-axis + interpretation
        _trendChartCard(a),
        const SizedBox(height: 10),

        // 4. Recovery / Fatigue card
        _fatigueCard(a.fatigueWarnings),
        const SizedBox(height: 10),

        // 5. Personal Records list
        if (a.personalRecords.isNotEmpty) ...[
          _prsCard(a.personalRecords),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ── Stat card ───────────────────────────────────────────────────────────────

  Widget _statCard({
    required String label,
    required String value,
    required String valueUnit,
    required String sub,
    required bool subPositive,
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
          Text(label,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                if (valueUnit.isNotEmpty)
                  TextSpan(
                    text: ' $valueUnit',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(sub,
              style: TextStyle(
                color: subPositive
                    ? OnboardingTheme.success
                    : OnboardingTheme.danger,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  // ── Heaviest Lift card ──────────────────────────────────────────────────────

  Widget _heaviestLiftCard(MusclePersonalRecord pr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            OnboardingTheme.accent.withAlpha(30),
            OnboardingTheme.accent.withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OnboardingTheme.accent.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.military_tech_rounded,
                  color: OnboardingTheme.accent, size: 15),
              const SizedBox(width: 5),
              const Text(
                'Heaviest Lift',
                style: TextStyle(
                    color: OnboardingTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pr.exerciseName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Best set: ${pr.weightKg.toStringAsFixed(1)} kg × ${pr.reps} reps',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            'e1RM: ${pr.estimatedOneRepMaxKg.toStringAsFixed(1)} kg  ·  '
            '${DateFormat('dd MMM yy').format(pr.date)}',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── 8-week trend chart (explicit SizedBox height — no Expanded in chart) ─────

  Widget _trendChartCard(MuscleAnalytics a) {
    final trend = a.weeklyTrend;
    final hasData = trend.any((p) => p.volumeKg > 0);
    // Safe maxY calculation — never NaN/0
    final double maxY = hasData
        ? trend.map((p) => p.volumeKg).reduce((x, y) => x > y ? x : y) * 1.25
        : 100.0;
    final safeMaxY = maxY <= 0 ? 100.0 : maxY;
    final thisWeek = _mondayOfNow();
    final interpretation = _trendInterpretation(
        a.currentWeekVolumeKg, a.previousWeekVolumeKg, trend);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('8-Week Trend',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                'Current: ${_fmtVol(a.currentWeekVolumeKg)}',
                style:
                    const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(width: 8),
              Text(
                _fmtPercent(a.volumeChangePercent),
                style: TextStyle(
                  color: a.volumeChangePercent >= 0
                      ? OnboardingTheme.success
                      : OnboardingTheme.danger,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Fixed height — never Expanded inside a column inside a scroll view
          SizedBox(
            height: 130,
            child: !hasData
                ? const Center(
                    child: Text('No data yet',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 12)))
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
                              if (idx < 0 || idx >= trend.length) {
                                return const SizedBox.shrink();
                              }
                              if (idx == 0 ||
                                  idx == trend.length - 1) {
                                return Text(
                                  DateFormat('M/d')
                                      .format(trend[idx].weekStart),
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
                        final isCurrent =
                            !e.value.weekStart.isBefore(thisWeek);
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.volumeKg,
                              color: isCurrent
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF2563EB)
                                      .withAlpha(180),
                              width: 12,
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
          // Interpretation line — no Expanded needed; Row wraps naturally
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.insights_rounded,
                  color: OnboardingTheme.accent, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  interpretation,
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recovery / Fatigue card ─────────────────────────────────────────────────

  Widget _fatigueCard(List<String> warnings) {
    // Guard against empty list to avoid crash on .first / .contains
    if (warnings.isEmpty) {
      warnings = ['No recovery concerns this week.'];
    }
    final isOk = warnings.first.contains('No recovery');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isOk
            ? OnboardingTheme.success.withAlpha(18)
            : Colors.orange.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isOk
                ? OnboardingTheme.success.withAlpha(70)
                : Colors.orange.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOk
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                color: isOk ? OnboardingTheme.success : Colors.orange,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                'Recovery Status',
                style: TextStyle(
                  color: isOk
                      ? OnboardingTheme.success
                      : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...warnings.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                w,
                style: TextStyle(
                    color: isOk ? Colors.white70 : Colors.orange[200],
                    fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Personal Records card ───────────────────────────────────────────────────

  Widget _prsCard(List<MusclePersonalRecord> prs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: Colors.amber, size: 15),
              const SizedBox(width: 6),
              const Text('Personal Records',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ...prs.take(5).map(
                (pr) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pr.exerciseName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${pr.weightKg.toStringAsFixed(1)} kg × ${pr.reps}'
                        '  |  ${pr.estimatedOneRepMaxKg.toStringAsFixed(1)} kg e1RM',
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12),
                      ),
                      Text(
                        DateFormat('dd MMM yy').format(pr.date),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // ── Trend interpretation ────────────────────────────────────────────────────

  static String _trendInterpretation(
    double current,
    double previous,
    List<MuscleWeeklyPoint> trend,
  ) {
    if (current == 0 && previous == 0) {
      return 'No training logged for this muscle recently.';
    }
    if (previous == 0 && current > 0) {
      return 'First data this week. Keep tracking to see trends.';
    }
    final pct = ((current - previous) / previous) * 100;

    final recent = trend.where((p) => p.volumeKg > 0).toList();
    String direction = '';
    if (recent.length >= 3) {
      final last = recent.last.volumeKg;
      final mid = recent[recent.length ~/ 2].volumeKg;
      final first = recent.first.volumeKg;
      if (last > mid && mid > first) {
        direction = ' · 4-wk direction: rising';
      } else if (last < mid && mid < first) {
        direction = ' · 4-wk direction: declining';
      } else {
        direction = ' · 4-wk direction: stable';
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

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static DateTime _mondayOfNow() {
    final d = DateTime.now();
    final today = DateTime(d.year, d.month, d.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  static String _fmtVol(double v) {
    if (v >= 1000) return '${NumberFormat('#,##0').format(v.round())} kg';
    return '${v.round()} kg';
  }

  static String _fmtAxisVol(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.round().toString();
  }

  static String _fmtPercent(double p) {
    final sign = p >= 0 ? '+' : '';
    return '$sign${p.round()}%';
  }
}
