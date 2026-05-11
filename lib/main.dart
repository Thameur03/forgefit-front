import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Core
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';

// Providers
import 'features/auth/providers/auth_provider.dart';
import 'features/workout/providers/workout_provider.dart';
import 'features/workout/providers/program_provider.dart';
import 'features/workout/providers/schedule_provider.dart';
import 'features/nutrition/providers/nutrition_provider.dart';
import 'features/progress/providers/stats_provider.dart';
import 'features/auth/providers/onboarding_provider.dart';

// Screens
import 'features/home/screens/home_screen.dart';
import 'features/workout/screens/workout_detail_screen.dart';
import 'features/workout/screens/log_workout_screen.dart';
import 'features/nutrition/screens/food_search_screen.dart';
import 'features/nutrition/screens/add_food_screen.dart';
import 'features/nutrition/screens/food_detail_screen.dart';
import 'features/nutrition/screens/macro_targets_screen.dart';
import 'features/nutrition/screens/barcode_scanner_screen.dart';
import 'features/nutrition/screens/micronutrient_dashboard_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/email_password_screen.dart';
import 'features/auth/screens/profile_summary_screen.dart';
import 'features/auth/screens/physical_metrics_screen.dart';
import 'features/auth/screens/fitness_level_screen.dart';
import 'features/auth/screens/email_verification_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/reset_password_screen.dart';
import 'features/auth/widgets/onboarding_widgets.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/statistics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize core dependencies
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage: tokenStorage);

  // Initialize AuthProvider early to check status before building app
  final authProvider = AuthProvider(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
  
  // Check if user is already logged in
  final isLoggedIn = await authProvider.checkAuthStatus();

  runApp(ForgeFitApp(
    tokenStorage: tokenStorage,
    apiClient: apiClient,
    authProvider: authProvider,
    initialRoute: isLoggedIn ? '/home' : '/login',
  ));
}

class ForgeFitApp extends StatelessWidget {
  final TokenStorage tokenStorage;
  final ApiClient apiClient;
  final AuthProvider authProvider;
  final String initialRoute;

  const ForgeFitApp({
    super.key,
    required this.tokenStorage,
    required this.apiClient,
    required this.authProvider,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ProgramProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => NutritionProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => StatsProvider(apiClient: apiClient),
        ),
      ],
      child: MaterialApp(
        title: 'AthleteLab',
        debugShowCheckedModeBanner: false,
        theme: _buildDarkFitnessTheme(),
        initialRoute: initialRoute,
        onGenerateRoute: _generateRoute,
        builder: (context, child) {
          return MultiProvider(
            providers: [
              Provider.value(value: context.read<ApiClient>()),
              ChangeNotifierProvider.value(
                  value: context.read<AuthProvider>()),
              ChangeNotifierProvider.value(
                  value: context.read<WorkoutProvider>()),
              ChangeNotifierProvider.value(
                  value: context.read<ProgramProvider>()),
              ChangeNotifierProvider.value(
                  value: context.read<ScheduleProvider>()),
              ChangeNotifierProvider.value(
                  value: context.read<NutritionProvider>()),
              ChangeNotifierProvider.value(
                  value: context.read<StatsProvider>()),
              ChangeNotifierProvider.value(
                  value: context.read<OnboardingProvider>()),
            ],
            child: child!,
          );
        },
      ),
    );
  }

  ThemeData _buildDarkFitnessTheme() {
    const primaryColor = Color(0xFF3B82F6);
    const secondaryColor = Color(0xFF2563EB);
    const backgroundColor = Color(0xFF0B1220);
    const surfaceColor = Color(0xFF111827);
    const unselectedColor = Color(0xFF6B7280);

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: Color(0xFFCF6679),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14),
        labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: unselectedColor,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(51)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return buildSlideRoute(const EmailPasswordScreen());
      case '/personal-info':
        return buildSlideRoute(const RegisterScreen());
      case '/physical-metrics':
        return buildSlideRoute(const PhysicalMetricsScreen());
      case '/fitness-level':
        return buildSlideRoute(const FitnessLevelScreen());
      case '/profile-summary':
        return buildSlideRoute(const ProfileSummaryScreen());
      case '/verify-email':
        final email = settings.arguments as String? ?? '';
        return buildSlideRoute(EmailVerificationScreen(email: email));
      case '/forgot-password':
        return buildSlideRoute(const ForgotPasswordScreen());
      case '/reset-password':
        final email = settings.arguments as String? ?? '';
        return buildSlideRoute(ResetPasswordScreen(email: email));
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/log-workout':
        return MaterialPageRoute(builder: (_) => const LogWorkoutScreen());
      case '/workout-detail':
        final workoutId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => WorkoutDetailScreen(workoutId: workoutId),
        );
      case '/log-food':
        return MaterialPageRoute(builder: (_) => const FoodSearchScreen());
      case '/nutrition/add-food':
        final meal = settings.arguments as String? ?? 'breakfast';
        return MaterialPageRoute(
          builder: (_) => AddFoodScreen(initialMeal: meal),
        );
      case '/nutrition/food-detail':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => FoodDetailScreen(
            foodData: args['foodData'] as Map<String, dynamic>,
            targetMeal: args['targetMeal'] as String? ?? 'breakfast',
          ),
        );
      case '/nutrition/macro-targets':
        return MaterialPageRoute(
          builder: (_) => const MacroTargetsScreen(),
        );
      case '/nutrition/barcode-scanner':
        return MaterialPageRoute(
          builder: (_) => const BarcodeScannerScreen(),
        );
      case '/profile/statistics':
        return MaterialPageRoute(
          builder: (_) => const StatisticsScreen(),
        );
      case '/profile/edit':
        return buildSlideRoute(const EditProfileScreen());
      case '/nutrition/micronutrients':
        return MaterialPageRoute(
          builder: (_) => const MicronutrientDashboardScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
