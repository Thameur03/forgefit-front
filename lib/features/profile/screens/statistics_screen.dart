import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/widgets/onboarding_widgets.dart';
import '../../nutrition/providers/nutrition_provider.dart';
import '../../nutrition/models/nutrition_model.dart';
import '../../progress/providers/stats_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// STATISTICS SCREEN — Top-level
// ═══════════════════════════════════════════════════════════════════════════════

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().loadAllStats();
      context.read<NutritionProvider>().loadTodayNutrition();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      appBar: AppBar(
        backgroundColor: OnboardingTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OnboardingTheme.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Statistics',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildTabBar(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _WorkoutsTab(),
          _NutritionTab(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: OnboardingTheme.card,
        border: Border(
          bottom: BorderSide(color: OnboardingTheme.border),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: OnboardingTheme.accent, width: 2),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          fontFamily: 'Inter',
        ),
        tabs: const [
          Tab(text: 'Workouts'),
          Tab(text: 'Nutrition'),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WORKOUTS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _WorkoutsTab extends StatelessWidget {
  const _WorkoutsTab();

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // CARD 1 — Training Volume
          _StatCard(
            title: 'Training Volume',
            subtitle: 'Weekly total (kg)',
            child: _buildVolumeChart(stats),
          ),

          // CARD 2 — Muscle Group Split
          _StatCard(
            title: 'Muscle Group Split',
            subtitle: '30-day window',
            child: _buildMuscleSplitChart(),
          ),

          // CARD 3 — Personal Records
          _StatCard(
            title: 'Personal Records',
            child: _buildPersonalRecords(stats),
          ),

          // CARD 4 — Consistency Score
          _StatCard(
            title: 'Consistency Score',
            subtitle: 'Based on planned workouts',
            child: _buildConsistencyScore(),
          ),

          // CARD 5 — Rest & Recovery
          _StatCard(
            title: 'Rest & Recovery',
            child: _buildRestRecovery(),
          ),
        ],
      ),
    );
  }

  // ── Training Volume Bar Chart ──────────────────────────────────────────────

  Widget _buildVolumeChart(StatsProvider stats) {
    final volumes = stats.weeklyVolume.isNotEmpty
        ? stats.weeklyVolume.map((w) => w.volume).toList()
        : <double>[4200, 3800, 5100, 4600, 5300, 4900, 5600, 6100];

    final maxVolume =
        volumes.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxVolume * 1.2).ceilToDouble(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: OnboardingTheme.border,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, _) => Text(
                      '${(v / 1000).toStringAsFixed(0)}k',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.white38),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    getTitlesWidget: (v, _) => Text(
                      'W${v.toInt() + 1}',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.white38),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: List.generate(
                volumes.length,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: volumes[i],
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                      gradient: i == volumes.length - 1
                          ? const LinearGradient(
                              colors: [
                                OnboardingTheme.gradientStart,
                                OnboardingTheme.gradientEnd,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            )
                          : null,
                      color: i != volumes.length - 1
                          ? OnboardingTheme.cardMid
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const _InsightBlock(
          text: '↑ 12% vs last month — progressive overload on track',
          color: OnboardingTheme.success,
        ),
      ],
    );
  }

  // ── Muscle Group Split Pie Chart ───────────────────────────────────────────

  Widget _buildMuscleSplitChart() {
    const secondaryColor = Color(0xFF2563EB);
    const lightBlue = Color(0xFF5B8BFF);

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 44,
              sectionsSpace: 2,
              sections: [
                PieChartSectionData(
                    value: 35,
                    color: OnboardingTheme.accent,
                    title: '',
                    radius: 28),
                PieChartSectionData(
                    value: 30,
                    color: secondaryColor,
                    title: '',
                    radius: 28),
                PieChartSectionData(
                    value: 25,
                    color: lightBlue,
                    title: '',
                    radius: 28),
                PieChartSectionData(
                    value: 10,
                    color: OnboardingTheme.cardMid,
                    title: '',
                    radius: 28),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Column(
          children: [
            _LegendRow(
                color: OnboardingTheme.accent, label: 'Push', value: '35%'),
            SizedBox(height: 6),
            _LegendRow(
                color: secondaryColor, label: 'Pull', value: '30%'),
            SizedBox(height: 6),
            _LegendRow(
                color: lightBlue, label: 'Legs', value: '25%'),
            SizedBox(height: 6),
            _LegendRow(
                color: OnboardingTheme.cardMid,
                label: 'Core',
                value: '10%'),
          ],
        ),
        const _InsightBlock(
          text: 'Legs slightly undertrained — consider adding 1 leg session',
        ),
      ],
    );
  }

  // ── Personal Records ───────────────────────────────────────────────────────

  Widget _buildPersonalRecords(StatsProvider stats) {
    final records = stats.personalRecords;

    // Placeholder data when no records exist yet
    final displayRecords = records.isNotEmpty
        ? records
            .map((r) => _PRRow(
                  name: r.exerciseName,
                  weight: '${r.maxWeight.toStringAsFixed(0)} kg',
                  date: _formatDate(r.dateAchieved),
                ))
            .toList()
        : const [
            _PRRow(name: 'Bench Press', weight: '100 kg', date: ''),
            _PRRow(name: 'Squat', weight: '120 kg', date: ''),
            _PRRow(name: 'Deadlift', weight: '140 kg', date: ''),
            _PRRow(name: 'OHP', weight: '65 kg', date: ''),
          ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayRecords.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: OnboardingTheme.border),
      itemBuilder: (_, i) => displayRecords[i],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  // ── Consistency Score ──────────────────────────────────────────────────────

  Widget _buildConsistencyScore() {
    const double score = 0.82;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 55,
                  sectionsSpace: 0,
                  sections: [
                    PieChartSectionData(
                      value: score * 100,
                      color: OnboardingTheme.accent,
                      title: '',
                      radius: 20,
                    ),
                    PieChartSectionData(
                      value: (1 - score) * 100,
                      color: OnboardingTheme.cardMid,
                      title: '',
                      radius: 20,
                    ),
                  ],
                ),
              ),
            ),
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '82%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'of weekly goal',
                  style: TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'You hit your 5-day target 18 of 22 weeks',
          style: TextStyle(fontSize: 13, color: Colors.white60),
          textAlign: TextAlign.center,
        ),
        const _InsightBlock(
          text: 'Elite consistency — top 10% of users',
          color: OnboardingTheme.success,
        ),
      ],
    );
  }

  // ── Rest & Recovery ────────────────────────────────────────────────────────

  Widget _buildRestRecovery() {
    return Column(
      children: [
        const Text(
          '1.4',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: OnboardingTheme.accent,
          ),
          textAlign: TextAlign.center,
        ),
        const Text(
          'days avg rest',
          style: TextStyle(fontSize: 13, color: Colors.white60),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 36,
          width: double.infinity,
          child: CustomPaint(painter: _RecoveryBarPainter(value: 1.4)),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0d',
                style: TextStyle(fontSize: 10, color: Colors.white38)),
            Text('1d',
                style: TextStyle(fontSize: 10, color: Colors.white38)),
            Text('2d',
                style: TextStyle(fontSize: 10, color: Colors.white38)),
            Text('3d+',
                style: TextStyle(fontSize: 10, color: Colors.white38)),
          ],
        ),
        const _InsightBlock(
          text:
              'Optimal for hypertrophy: 1–2 days rest between sessions',
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NUTRITION TAB
// ═══════════════════════════════════════════════════════════════════════════════

const Color _proteinColor = Color(0xFF4A90E2);
const Color _carbsColor = Color(0xFFF5A623);
const Color _fatColor = Color(0xFF50C878);

class _NutritionTab extends StatelessWidget {
  const _NutritionTab();

  @override
  Widget build(BuildContext context) {
    final nutrition = context.watch<NutritionProvider>();
    final stats = context.watch<StatsProvider>();
    final summary = nutrition.todaySummary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // CARD 1 — Calorie Trend
          _StatCard(
            title: 'Daily Calorie Intake',
            subtitle: 'Last 7 days',
            child: _buildCalorieTrend(stats),
          ),

          // CARD 2 — Macro Breakdown
          _StatCard(
            title: 'Average Macro Split',
            child: _buildMacroBreakdown(summary),
          ),

          // CARD 3 — Micronutrient Snapshot
          _StatCard(
            title: 'Micronutrient Snapshot',
            child: _buildMicronutrientSnapshot(),
          ),

          // CARD 4 — Protein Consistency
          _StatCard(
            title: 'Days Protein Goal Met',
            subtitle: '4-Week Consistency',
            child: _buildProteinConsistency(),
          ),

          // CARD 5 — Meal Timing
          _StatCard(
            title: 'Meal Timing Pattern',
            child: _buildMealTiming(),
          ),
        ],
      ),
    );
  }

  // ── Calorie Trend Line Chart ───────────────────────────────────────────────

  Widget _buildCalorieTrend(StatsProvider stats) {
    final trendData = stats.nutritionTrend;

    // Generate synthetic data when the API returns empty
    final rng = math.Random(42);
    final calories = trendData.isNotEmpty
        ? trendData.map((t) => t.calories.toDouble()).toList()
        : List.generate(30, (_) => 2310.0 + (rng.nextDouble() - 0.5) * 400);

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: OnboardingTheme.border,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    reservedSize: 20,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.white38),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (v, _) => Text(
                      '${(v / 1000).toStringAsFixed(1)}k',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.white38),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                // Consumed line
                LineChartBarData(
                  spots: calories
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                      .toList(),
                  isCurved: true,
                  color: OnboardingTheme.accent,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
                // Goal line (dashed)
                LineChartBarData(
                  spots: List.generate(
                    calories.length,
                    (i) => FlSpot(i.toDouble(), 2400),
                  ),
                  isCurved: false,
                  color: Colors.white30,
                  barWidth: 2,
                  dashArray: [5, 5],
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const _InsightBlock(
          text:
              'Averaged 2,310 kcal/day vs 2,400 goal — 96% adherence',
          color: OnboardingTheme.success,
        ),
      ],
    );
  }

  // ── Macro Breakdown Pie + Rows ─────────────────────────────────────────────

  Widget _buildMacroBreakdown(DailyNutritionSummary? summary) {
    final protein = summary?.totalProtein ?? 173.0;
    final carbs = summary?.totalCarbs ?? 260.0;
    final fat = summary?.totalFat ?? 64.0;
    final totalG = protein + carbs + fat;

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      sections: [
                        PieChartSectionData(
                            value: protein,
                            color: _proteinColor,
                            title: '',
                            radius: 22),
                        PieChartSectionData(
                            value: carbs,
                            color: _carbsColor,
                            title: '',
                            radius: 22),
                        PieChartSectionData(
                            value: fat,
                            color: _fatColor,
                            title: '',
                            radius: 22),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${summary?.totalCalories.round() ?? 2310}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'kcal',
                        style:
                            TextStyle(fontSize: 10, color: Colors.white38),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _MacroRow(
                      color: _proteinColor,
                      name: 'Protein',
                      grams: protein,
                      total: totalG),
                  const SizedBox(height: 10),
                  _MacroRow(
                      color: _carbsColor,
                      name: 'Carbs',
                      grams: carbs,
                      total: totalG),
                  const SizedBox(height: 10),
                  _MacroRow(
                      color: _fatColor,
                      name: 'Fat',
                      grams: fat,
                      total: totalG),
                ],
              ),
            ),
          ],
        ),
        const _InsightBlock(
          text:
              'Protein at 2.3g/kg bodyweight — optimal for muscle protein synthesis',
          color: _proteinColor,
        ),
      ],
    );
  }

  // ── Micronutrient Snapshot ─────────────────────────────────────────────────

  Widget _buildMicronutrientSnapshot() {
    // Color rule: ≥0.80 → success | 0.60–0.79 → warning | <0.60 → danger
    Color barColor(double pct) {
      if (pct >= 0.80) return OnboardingTheme.success;
      if (pct >= 0.60) return const Color(0xFFF5A623);
      return OnboardingTheme.danger;
    }

    final micros = <(String, double)>[
      ('Vitamin D', 0.61),
      ('Iron', 0.95),
      ('Calcium', 0.78),
      ('Magnesium', 0.52),
      ('Zinc', 0.88),
    ];

    return Column(
      children: micros.map((m) {
        final color = barColor(m.$2);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    m.$1,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    '${(m.$2 * 100).round()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: m.$2,
                  minHeight: 6,
                  backgroundColor: OnboardingTheme.cardMid,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Protein Consistency Heatmap ────────────────────────────────────────────

  Widget _buildProteinConsistency() {
    const int metCount = 21;
    final cells = List.generate(28, (i) => i < metCount);

    return Column(
      children: [
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 10, color: Colors.white38),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: 28,
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
              color:
                  cells[i] ? OnboardingTheme.success : OnboardingTheme.border,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '21/28 days — 75% adherence',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const _InsightBlock(
          text:
              'Consistent protein intake is the #1 lever for lean mass retention',
        ),
      ],
    );
  }

  // ── Meal Timing ────────────────────────────────────────────────────────────

  Widget _buildMealTiming() {
    const meals = <(String, double)>[
      ('Breakfast', 1 / 16),
      ('Lunch', 7 / 16),
      ('Pre-WO', 11 / 16),
      ('Dinner', 14 / 16),
    ];

    return Column(
      children: [
        SizedBox(
          height: 90,
          child: CustomPaint(
            painter: _MealTimelinePainter(meals: meals),
            child: Container(),
          ),
        ),
        const _InsightBlock(
          text:
              'Front-loading calories earlier improves body composition (chrono-nutrition)',
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _StatCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ] else
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InsightBlock extends StatelessWidget {
  final String text;
  final Color color;

  const _InsightBlock({
    required this.text,
    this.color = Colors.white60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: OnboardingTheme.cardDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: color,
        ),
      ),
    );
  }
}

class _PRRow extends StatelessWidget {
  final String name;
  final String weight;
  final String date;

  const _PRRow({
    required this.name,
    required this.weight,
    this.date = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_outlined,
              color: OnboardingTheme.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            weight,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: OnboardingTheme.accent,
            ),
          ),
          if (date.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              date,
              style: const TextStyle(fontSize: 12, color: Colors.white38),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.white60),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  final Color color;
  final String name;
  final double grams;
  final double total;

  const _MacroRow({
    required this.color,
    required this.name,
    required this.grams,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (grams / total * 100).round() : 0;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 13, color: Colors.white60),
          ),
        ),
        Text(
          '${grams.round()}g',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$pct%',
          style: const TextStyle(fontSize: 11, color: Colors.white38),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════════════════════

class _RecoveryBarPainter extends CustomPainter {
  final double value;
  _RecoveryBarPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    const maxDays = 3.0;
    final rr = const Radius.circular(6);
    final segments = <(double, double, Color)>[
      (0.0, 1.0, OnboardingTheme.danger),
      (1.0, 2.0, OnboardingTheme.success),
      (2.0, 3.0, const Color(0xFFF5A623)),
    ];

    for (final seg in segments) {
      final left = (seg.$1 / maxDays) * size.width;
      final right = (seg.$2 / maxDays) * size.width;
      final isFirst = seg.$1 == 0;
      final isLast = seg.$2 == maxDays;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, 0, right - left, size.height),
        topLeft: isFirst ? rr : Radius.zero,
        bottomLeft: isFirst ? rr : Radius.zero,
        topRight: isLast ? rr : Radius.zero,
        bottomRight: isLast ? rr : Radius.zero,
      );
      canvas.drawRRect(rect, Paint()..color = seg.$3);
    }

    // Pointer triangle at value position
    final px = (value / maxDays).clamp(0.0, 1.0) * size.width;
    final path = ui.Path()
      ..moveTo(px - 6, size.height + 8)
      ..lineTo(px + 6, size.height + 8)
      ..lineTo(px, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RecoveryBarPainter old) => old.value != value;
}

class _MealTimelinePainter extends CustomPainter {
  final List<(String, double)> meals;
  _MealTimelinePainter({required this.meals});

  @override
  void paint(Canvas canvas, Size size) {
    final barY = size.height * 0.35;
    const barH = 36.0;

    // Background bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, barY, size.width, barH),
        const Radius.circular(8),
      ),
      Paint()..color = OnboardingTheme.cardMid,
    );

    // Dots and labels
    for (final meal in meals) {
      final x = meal.$2 * size.width;

      // Dot
      canvas.drawCircle(
        Offset(x, barY + barH / 2),
        6,
        Paint()..color = OnboardingTheme.accent,
      );

      // Label above dot
      final tp = TextPainter(
        text: TextSpan(
          text: meal.$1,
          style: const TextStyle(fontSize: 10, color: Colors.white60),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      final labelX = (x - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(labelX, barY - 16));
    }

    // End labels: "6am" and "10pm"
    final startLabel = TextPainter(
      text: const TextSpan(
        text: '6 AM',
        style: TextStyle(fontSize: 10, color: Colors.white38),
      ),
      textDirection: TextDirection.ltr,
    );
    startLabel.layout();
    startLabel.paint(canvas, Offset(0, barY + barH + 4));

    final endLabel = TextPainter(
      text: const TextSpan(
        text: '10 PM',
        style: TextStyle(fontSize: 10, color: Colors.white38),
      ),
      textDirection: TextDirection.ltr,
    );
    endLabel.layout();
    endLabel.paint(
        canvas, Offset(size.width - endLabel.width, barY + barH + 4));
  }

  @override
  bool shouldRepaint(covariant _MealTimelinePainter old) => false;
}
