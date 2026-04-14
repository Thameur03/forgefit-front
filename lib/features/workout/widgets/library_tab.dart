import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../providers/program_provider.dart';
import '../screens/program_detail_screen.dart';


class LibraryTab extends StatefulWidget {
  final void Function(String) onShowComingSoon;

  const LibraryTab({super.key, required this.onShowComingSoon});

  // Keep this for the templates bottom sheet used elsewhere
  static const hardcodedPrograms = [
    {'name': 'Push Pull Legs', 'duration': '6 Weeks', 'frequency': '3x per week', 'slug': 'push_pull_legs'},
    {'name': 'Bro Split', 'duration': '8 Weeks', 'frequency': '5x per week', 'slug': 'bro_split'},
    {'name': 'Full Body', 'duration': '4 Weeks', 'frequency': '2x per week', 'slug': 'full_body'},
    {'name': 'Upper Lower', 'duration': '12 Weeks', 'frequency': '4x per week', 'slug': 'upper_lower'},
    {'name': 'Powerlifting Peaking', 'duration': '8 Weeks', 'frequency': '4x per week', 'slug': 'powerlifting_peaking'},
    {'name': 'Starting Strength', 'duration': 'Unknown', 'frequency': '3x per week', 'slug': 'starting_strength'},
  ];

  @override
  State<LibraryTab> createState() => LibraryTabState();
}

class LibraryTabState extends State<LibraryTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramProvider>().loadPrograms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgramProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.programs.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: OnboardingTheme.accent),
          );
        }

        if (provider.programs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center,
                      color: Colors.white.withAlpha(40), size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'No programs yet.\nTap + to browse templates or create your own.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: provider.programs.length,
          itemBuilder: (context, index) {
            final p = provider.programs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () async {
                  final programProvider = context.read<ProgramProvider>();
                  final refreshed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProgramDetailScreen(programId: p.id),
                    ),
                  );
                  if (refreshed == true) {
                    programProvider.loadPrograms();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OnboardingTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: p.isActive
                          ? OnboardingTheme.accent.withAlpha(120)
                          : OnboardingTheme.border,
                    ),
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
                                    p.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (p.isActive) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: OnboardingTheme.success.withAlpha(30),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: OnboardingTheme.success
                                              .withAlpha(80)),
                                    ),
                                    child: const Text('Active',
                                        style: TextStyle(
                                            color: OnboardingTheme.success,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.subtitle,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: Colors.white38, size: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTORY TAB
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

