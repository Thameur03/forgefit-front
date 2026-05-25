import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/widgets/onboarding_widgets.dart';
import '../providers/workout_provider.dart';
import '../providers/program_provider.dart';

import 'calendar_screen.dart';


import 'program_detail_screen.dart';
import 'create_program_screen.dart';
import '../widgets/today_tab.dart';
import '../widgets/library_tab.dart';
import '../widgets/history_tab.dart';


class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen>
    with TickerProviderStateMixin {
  int _activeTab = 0; // 0=Today, 1=Library, 2=History
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadWorkouts();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _switchTab(int index) async {
    _fadeController.reverse();
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      setState(() => _activeTab = index);
      _fadeController.forward();
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
        backgroundColor: OnboardingTheme.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
              child: Row(
                children: [
                  Text(
                    _activeTab == 1 ? 'Programs' : 'Workouts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _iconButton(Icons.calendar_month, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CalendarScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sub-tab pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTabPills(),
            ),
            const SizedBox(height: 16),

            // Tab content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildTabContent(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _activeTab == 1 ? _buildLibraryFab() : null,
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
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
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildTabPills() {
    const tabs = ['Today', 'Library', 'History'];
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _activeTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchTab(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color:
                      isActive ? OnboardingTheme.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white60,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return TodayTab(
          onShowComingSoon: _showComingSoon,
          onSwitchToHistory: () => _switchTab(2),
          onViewPrograms: () {
            _switchTab(1);
            // Delay slightly to let the tab transition start/finish gracefully
            Future.delayed(const Duration(milliseconds: 250), () {
              if (mounted) _showCreateModal();
            });
          },
        );
      case 1:
        return LibraryTab(onShowComingSoon: _showComingSoon);
      case 2:
        return HistoryTab(onShowComingSoon: _showComingSoon);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget? _buildLibraryFab() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: OnboardingTheme.accent.withAlpha(120),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showCreateModal(),
        backgroundColor: OnboardingTheme.accent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewPadding.bottom;
        return SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: OnboardingTheme.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              (bottomInset > 0 ? bottomInset : 16) + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create or Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: OnboardingTheme.card,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white60, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _createModalOption(
                ctx,
                icon: Icons.edit_note,
                title: 'Create Custom Program',
                subtitle:
                    'Build your own training program from scratch. Design splits, sets, and progression logic.',
                onTapOverride: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateProgramScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _createModalOption(
                ctx,
                icon: Icons.description_outlined,
                title: 'Browse Templates',
                subtitle:
                    'Choose from structured training plans designed for strength, hypertrophy, or endurance.',
                onTapOverride: () {
                  Navigator.pop(ctx);
                  _showTemplatesBottomSheet();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _createModalOption(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTapOverride,
  }) {
    return GestureDetector(
      onTap: onTapOverride ?? () {
        Navigator.pop(ctx);
        _showComingSoon(title);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OnboardingTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: OnboardingTheme.accent.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: OnboardingTheme.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  void _showTemplatesBottomSheet() {
    // Trigger DB template load as soon as the sheet is requested.
    final programProvider = context.read<ProgramProvider>();
    programProvider.loadGlobalTemplates();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewPadding.bottom;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: OnboardingTheme.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Browse Templates',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: OnboardingTheme.card,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white60, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Consumer<ProgramProvider>(
                      builder: (_, provider, __) {
                        final hardcoded = LibraryTab.hardcodedPrograms;
                        final dbTemplates = provider.dbTemplates;
                        final totalCount = hardcoded.length + dbTemplates.length;

                        if (totalCount == 0 && provider.isLoadingDbTemplates) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: OnboardingTheme.accent,
                            ),
                          );
                        }

                        // ── Show error hint if DB templates failed to load ──────
                        final errorBanner = (provider.dbTemplatesError != null)
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                                child: Text(
                                  'Could not load AthleteLab templates',
                                  style: TextStyle(
                                    color: Colors.redAccent.withAlpha(200),
                                    fontSize: 11,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();

                        // ── Loading indicator for DB templates (non-blocking) ──
                        final loadingChip = provider.isLoadingDbTemplates
                            ? const Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        color: OnboardingTheme.accent,
                                        strokeWidth: 1.5,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Loading AthleteLab templates…',
                                      style: TextStyle(
                                          color: Colors.white38, fontSize: 11),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            loadingChip,
                            errorBanner,
                            Expanded(
                              child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: totalCount,
                          itemBuilder: (context, index) {
                            // First: hardcoded templates
                            if (index < hardcoded.length) {
                              final p = hardcoded[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _TemplateTile(
                                  name: p['name']!,
                                  subtitle: '${p['duration']}  •  ${p['frequency']}',
                                  badge: 'Built-in',
                                  badgeColor: Colors.white24,
                                  onTap: () async {
                                    Navigator.pop(ctx);
                                    final nav = Navigator.of(this.context);
                                    final messenger = ScaffoldMessenger.of(this.context);
                                    showDialog(
                                      context: this.context,
                                      barrierDismissible: false,
                                      builder: (_) => const Center(
                                        child: CircularProgressIndicator(
                                          color: OnboardingTheme.accent,
                                        ),
                                      ),
                                    );
                                    final slug = p['slug']!;
                                    final program = await provider.adoptTemplate(slug);
                                    nav.pop();
                                    if (program != null) {
                                      nav.push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ProgramDetailScreen(programId: program.id),
                                        ),
                                      );
                                    } else {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to add template.'),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            }

                            // Then: DB (admin-created) templates
                            final dbIndex = index - hardcoded.length;
                            final t = dbTemplates[dbIndex];
                            final sub = t.subtitle.isNotEmpty
                                ? t.subtitle
                                : '${t.days.length} Day${t.days.length == 1 ? '' : 's'}';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _TemplateTile(
                                name: t.name,
                                subtitle: sub,
                                badge: 'AthleteLab',
                                badgeColor: OnboardingTheme.accent.withAlpha(50),
                                badgeTextColor: OnboardingTheme.accent,
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  final nav = Navigator.of(this.context);
                                  final messenger = ScaffoldMessenger.of(this.context);
                                  showDialog(
                                    context: this.context,
                                    barrierDismissible: false,
                                    builder: (_) => const Center(
                                      child: CircularProgressIndicator(
                                        color: OnboardingTheme.accent,
                                      ),
                                    ),
                                  );
                                  final program = await provider.adoptDbTemplate(t.id);
                                  nav.pop();
                                  if (program != null) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Program added to your library'),
                                        backgroundColor: Color(0xFF1A2E1A),
                                      ),
                                    );
                                    nav.push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProgramDetailScreen(programId: program.id),
                                      ),
                                    );
                                  } else {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to add template.'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),   // Expanded
                          ],  // Column.children
                        );   // Column
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private template tile widget
// ─────────────────────────────────────────────────────────────────────────────

class _TemplateTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final VoidCallback onTap;

  const _TemplateTile({
    required this.name,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    this.badgeTextColor = Colors.white60,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OnboardingTheme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.add_circle,
                color: OnboardingTheme.accent, size: 24),
          ],
        ),
      ),
    );
  }
}


