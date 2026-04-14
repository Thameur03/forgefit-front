import 'package:flutter/material.dart';
import 'auth_provider.dart';

/// Holds all data collected throughout the 5-step onboarding flow.
/// The actual [register] API call is deferred until Step 5 (profile summary).
class OnboardingProvider extends ChangeNotifier {
  // ── Step 1 ──────────────────────────────────────────────────────────────────
  String email = '';
  String password = '';

  // ── Step 2 ──────────────────────────────────────────────────────────────────
  String fullName = '';
  String dateOfBirth = '';
  String gender = 'Male';

  // ── Step 3 ──────────────────────────────────────────────────────────────────
  double heightCm = 170;
  double weightKg = 75;

  // ── Step 4 ──────────────────────────────────────────────────────────────────
  String fitnessLevel = 'Beginner';

  // ── Registration state ────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Calls [authProvider.register] with the email, password and full name
  /// collected during onboarding. Only invoked from the Profile Summary screen.
  Future<bool> register(AuthProvider authProvider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    bool success = false;
    try {
      success = await authProvider.register(
        email: email,
        password: password,
        fullName: fullName,
        dateOfBirth: dateOfBirth.isNotEmpty ? DateTime.tryParse(dateOfBirth) : null,
        gender: gender,
        weightKg: weightKg,
        heightCm: heightCm,
        fitnessLevel: fitnessLevel,
      ).timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          _errorMessage = 'Connection timed out. Check your internet and try again.';
          return false;
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      success = false;
    }

    _isLoading = false;
    if (!success && _errorMessage == null) {
      _errorMessage = authProvider.errorMessage;
    }
    notifyListeners();
    return success;
  }

  /// Resets all collected data after successful registration.
  void reset() {
    email = '';
    password = '';
    fullName = '';
    dateOfBirth = '';
    gender = 'Male';
    heightCm = 170;
    weightKg = 75;
    fitnessLevel = 'Beginner';
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
