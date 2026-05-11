class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://forgefit-back.onrender.com';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String authProfile = '/auth/profile';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerificationCode = '/auth/resend-verification-code';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Workouts
  static const String workouts = '/workouts/';

  // Exercises
  static const String exerciseSearch = '/exercises/search';
  static const String exerciseRecent = '/exercises/recent';

  // Nutrition
  static const String nutrition = '/nutrition/';
  static const String nutritionToday = '/nutrition/today';
  static const String nutritionHistory = '/nutrition/history';
  static const String nutritionDate = '/nutrition/date/';

  // Food
  static const String foodSearch = '/food/search';
  static const String foodNutrients = '/food/';


  // Stats
  static const String statsWorkouts = '/stats/workouts';
  static const String statsNutrition = '/stats/nutrition';
  static const String statsPersonalRecords = '/stats/personal-records';
  static const String statsWeeklyVolume = '/stats/weekly-volume';
  static const String statsNutritionTrend = '/stats/nutrition-trend';
  static const String statsMuscleVolume = '/stats/muscle-volume';

  // Programs
  static const String programTemplates = '/programs/templates';
  static const String programs = '/programs/';
  static const String programsActive = '/programs/active';

  // Schedule
  static const String schedule = '/schedule/';
  static const String scheduleToday = '/schedule/today';
  static const String scheduleMonth = '/schedule/month';
}
