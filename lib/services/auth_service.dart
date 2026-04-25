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

  // ── Mode Dummy untuk Testing UI ──────────────────────
  // Ubah ke 'false' jika backend Golang sudah running
  final bool _useMock = false; 

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.accessToken);
    if (token == null || token.isEmpty) return false;

    if (_useMock) {
      _currentUser = UserModel(id: '1', email: 'user@test.com', name: 'Fista');
      notifyListeners();
      return true;
    }

    try {
      final resp = await _dio.get(ApiEndpoints.me);
      _currentUser = UserModel.fromJson(resp.data as Map<String, dynamic>);
      notifyListeners();
      return true;
    } catch (_) {
      await _clearStorage();
      return false;
    }
  }

  Future<String?> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    if (_useMock) {
      await Future.delayed(const Duration(seconds: 2)); // simulasi loading
      _currentUser = UserModel(id: '1', email: email, name: 'Fista');
      notifyListeners();
      _setLoading(false);
      return null;
    }

    try {
      final resp = await _dio.post(
        ApiEndpoints.login,
        data: LoginRequest(email: email, password: password).toJson(),
      );
      print("=== LOGIN RESPONSE ===");
print(resp.data);
      final auth = AuthResponse.fromJson(resp.data as Map<String, dynamic>);
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

  Future<String?> register(String email, String password, {String? name}) async {
    _setLoading(true);
    _error = null;

    // ── LOGIKA MOCK (AGAR BISA MASUK DASHBOARDTanpa Server) ──
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 2)); 
      _currentUser = UserModel(id: '1', email: email, name: name ?? 'User Baru');
      notifyListeners();
      _setLoading(false);
      return null; // Mengembalikan null dianggap sukses
    }

    try {
      final resp = await _dio.post(
        ApiEndpoints.register,
        data: RegisterRequest(email: email, password: password, name: name).toJson(),
      );
      final auth = AuthResponse.fromJson(resp.data as Map<String, dynamic>);
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

  Future<void> logout() async {
    await _clearStorage();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _persistTokens(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.accessToken, auth.accessToken);
    if (auth.refreshToken != null) {
      await prefs.setString(StorageKeys.refreshToken, auth.refreshToken!);
    }
    await prefs.setString(StorageKeys.userId, auth.user.id);
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.refreshToken);
    await prefs.remove(StorageKeys.userId);
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('message')) {
      return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout, coba lagi.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server.';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}