import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/stats_provider.dart';
import '../widgets/weekly_volume_chart.dart';
import '../widgets/nutrition_trend_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().loadAllStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<StatsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load stats',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadAllStats(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAllStats(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle(theme, 'Weekly Volume'),
                Container(
                  height: 250,
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withAlpha(51),
                    ),
                  ),
                  child: WeeklyVolumeChart(data: provider.weeklyVolume),
                ),
                const SizedBox(height: 32),
                
                _buildSectionTitle(theme, 'Nutrition Trend'),
                Container(
                  height: 250,
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withAlpha(51),
                    ),
                  ),
                  child: NutritionTrendChart(data: provider.nutritionTrend),
                ),
                const SizedBox(height: 32),

                _buildSectionTitle(theme, 'Personal Records'),
                if (provider.personalRecords.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'No personal records yet',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withAlpha(51),
                      ),
                    ),
                    child: Column(
                      children: provider.personalRecords.map((pr) {
                        final isLast = pr == provider.personalRecords.last;
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary.withAlpha(51),
                                child: Icon(
                                  Icons.emoji_events,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                pr.exerciseName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                DateFormat('MMM d, yyyy').format(pr.dateAchieved),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withAlpha(153),
                                ),
                              ),
                              trailing: Text(
                                '${pr.maxWeight} kg',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                height: 1,
                                color: theme.colorScheme.outline.withAlpha(26),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
