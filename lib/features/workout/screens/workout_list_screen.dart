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
                  _iconButton(Icons.search, () => _showComingSoon('Search')),
                  const SizedBox(width: 4),
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
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: OnboardingTheme.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: OnboardingTheme.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
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
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: LibraryTab.hardcodedPrograms.length,
                  itemBuilder: (context, index) {
                    final p = LibraryTab.hardcodedPrograms[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(ctx);
                          final nav = Navigator.of(this.context);
                          final provider = this.context.read<ProgramProvider>();
                          // Show loading
                          showDialog(
                            context: this.context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(color: OnboardingTheme.accent),
                            ),
                          );
                          final slug = LibraryTab.hardcodedPrograms[index]['slug']!;
                          final program = await provider.adoptTemplate(slug);
                          nav.pop(); // dismiss loader
                          if (program != null) {
                            nav.push(
                              MaterialPageRoute(
                                builder: (_) => ProgramDetailScreen(programId: program.id),
                              ),
                            );
                          }
                        },
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
                                    Text(
                                      p['name']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${p['duration']}  •  ${p['frequency']}',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.add_circle, color: OnboardingTheme.accent, size: 24),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

