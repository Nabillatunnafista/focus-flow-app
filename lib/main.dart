// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import lokalisasi resmi Flutter

import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/tasks/task_list_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/local_profile_service.dart';
import 'services/notification_service.dart';
import 'services/task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // Inisialisasi data format tanggal bahasa Indonesia
  await initializeDateFormatting('id_ID', null);
  
  ApiClient.instance.init();
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();
  await LocalProfileService.instance.load();
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TaskService()),
        ChangeNotifierProvider.value(value: LocalProfileService.instance),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        
        // ── KONFIGURASI LOCALE BAHASA INDONESIA ──────────────────
        locale: const Locale('id', 'ID'),
        supportedLocales: const [
          Locale('id', 'ID'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // ──────────────────────────────────────────────────────────
        
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.taskList: (_) => const TaskListScreen(),
          AppRoutes.calendar: (_) => const CalendarScreen(),
          AppRoutes.notifications: (_) => const NotificationsScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
        },
      ),
    );
  }
}