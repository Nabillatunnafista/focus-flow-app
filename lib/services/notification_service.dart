// lib/services/notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    // Default local location ke Asia/Jakarta
    const String timeZoneName = 'Asia/Jakarta';
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Warning: Gagal menginisialisasi timezone $timeZoneName, menggunakan UTC: $e');
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Buat channel notifikasi untuk Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'deadline_reminders',
      'Deadline Reminders',
      description: 'Channel untuk pengingat deadline tugas',
      importance: Importance.max,
    );

    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
    }
  }

  Future<void> requestPermissions() async {
    try {
      final androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('Gagal meminta izin notifikasi: $e');
    }
  }

  Future<void> scheduleTaskReminder({
    required String id,
    required String title,
    required String folderName,
    required DateTime deadline,
    required int offsetMinutes,
  }) async {
    // Batalkan notifikasi lama terlebih dahulu jika ada
    await cancelTaskReminder(id);

    final reminderTime = deadline.subtract(Duration(minutes: offsetMinutes));
    if (reminderTime.isBefore(DateTime.now())) {
      // Jika waktu reminder sudah lewat, jangan jadwalkan
      return;
    }

    final notificationId = id.hashCode;

    const androidDetails = AndroidNotificationDetails(
      'deadline_reminders',
      'Deadline Reminders',
      channelDescription: 'Channel untuk pengingat deadline tugas',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    final tzScheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    String durationStr;
    if (offsetMinutes == 60) {
      durationStr = '1 jam';
    } else if (offsetMinutes == 180) {
      durationStr = '3 jam';
    } else if (offsetMinutes == 1440) {
      durationStr = '1 hari';
    } else if (offsetMinutes == 4320) {
      durationStr = '3 hari';
    } else {
      durationStr = '$offsetMinutes menit';
    }

    await _localNotifications.zonedSchedule(
      notificationId,
      'Peringatan Deadline!',
      'Tugas "$title" di pelajaran "$folderName" harus dikumpulkan dalam $durationStr lagi!',
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelTaskReminder(String id) async {
    final notificationId = id.hashCode;
    await _localNotifications.cancel(notificationId);
  }
}
