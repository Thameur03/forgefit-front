import 'package:flutter/material.dart';
import '../../auth/widgets/onboarding_widgets.dart';

class GreetingHeader extends StatelessWidget {
  final String userName;
  final int streakDays;

  const GreetingHeader({
    super.key,
    required this.userName,
    required this.streakDays,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning,';
    if (hour >= 12 && hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                '${_getGreeting()} 🔥',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              '$streakDays-Day Streak',
              style: const TextStyle(
                color: OnboardingTheme.accent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
