import 'package:flutter/material.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../../workout/screens/workout_list_screen.dart';
import '../../nutrition/screens/nutrition_screen.dart';
import '../../progress/screens/progress_analytics_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index.clamp(0, 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const WorkoutListScreen(),
      const NutritionScreen(),
      const ProgressAnalyticsScreen(),
      const ProfileScreen(),
    ];

    final safeIndex = _selectedIndex.clamp(0, screens.length - 1);

    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: safeIndex,
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
            currentIndex: safeIndex,
            onTap: _onItemTapped,
            backgroundColor: OnboardingTheme.card,
            selectedItemColor: OnboardingTheme.accent,
            unselectedItemColor: Colors.white38,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
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
                icon: Icon(Icons.bar_chart_rounded),
                activeIcon: Icon(Icons.bar_chart_rounded),
                label: 'Analytics',
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
