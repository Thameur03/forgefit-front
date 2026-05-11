import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  AuthProvider({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Extract a human-readable error message from a DioException.
  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      if (detail is List && detail.isNotEmpty) {
        return detail.map((d) => d['msg'] ?? d.toString()).join(', ');
      }
      return detail.toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connection timed out. Check your internet and try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  // ═══════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      _isLoggedIn = true;
      await getCurrentUser();
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      // Special handling for 403 (unverified email)
      if (e.response?.statusCode == 403) {
        _setError(e.response?.data?['detail'] ?? 'Please verify your email before logging in.');
      } else {
        _setError(_extractError(e));
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REGISTER
  // ═══════════════════════════════════════════════════════════

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    DateTime? dateOfBirth,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? fitnessLevel,
  }) async {
    _setLoading(true);
    _setError(null);

    // Wake Railway from cold sleep first
    await _apiClient.wakeServer();

    final body = {
      'email': email,
      'password': password,
      'full_name': fullName,
      if (dateOfBirth != null)
        'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      if (gender != null) 'gender': gender.toLowerCase(),
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (fitnessLevel != null) 'fitness_level': fitnessLevel.toLowerCase(),
    };

    int attempts = 0;
    while (attempts < 2) {
      try {
        await _apiClient.dio.post(
          ApiConstants.register,
          data: body,
          options: Options(
            receiveTimeout: const Duration(seconds: 90),
            sendTimeout: const Duration(seconds: 90),
          ),
        );
        _setLoading(false);
        return true;
      } on DioException catch (e) {
        if ((e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout) &&
            attempts == 0) {
          attempts++;
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          _setError('Connection timed out. Check your internet and try again.');
        } else if (e.response?.statusCode == 422) {
          _setError('Please check your information and try again.');
        } else if (e.response?.statusCode == 409 ||
            e.response?.statusCode == 400) {
          _setError(
              'Account may already exist. Please try logging in with your email.');
        } else {
          _setError(_extractError(e));
        }
        _setLoading(false);
        return false;
      } catch (e) {
        _setError(e.toString());
        _setLoading(false);
        return false;
      }
    }

    _setLoading(false);
    return false;
  }

  // ═══════════════════════════════════════════════════════════
  // EMAIL VERIFICATION
  // ═══════════════════════════════════════════════════════════

  Future<bool> verifyEmail(String email, String code) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.post(
        ApiConstants.verifyEmail,
        data: {'email': email, 'code': code},
      );
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendVerificationCode(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.post(
        ApiConstants.resendVerificationCode,
        data: {'email': email},
      );
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PASSWORD RECOVERY
  // ═══════════════════════════════════════════════════════════

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(
      String email, String code, String newPassword) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
        },
      );
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // USER SESSION
  // ═══════════════════════════════════════════════════════════

  Future<void> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConstants.me);
      _currentUser = UserModel.fromJson(response.data);
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (_) {
      // Proceed with local logout even if API call fails
    }
    await _tokenStorage.clearTokens();
    _currentUser = null;
    _isLoggedIn = false;
    _setLoading(false);
  }

  Future<bool> checkAuthStatus() async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      await getCurrentUser();
      return _isLoggedIn;
    }
    return false;
  }
}
