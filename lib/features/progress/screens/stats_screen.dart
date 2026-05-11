import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/widgets/onboarding_widgets.dart';
import '../../progress/models/muscle_volume_model.dart';
import '../../progress/providers/stats_provider.dart';
import '../../progress/widgets/muscle_map_widget.dart';

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
      final sp = context.read<StatsProvider>();
      sp.loadAllStats();
      sp.loadMuscleVolume('1m');
    });
  }

  // ── Period filter pills ───────────────────────────────────────────────────

  static const _periods = ['1W', '1M', '3M', '6M', '1Y'];

  String _apiPeriod(String pill) => pill.toLowerCase();

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StatsProvider>();

    // Full-screen loader only when both are loading and no cached data
    final isInitialLoad = sp.isLoading &&
        sp.isMuscleVolumeLoading &&
        sp.weeklyVolume.isEmpty &&
        sp.muscleVolume.isEmpty;

    if (isInitialLoad) {
      return const Scaffold(
        backgroundColor: OnboardingTheme.bg,
        body: Center(
          child: CircularProgressIndicator(color: OnboardingTheme.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──────────────────────────────────────────────────
              const Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // ── Period Pills ───────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _periods.map((p) {
                    final active = sp.selectedPeriod == _apiPeriod(p);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            context.read<StatsProvider>().setPeriod(_apiPeriod(p)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            gradient: active
                                ? const LinearGradient(
                                    colors: [
                                      OnboardingTheme.gradientStart,
                                      OnboardingTheme.gradientEnd,
                                    ],
                                  )
                                : null,
                            color: active ? null : OnboardingTheme.cardDark,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color:
                                    active ? Colors.white : Colors.white60,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // ── Section 1 — Muscle Map ─────────────────────────────────
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Muscle Activity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Tap a muscle for details',
                          style: TextStyle(
                              fontSize: 12, color: Colors.white38),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    sp.isMuscleVolumeLoading && sp.muscleVolume.isEmpty
                        ? _MuscleMapPlaceholder()
                        : SizedBox(
                            height: 340,
                            child: MuscleMapWidget(
                              muscleData: sp.muscleVolume,
                              onMuscleTap: (group) =>
                                  _showMuscleDetail(context, group, sp),
                            ),
                          ),
                  ],
                ),
              ),

              // ── Section 2 — Training Frequency ────────────────────────
              const SizedBox(height: 16),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Training Frequency',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (sp.muscleVolumePeriodLabel.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          sp.muscleVolumePeriodLabel,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white38),
                        ),
                      ),
                    const SizedBox(height: 16),
                    sp.weeklyVolume.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No data for this period',
                                style: TextStyle(color: Colors.white38),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 160,
                            child: _FrequencyChart(data: sp.weeklyVolume),
                          ),
                  ],
                ),
              ),

              // ── Section 3 — Volume Over Time ───────────────────────────
              const SizedBox(height: 16),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Volume',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    sp.weeklyVolume.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No data for this period',
                                style: TextStyle(color: Colors.white38),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 160,
                            child: _VolumeLineChart(data: sp.weeklyVolume),
                          ),
                  ],
                ),
              ),

              // ── Section 4 — Muscle Balance Radar ──────────────────────
              if (sp.muscleVolume.length >= 3) ...[
                const SizedBox(height: 16),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Muscle Balance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: _MuscleRadar(data: sp.muscleVolume),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Section 5 — Consistency Calendar ─────────────────────
              const SizedBox(height: 16),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Consistency',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Last 12 weeks',
                          style: TextStyle(
                              fontSize: 12, color: Colors.white38),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ConsistencyGrid(weeklyVolume: sp.weeklyVolume),
                  ],
                ),
              ),

              // ── Section 6 — Personal Records ──────────────────────────
              const SizedBox(height: 16),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Records',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    sp.personalRecords.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'No records yet — keep lifting.',
                                style: TextStyle(color: Colors.white38),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                math.min(5, sp.personalRecords.length),
                            separatorBuilder: (_, p1) => const Divider(
                                height: 1,
                                color: OnboardingTheme.border),
                            itemBuilder: (ctx, i) {
                              final pr = sp.personalRecords[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pr.exerciseName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${pr.maxWeight.toStringAsFixed(1)} kg',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: OnboardingTheme.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),

              // ── Section 7 — Summary Chips ──────────────────────────────
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.timer_rounded,
                      iconColor: OnboardingTheme.accent,
                      // TODO: replace with StatsProvider.avgDurationMinutes when available
                      value: '—',
                      label: 'Avg Duration',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.fitness_center_rounded,
                      iconColor: OnboardingTheme.success,
                      // TODO: replace with StatsProvider.totalWorkouts when available
                      value: sp.weeklyVolume
                          .where((w) => w.workoutCount > 0)
                          .length
                          .toString(),
                      label: 'Active Weeks',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Muscle detail bottom sheet ────────────────────────────────────────────

  void _showMuscleDetail(
      BuildContext context, String group, StatsProvider sp) {
    final item =
        sp.muscleVolume.where((m) => m.muscleGroup == group).firstOrNull;
    if (item == null) return;

    final trend = item.trendPercent;
    final trendPositive = trend >= 0;
    final trendColor =
        trendPositive ? OnboardingTheme.success : OnboardingTheme.danger;
    final trendIcon =
        trendPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: OnboardingTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OnboardingTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                group,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Stat rows
              Container(
                decoration: BoxDecoration(
                  color: OnboardingTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _SheetStatRow(
                        label: 'Volume',
                        value:
                            '${_formatVolume(item.totalVolumeKg)} kg'),
                    const Divider(height: 1, color: OnboardingTheme.border),
                    _SheetStatRow(
                        label: 'Sets',
                        value: item.totalSets.toString()),
                    const Divider(height: 1, color: OnboardingTheme.border),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('vs Previous Period',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 14)),
                          Row(
                            children: [
                              Icon(trendIcon, size: 16, color: trendColor),
                              const SizedBox(width: 4),
                              Text(
                                '${trend.abs().toStringAsFixed(1)}%',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: trendColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Volume share bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.percentage.toStringAsFixed(1)}% of total training volume',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white60),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 8,
                      color: OnboardingTheme.cardDark,
                      child: FractionallySizedBox(
                        widthFactor: (item.percentage / 100).clamp(0.0, 1.0),
                        alignment: Alignment.centerLeft,
                        child: Container(color: OnboardingTheme.accent),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatVolume(double v) {
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}k';
    }
    return v.toStringAsFixed(0);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE HELPERS & SUB-WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: OnboardingTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.white60)),
        ],
      ),
    );
  }
}

class _SheetStatRow extends StatelessWidget {
  final String label;
  final String value;
  const _SheetStatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MuscleMapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: OnboardingTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: OnboardingTheme.accent),
          SizedBox(height: 12),
          Text(
            'Analyzing your muscles...',
            style: TextStyle(fontSize: 12, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

// ── Frequency Bar Chart ───────────────────────────────────────────────────────

class _FrequencyChart extends StatelessWidget {
  final List<dynamic> data; // WeeklyVolumeModel

  const _FrequencyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final bars = data.asMap().entries.map((e) {
      final count = (e.value.workoutCount as int).toDouble();
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: count,
            color: OnboardingTheme.accent,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: 7,
        barGroups: bars,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: OnboardingTheme.border,
            strokeWidth: 1,
          ),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final i = val.toInt();
                return Text(
                  'W${i + 1}',
                  style: const TextStyle(
                      fontSize: 10, color: Colors.white38),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => OnboardingTheme.cardDark,
            getTooltipItem: (group, p1, rod, p2) => BarTooltipItem(
              '${rod.toY.toInt()} workouts',
              const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Volume Line Chart ─────────────────────────────────────────────────────────

class _VolumeLineChart extends StatelessWidget {
  final List<dynamic> data; // WeeklyVolumeModel

  const _VolumeLineChart({required this.data});

  String _formatY(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(),
          (e.value.totalVolumeKg as double));
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: OnboardingTheme.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (val, _) => Text(
                _formatY(val),
                style:
                    const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            gradient: const LinearGradient(
              colors: [
                OnboardingTheme.gradientStart,
                OnboardingTheme.gradientEnd,
              ],
            ),
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  OnboardingTheme.gradientStart.withValues(alpha: 0.15),
                  OnboardingTheme.gradientEnd.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Muscle Balance Radar ──────────────────────────────────────────────────────

class _MuscleRadar extends StatelessWidget {
  final List<MuscleVolumeModel> data;
  const _MuscleRadar({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxVol = data.map((m) => m.totalVolumeKg).reduce(math.max);
    final dataSets = [
      RadarDataSet(
        fillColor: OnboardingTheme.accent.withValues(alpha: 0.2),
        borderColor: OnboardingTheme.accent,
        borderWidth: 2,
        dataEntries: data
            .map((m) =>
                RadarEntry(value: maxVol > 0 ? m.totalVolumeKg / maxVol : 0))
            .toList(),
      ),
    ];

    return RadarChart(
      RadarChartData(
        dataSets: dataSets,
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: const BorderSide(color: OnboardingTheme.border),
        tickBorderData: const BorderSide(color: OnboardingTheme.border),
        gridBorderData:
            const BorderSide(color: OnboardingTheme.border, width: 0.5),
        tickCount: 3,
        ticksTextStyle: TextStyle(color: Colors.transparent, fontSize: 0),
        getTitle: (index, angle) {
          if (index >= data.length) return RadarChartTitle(text: '');
          return RadarChartTitle(
            text: data[index].muscleGroup,
            angle: 0,
          );
        },
        titleTextStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white60,
        ),
        titlePositionPercentageOffset: 0.1,
      ),
    );
  }
}

// ── Consistency Calendar ──────────────────────────────────────────────────────

class _ConsistencyGrid extends StatelessWidget {
  final List<dynamic> weeklyVolume; // WeeklyVolumeModel list

  const _ConsistencyGrid({required this.weeklyVolume});

  @override
  Widget build(BuildContext context) {
    // TODO: upgrade to day-level granularity when backend supports it
    // For now, use 12 most recent weeks; mark as "trained" if workoutCount > 0
    const int numWeeks = 12;
    const int daysPerWeek = 7;
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Take last 12 weeks of data (or less if not enough)
    final weeks = weeklyVolume.length >= numWeeks
        ? weeklyVolume.sublist(weeklyVolume.length - numWeeks)
        : weeklyVolume;

    // Compute average volume for colour thresholding
    final trainedWeeks = weeks.where((w) => w.workoutCount > 0).toList();
    final avgVol = trainedWeeks.isEmpty
        ? 0.0
        : trainedWeeks.fold<double>(
                0, (sum, w) => sum + (w.totalVolumeKg as double)) /
            trainedWeeks.length;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final cellSize =
            (constraints.maxWidth - 20) / numWeeks - 2; // 20px for day labels

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day-of-week labels column
            Column(
              children: dayLabels.map((d) {
                return SizedBox(
                  height: cellSize + 2,
                  width: 14,
                  child: Center(
                    child: Text(d,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white38)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 4),
            // Week columns
            ...List.generate(numWeeks, (wi) {
              final weekIndex = wi - (numWeeks - weeks.length);
              final hasData = weekIndex >= 0 && weekIndex < weeks.length;
              final w = hasData ? weeks[weekIndex] : null;
              final isActive = w != null && (w.workoutCount as int) > 0;
              final isHigh = isActive &&
                  avgVol > 0 &&
                  (w.totalVolumeKg as double) > avgVol;

              final color = isHigh
                  ? OnboardingTheme.success
                  : isActive
                      ? OnboardingTheme.accent
                      : OnboardingTheme.cardDark;

              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Column(
                  children: List.generate(daysPerWeek, (_) {
                    return Container(
                      width: cellSize,
                      height: cellSize,
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
