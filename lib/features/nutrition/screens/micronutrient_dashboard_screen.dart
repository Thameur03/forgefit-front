import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/nutrition_provider.dart';

class MicronutrientDashboardScreen extends StatefulWidget {
  const MicronutrientDashboardScreen({super.key});

  @override
  State<MicronutrientDashboardScreen> createState() =>
      _MicronutrientDashboardScreenState();
}

class _MicronutrientDashboardScreenState
    extends State<MicronutrientDashboardScreen>
    with SingleTickerProviderStateMixin {
  // Aggregated nutrients map: nutrient_id → {name, unit, rda, total}
  Map<int, Map<String, dynamic>> _aggregated = {};
  bool _loading = true;
  int _resolvedCount = 0;

  // Shimmer animation
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  // Quick-view critical nutrients (shown as chips at top)
  static const _criticalIds = [1114, 1089, 1087, 1090, 1162, 1079];

  // Nutrient groups
  static const _groups = <String, List<int>>{
    'Minerals': [1087, 1089, 1090, 1091, 1092, 1093, 1095, 1098],
    'Fat-Soluble Vitamins': [1106, 1109, 1114, 1185],
    'Water-Soluble Vitamins': [1162, 1165, 1166, 1167, 1175, 1177, 1178],
    'Other': [1079],
  };

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmerAnim =
        Tween<double>(begin: 0.15, end: 0.35).animate(_shimmerController);
    _loadData();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() { _loading = true; _resolvedCount = 0; });
    final provider = context.read<NutritionProvider>();
    final logs = provider.todayLogs;

    if (logs.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final aggregated = <int, Map<String, dynamic>>{};

    final futures = logs.map((log) => provider.getNutrients(
          fdcId: log.fdcId,
          foodName: log.foodName,
        ));

    final results = await Future.wait(futures);

    for (int i = 0; i < logs.length; i++) {
      final nutrients = results[i];
      if (nutrients.isEmpty) continue;

      if (mounted) setState(() => _resolvedCount++);

      final scaledFactor = logs[i].amount > 0 ? logs[i].amount / 100 : 1.0;

      for (final n in nutrients) {
        final id = n['id'] as int?;
        if (id == null) continue;
        final baseAmount = (n['amount'] as num?)?.toDouble() ?? 0.0;
        final scaled = baseAmount * scaledFactor;

        if (aggregated.containsKey(id)) {
          aggregated[id]!['total'] =
              (aggregated[id]!['total'] as double) + scaled;
        } else {
          aggregated[id] = {
            'name': n['name'],
            'unit': n['unit'],
            'rda': (n['rda'] as num?)?.toDouble() ?? 0.0,
            'total': scaled,
          };
        }
      }
    }

    if (mounted) {
      setState(() {
        _aggregated = aggregated;
        _loading = false;
      });
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Color _barColor(double pct) {
    if (pct >= 100) return Colors.green;
    if (pct >= 50) return const Color(0xFF4A90E2);
    if (pct >= 25) return Colors.grey;
    return Colors.redAccent;
  }

  double _pct(Map<String, dynamic> n) {
    final rda = n['rda'] as double? ?? 0.0;
    final total = n['total'] as double? ?? 0.0;
    return rda > 0 ? (total / rda * 100) : 0.0;
  }

  // ── Shimmer skeleton ────────────────────────────────────────────────────────

  Widget _shimmerBox(double width, double height) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, child) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((_shimmerAnim.value * 255).round()),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _shimmerBox(double.infinity, 80),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _shimmerBox(100, 90),
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(
          8,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(120, 12),
                const SizedBox(height: 6),
                _shimmerBox(double.infinity, 6),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Critical nutrient chips ─────────────────────────────────────────────────

  Widget _buildCriticalChips() {
    final chips = _criticalIds
        .where((id) => _aggregated.containsKey(id))
        .toList();

    if (chips.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final id = chips[i];
          final n = _aggregated[id]!;
          final pct = _pct(n);
          final color = _barColor(pct);
          final total = n['total'] as double? ?? 0.0;
          final rda = n['rda'] as double? ?? 0.0;
          final unit = n['unit'] as String? ?? '';

          return Container(
            width: 108,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  n['name'] as String? ?? '',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${total.toStringAsFixed(1)}/${rda.toStringAsFixed(0)}$unit',
                  style:
                      TextStyle(fontSize: 10, color: Colors.white.withAlpha(153)),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 100.0) / 100,
                    minHeight: 4,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pct.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Full grouped list ───────────────────────────────────────────────────────

  List<Widget> _buildFullList() {
    final widgets = <Widget>[];

    for (final entry in _groups.entries) {
      final ids = _groups[entry.key] ?? [];
      final groupData = ids
          .where((id) => _aggregated.containsKey(id))
          .map((id) => _aggregated[id]!)
          .toList();
      if (groupData.isEmpty) continue;

      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(
          entry.key.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ));

      for (final n in groupData) {
        final pct = _pct(n);
        final pctClamped = pct.clamp(0.0, 100.0);
        final color = _barColor(pct);
        final total = n['total'] as double? ?? 0.0;
        final rda = n['rda'] as double? ?? 0.0;
        final unit = n['unit'] as String? ?? '';

        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      n['name'] as String? ?? '',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(1)} / ${rda.toStringAsFixed(0)}$unit',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(153)),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 42,
                    child: Text(
                      '${pct.toStringAsFixed(0)}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: pctClamped / 100,
                  minHeight: 3,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ));
      }
    }
    return widgets;
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Today's Nutrients"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSkeleton(),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Analyzing $_resolvedCount of ${context.read<NutritionProvider>().todayLogs.length} foods…',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _buildContent(theme, dateLabel),
            ),
    );
  }

  Widget _buildContent(ThemeData theme, String dateLabel) {
    final provider = context.watch<NutritionProvider>();
    final logs = provider.todayLogs;

    // Empty state: no foods logged at all
    if (logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science_outlined,
                  size: 64, color: Colors.white.withAlpha(77)),
              const SizedBox(height: 20),
              const Text(
                "Log some food today to see\nyour nutrient breakdown.",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 16, color: Colors.white54, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    // All lookups (fdc_id + name fallback) returned nothing
    if (_aggregated.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline,
                  size: 52, color: Colors.white.withAlpha(77)),
              const SizedBox(height: 16),
              const Text(
                'No nutrient data could be found for today\'s foods.\nTry refreshing or adding more specific food items.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 14, color: Colors.white54, height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      children: [
        // Header card
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withAlpha(40),
                  theme.colorScheme.primary.withAlpha(10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(60)),
            ),
            child: Row(
              children: [
                Icon(Icons.science,
                    color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateLabel,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white54)),
                    const Text(
                      "Micronutrient Summary",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Critical nutrients chips
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            'KEY NUTRIENTS',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        _buildCriticalChips(),

        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'FULL BREAKDOWN',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),

        // Full grouped list
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildFullList(),
          ),
        ),
      ],
    );
  }
}
