import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Dio get _dio => ApiClient.instance.dio;

  // ─────────────────────────────────────────
  // AUTO LOGIN
  // ─────────────────────────────────────────
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.accessToken);

    if (token == null || token.isEmpty) return false;

    try {
      final resp = await _dio.get(ApiEndpoints.me);

      final data = resp.data['data']; // ✅ WAJIB

      _currentUser = UserModel.fromJson(
        data as Map<String, dynamic>,
      );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("AUTO LOGIN ERROR: $e");
      return false;
    }
  }

  // ─────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────
  Future<String?> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final resp = await _dio.post(
        ApiEndpoints.login,
        data: LoginRequest(
          email: email,
          password: password,
        ).toJson(),
      );

      // 🔍 DEBUG (boleh dihapus nanti)
      debugPrint("LOGIN RAW: ${resp.data}");

      final data = resp.data['data']; // ✅ WAJIB

      final auth = AuthResponse.fromJson(
        data as Map<String, dynamic>,
      );

      debugPrint("TOKEN: ${auth.accessToken}");
      debugPrint("USER: ${auth.user.email}");

      await _persistTokens(auth);

      _currentUser = auth.user;

      notifyListeners();
      return null;
    } on DioException catch (e) {
      _error = _parseError(e);
      return _error;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      return _error;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────
  Future<String?> register(
    String email,
    String password, {
    String? name,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final resp = await _dio.post(
        ApiEndpoints.register,
        data: RegisterRequest(
          email: email,
          password: password,
          name: name,
        ).toJson(),
      );

      final data = resp.data['data']; // ✅ WAJIB

      final auth = AuthResponse.fromJson(
        data as Map<String, dynamic>,
      );

      await _persistTokens(auth);

      _currentUser = auth.user;

      notifyListeners();
      return null;
    } on DioException catch (e) {
      _error = _parseError(e);
      return _error;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  Future<void> logout() async {
    await _clearStorage();
    _currentUser = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _persistTokens(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      StorageKeys.accessToken,
      auth.accessToken,
    );

    await prefs.setString(
      StorageKeys.userId,
      auth.user.id,
    );
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.userId);
  }

  String _parseError(DioException e) {
    final data = e.response?.data;

    if (data is Map && data.containsKey('message')) {
      return data['message'].toString();
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Server tidak terjangkau.';
    }

    return 'Terjadi kesalahan sistem.';
  }
}