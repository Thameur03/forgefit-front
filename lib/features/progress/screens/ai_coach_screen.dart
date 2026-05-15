import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/widgets/onboarding_widgets.dart';
import '../models/ai_coach_model.dart';
import '../providers/ai_coach_provider.dart';

// ── Lab Insights content (third tab inside Progress & Analytics) ─────────
class AICoachContent extends StatefulWidget {
  const AICoachContent({super.key});

  @override
  State<AICoachContent> createState() => _AICoachContentState();
}

class _AICoachContentState extends State<AICoachContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AICoachProvider>().loadSummary(days: 7);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AICoachProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const _LoadingState();
        }
        if (provider.error != null) {
          return _ErrorState(
            error: provider.error!,
            onRetry: () => provider.loadSummary(days: 7, forceRefresh: true),
          );
        }
        if (provider.summary == null) {
          return const _EmptyState();
        }
        return _SummaryView(summary: provider.summary!);
      },
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: OnboardingTheme.accent,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Analyzing your data…',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 44),
            const SizedBox(height: 12),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: OnboardingTheme.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_rounded, color: Colors.white24, size: 56),
            SizedBox(height: 12),
            Text('No insight data yet.',
                style: TextStyle(color: Colors.white54, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ── Main summary view ────────────────────────────────────────────────────
class _SummaryView extends StatelessWidget {
  final AICoachSummaryModel summary;
  const _SummaryView({required this.summary});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReadinessScoreCard(summary: summary),
          const SizedBox(height: 16),
          _SubScoreRow(summary: summary),
          const SizedBox(height: 12),
          _ConfidenceChip(
            confidence: summary.confidence,
            reason: summary.confidenceReason,
          ),
          const SizedBox(height: 16),
          _CoachSummaryCard(text: summary.summary),
          if (summary.nextBestAction != null) ...[
            const SizedBox(height: 14),
            _NextBestActionCard(action: summary.nextBestAction!),
          ],
          if (summary.warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            _WarningsSection(warnings: summary.warnings),
          ],
          if (summary.recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            _RecommendationsSection(recommendations: summary.recommendations),
          ],
          if (summary.missingData.isNotEmpty) ...[
            const SizedBox(height: 16),
            _MissingDataCard(items: summary.missingData),
          ],
          const SizedBox(height: 16),
          _DisclaimerCard(text: summary.disclaimer),
        ],
      ),
    );
  }
}

// ── Weekly Readiness Score Card ───────────────────────────────────────────
class _ReadinessScoreCard extends StatelessWidget {
  final AICoachSummaryModel summary;
  const _ReadinessScoreCard({required this.summary});

  Color _scoreColor(int score) {
    if (score >= 85) return const Color(0xFF00C853);
    if (score >= 70) return const Color(0xFF66BB6A);
    if (score >= 50) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(summary.overallScore);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            OnboardingTheme.cardDark,
            color.withAlpha(30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          const Text(
            'Weekly Readiness Score',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${summary.overallScore}',
            style: TextStyle(
              color: color,
              fontSize: 56,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withAlpha(60)),
            ),
            child: Text(
              summary.readinessLabel,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-Score Row ─────────────────────────────────────────────────────────
class _SubScoreRow extends StatelessWidget {
  final AICoachSummaryModel summary;
  const _SubScoreRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniScoreCard(
            label: 'Training',
            score: summary.trainingScore,
            icon: Icons.fitness_center_rounded,
            color: const Color(0xFF42A5F5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniScoreCard(
            label: 'Nutrition',
            score: summary.nutritionScore,
            icon: Icons.restaurant_rounded,
            color: const Color(0xFF66BB6A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniScoreCard(
            label: 'Recovery',
            score: summary.recoveryScore,
            icon: Icons.favorite_rounded,
            color: const Color(0xFFFFA726),
          ),
        ),
      ],
    );
  }
}

class _MiniScoreCard extends StatelessWidget {
  final String label;
  final int score;
  final IconData icon;
  final Color color;
  const _MiniScoreCard({
    required this.label,
    required this.score,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            '$score',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confidence Chip ──────────────────────────────────────────────────────
class _ConfidenceChip extends StatelessWidget {
  final String confidence;
  final String reason;
  const _ConfidenceChip({required this.confidence, required this.reason});

  Color _chipColor() {
    switch (confidence) {
      case 'high':
        return const Color(0xFF00C853);
      case 'medium':
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFFEF5350);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _chipColor();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            'Confidence: ${confidence[0].toUpperCase()}${confidence.substring(1)}',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              reason,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coach Summary Card ───────────────────────────────────────────────────
class _CoachSummaryCard extends StatelessWidget {
  final String text;
  const _CoachSummaryCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Coach Summary',
      icon: Icons.auto_awesome_rounded,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
      ),
    );
  }
}

// ── Next Best Action Card ────────────────────────────────────────────────
class _NextBestActionCard extends StatelessWidget {
  final String action;
  const _NextBestActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.accent.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: OnboardingTheme.accent.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.rocket_launch_rounded,
                color: OnboardingTheme.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Best Action',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Warnings Section ─────────────────────────────────────────────────────
class _WarningsSection extends StatelessWidget {
  final List<AICoachWarning> warnings;
  const _WarningsSection({required this.warnings});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Recovery Warnings',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFFFB74D),
      child: Column(
        children: warnings.map((w) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_rounded,
                    color: Color(0xFFFFB74D), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 2),
                      Text(w.detail,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Recommendations Section ──────────────────────────────────────────────
class _RecommendationsSection extends StatelessWidget {
  final List<AICoachRecommendation> recommendations;
  const _RecommendationsSection({required this.recommendations});

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return const Color(0xFFEF5350);
      case 'medium':
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFF66BB6A);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'workout':
        return Icons.fitness_center_rounded;
      case 'nutrition':
        return Icons.restaurant_rounded;
      case 'recovery':
        return Icons.favorite_rounded;
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Recommendations',
      icon: Icons.lightbulb_outline_rounded,
      child: Column(
        children: recommendations.asMap().entries.map((entry) {
          final rec = entry.value;
          final color = _priorityColor(rec.priority);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withAlpha(10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_categoryIcon(rec.category),
                        color: color, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec.title,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rec.priority.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(rec.reason,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12, height: 1.4)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(rec.action,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Missing Data Card ────────────────────────────────────────────────────
class _MissingDataCard extends StatelessWidget {
  final List<String> items;
  const _MissingDataCard({required this.items});

  String _readableLabel(String key) {
    switch (key) {
      case 'workouts':
        return 'Workout data';
      case 'nutrition_logs':
        return 'Nutrition logs';
      case 'bodyweight':
        return 'Bodyweight in profile';
      case 'active_program':
        return 'Active training program';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Missing Data',
      icon: Icons.info_outline_rounded,
      iconColor: Colors.white38,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.remove_circle_outline,
                          color: Colors.white30, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _readableLabel(item),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── Disclaimer ───────────────────────────────────────────────────────────
class _DisclaimerCard extends StatelessWidget {
  final String text;
  const _DisclaimerCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gpp_good_outlined, color: Colors.white24, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Generic Section Card ─────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
