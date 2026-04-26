// lib/core/constants.dart

class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addTask = '/add-task';
}

// lib/core/constants.dart

// lib/core/constants.dart

class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8080/api';

  // AUTH
  static const String login = '/login';
  static const String register = '/register';
  static const String me = '/me';

  // FOLDER (MATKUL)
  static const String matkul = '/matkul';

  // TASK
  static const String tasks = '/tasks';
  static const String taskById = '/tasks/:id';

  // DEADLINE
  static const String deadlines = '/deadlines';
}

class StorageKeys {
  StorageKeys._();
  static const String accessToken = 'access_token';
  static const String userId = 'user_id';
}

class AppStrings {
  AppStrings._();
  static const String appName = 'FocusFlow';
  static const String loginTitle = 'Selamat Datang\nKembali !';
  static const String registerTitle = 'Ayo Mulai Fokus!\nDaftar akun barumu.';
  static const String inboxBanner = 'Kotak masuk adalah pusat sementara';
  static const String inboxSubtitle =
      'Inspirasi tiba-tiba, tugas yang belum\nterklasifikasi – semuanya dapat dicatat di sini.';
}
