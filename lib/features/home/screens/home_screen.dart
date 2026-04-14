import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../../nutrition/providers/nutrition_provider.dart';
import '../../progress/providers/stats_provider.dart';
import '../../workout/screens/workout_list_screen.dart';
import '../../nutrition/screens/nutrition_screen.dart';
import '../widgets/greeting_header.dart';
import '../widgets/today_summary_card.dart';
import '../widgets/todays_focus_card.dart';
import '../widgets/nutrition_snapshot_widget.dart';

// Placeholder widgets until other features are built
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _switchToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      _HomeTab(onSwitchTab: _switchToTab),
      const WorkoutListScreen(),
      const NutritionScreen(),
      const _PlaceholderScreen('Profile Tab'),
    ];

    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          border: Border(
            top: BorderSide(
              color: OnboardingTheme.border,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: OnboardingTheme.card,
            selectedItemColor: OnboardingTheme.accent,
            unselectedItemColor: Colors.white38,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_outlined),
                activeIcon: Icon(Icons.fitness_center),
                label: 'Workouts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_outlined),
                activeIcon: Icon(Icons.restaurant),
                label: 'Nutrition',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final void Function(int) onSwitchTab;

  const _HomeTab({required this.onSwitchTab});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _ringController;
  late Animation<double> _ringAnimation;

  late AnimationController _barController;
  late Animation<double> _barAnimation;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Page fade-in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Ring animation
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _ringAnimation = CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeOutCubic,
    );

    // Nutrition bar animation
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _barAnimation = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutCubic,
    );

    _loadData();
  }

  Future<void> _loadData() async {
    final nutritionProvider = context.read<NutritionProvider>();
    final statsProvider = context.read<StatsProvider>();

    try {
      await Future.wait([
        nutritionProvider.loadTodayNutrition(),
        statsProvider.loadWorkoutStats(),
      ]);
    } catch (_) {
      // Swallow errors — show zero values
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _fadeController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) _ringController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) _barController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _ringController.dispose();
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final userName = user?.fullName.split(' ').first ?? 'Athlete';
    final nutritionProvider = context.watch<NutritionProvider>();
    final statsProvider = context.watch<StatsProvider>();

    final summary = nutritionProvider.todaySummary;
    final totalCalories = (summary?.totalCalories ?? 0).round();
    final totalProtein = summary?.totalProtein ?? 0.0;
    final totalCarbs = summary?.totalCarbs ?? 0.0;
    final totalFat = summary?.totalFat ?? 0.0;
    final streakDays = statsProvider.currentStreakDays;

    if (_isLoading) {
      return _buildShimmer();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1 — Greeting Header
            GreetingHeader(
              userName: userName,
              streakDays: streakDays,
            ),
            const SizedBox(height: 28),

            // Section 2 — Today's Progress (4 rings)
            TodaySummaryCard(
              calories: totalCalories,
              ringAnimation: _ringAnimation,
            ),
            const SizedBox(height: 28),

            // Section 3 — Today's Focus
            TodaysFocusCard(
              onStartWorkout: () => widget.onSwitchTab(1),
            ),
            const SizedBox(height: 28),

            // Section 4 — Nutrition Snapshot
            NutritionSnapshotWidget(
              protein: totalProtein,
              carbs: totalCarbs,
              fat: totalFat,
              onLogMeal: () => widget.onSwitchTab(2),
              animation: _barAnimation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(180, 36),
          const SizedBox(height: 8),
          _shimmerBox(120, 24),
          const SizedBox(height: 32),
          _shimmerBox(double.infinity, 20),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (_) => _shimmerCircle(72),
            ),
          ),
          const SizedBox(height: 32),
          _shimmerBox(double.infinity, 180),
          const SizedBox(height: 16),
          _shimmerBox(double.infinity, 50),
          const SizedBox(height: 32),
          _shimmerBox(double.infinity, 20),
          const SizedBox(height: 12),
          _shimmerBox(double.infinity, 30),
          const SizedBox(height: 10),
          _shimmerBox(double.infinity, 30),
          const SizedBox(height: 10),
          _shimmerBox(double.infinity, 30),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _shimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: OnboardingTheme.card,
        shape: BoxShape.circle,
      ),
    );
  }
}
