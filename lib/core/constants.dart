// lib/core/constants.dart

class AppRoutes {
  AppRoutes._();
  static const String splash   = '/';
  static const String login    = '/login';
  static const String register = '/register';
  static const String home     = '/home';
}

class ApiEndpoints {
  ApiEndpoints._();

  /// Base URL — ganti dengan URL Backend Golang Anda
  static const String baseUrl  = 'http://localhost:8080/api/v1';

  // Auth
  static const String login    = '/auth/login';
  static const String register = '/auth/register';
  static const String me       = '/auth/me';

  // Tasks
  static const String tasks    = '/tasks';          // GET (list), POST (create)
  static const String taskById = '/tasks/:id';      // GET, PUT, DELETE
  static const String taskDone = '/tasks/:id/done'; // PATCH

  // Deadlines
  static const String deadlines = '/deadlines/today'; // GET
}

class StorageKeys {
  StorageKeys._();
  static const String accessToken  = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId       = 'user_id';
}

class AppStrings {
  AppStrings._();
  static const String appName       = 'FocusFlow';
  static const String tagline       = 'Smart Study Planner for Students';
  static const String loginTitle    = 'Selamat Datang\nKembali !';
  static const String registerTitle = 'Ayo Mulai Fokus!\nDaftar akun barumu.';
  static const String inboxBanner   = 'Kotak masuk adalah pusat sementara';
  static const String inboxSubtitle =
      'Inspirasi tiba-tiba, tugas yang belum\nterklasifikasi – semuanya dapat dicatat di sini.';
}