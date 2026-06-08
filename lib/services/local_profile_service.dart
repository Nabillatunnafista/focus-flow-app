// lib/services/local_profile_service.dart
// Menyimpan foto profil & nama tampilan secara lokal di perangkat
// (dipakai sementara karena backend belum support endpoint avatar)

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProfileService extends ChangeNotifier {
  LocalProfileService._();
  static final LocalProfileService instance = LocalProfileService._();

  static const _keyAvatarPath = 'local_avatar_path';
  static const _keyDisplayName = 'local_display_name';

  String? _avatarPath;
  String? _displayName;

  String? get avatarPath => _avatarPath;
  String? get displayName => _displayName;

  /// Muat data dari SharedPreferences saat app start
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _avatarPath = prefs.getString(_keyAvatarPath);
    _displayName = prefs.getString(_keyDisplayName);
    notifyListeners();
  }

  /// Simpan path foto avatar lokal
  Future<void> saveAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatarPath, path);
    _avatarPath = path;
    notifyListeners();
  }

  /// Hapus foto avatar (reset ke inisial)
  Future<void> clearAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAvatarPath);
    _avatarPath = null;
    notifyListeners();
  }

  /// Simpan nama tampilan lokal
  Future<void> saveDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDisplayName, name.trim());
    _displayName = name.trim();
    notifyListeners();
  }

  /// Hapus semua data lokal (dipanggil saat logout)
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAvatarPath);
    await prefs.remove(_keyDisplayName);
    _avatarPath = null;
    _displayName = null;
    notifyListeners();
  }
}
