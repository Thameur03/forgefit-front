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

  // Programs
  static const String programTemplates = '/programs/templates';
  static const String programs = '/programs/';
  static const String programsActive = '/programs/active';
}
