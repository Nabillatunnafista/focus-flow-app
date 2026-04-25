// lib/core/constants.dart

class AppRoutes {
  AppRoutes._();
  static const String splash   = '/';
  static const String login    = '/login';
  static const String register = '/register';
  static const String home     = '/home';
  static const String addTask  = '/add-task';
}

class ApiEndpoints {
  ApiEndpoints._();
  static const String baseUrl = 'http://localhost:8080/api'; // Ganti IP 
  static const String login    = '/login';
  static const String register = '/register';
  static const String me       = '/me';

  static const String tasks    = '/matkul'; 
  static const String taskDone = '/matkul/:id/done';
  static const String deadlines = '/deadlines';
}

class StorageKeys {
  StorageKeys._();
  static const String accessToken  = 'access_token';
  static const String userId       = 'user_id';
}

class AppStrings {
  AppStrings._();
  static const String appName       = 'FocusFlow'; 
  static const String loginTitle    = 'Selamat Datang\nKembali !';
  static const String registerTitle = 'Ayo Mulai Fokus!\nDaftar akun barumu.';
  static const String inboxBanner   = 'Kotak masuk adalah pusat sementara';
  static const String inboxSubtitle =
      'Inspirasi tiba-tiba, tugas yang belum\nterklasifikasi – semuanya dapat dicatat di sini.';
}