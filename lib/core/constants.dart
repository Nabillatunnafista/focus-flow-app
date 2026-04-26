// lib/core/constants.dart

class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addTask = '/add-task';
}

class ApiEndpoints {
  ApiEndpoints._();
  static const String baseUrl =
      'http://localhost:8080/api'; // Ganti IP sesuai kebutuhan

  // ──── AUTH (Public) ────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';

  // ──── USER (Protected) ─────────────────────────────────────
  static const String me = '/me';

  // ──── MATKUL / COURSES (Protected) ─────────────────────────
  static const String matkul = '/matkul';
  static const String listMatkul = '/matkul';
  static const String createMatkul = '/matkul';
  static const String updateMatkul = '/matkul/:id';

  // ──── TASKS (Protected) ────────────────────────────────────
  static const String tasks = '/tasks';
  static const String listTasks = '/tasks';
  static const String createTask = '/tasks';
  static const String updateTask = '/tasks/:id';
  static const String deleteTask = '/tasks/:id';

  // ──── DEADLINES (Protected) ────────────────────────────────
  static const String deadlines = '/deadlines';
  static const String listDeadlines = '/deadlines';
  static const String createDeadline = '/deadlines';
  static const String updateDeadline = '/deadlines/:id';
  static const String toggleDeadline = '/deadlines/:id/toggle';
  static const String deleteDeadline = '/deadlines/:id';
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
