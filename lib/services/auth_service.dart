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

  // Set false agar langsung konek ke Gin 
  final bool _useMock = false; 

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.accessToken);
    if (token == null || token.isEmpty) return false;

    try {
      // Mengambil data user yang sedang login
      final resp = await _dio.get(ApiEndpoints.me);
      _currentUser = UserModel.fromJson(resp.data as Map<String, dynamic>);
      notifyListeners();
      return true;
    } catch (_) {
      // Jika token expired atau server mati, jangan paksa login
      return false;
    }
  }

  Future<String?> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final resp = await _dio.post(
        ApiEndpoints.login,
        data: LoginRequest(email: email, password: password).toJson(),
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

  Future<String?> register(String email, String password, {String? name}) async {
    _setLoading(true);
    _error = null;

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
    await prefs.setString(StorageKeys.userId, auth.user.id);
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.userId);
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('message')) return data['message'].toString();
    if (e.type == DioExceptionType.connectionError) return 'Server Gin tidak terjangkau. Cek IP!';
    return 'Terjadi kesalahan sistem.';
  }
}