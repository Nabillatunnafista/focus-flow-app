// lib/screens/notifications/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskService>(
      builder: (context, provider, _) {
        final notifications = _buildNotifications(provider);

        return Scaffold(
          backgroundColor: const Color(0xFFEDE9F6),
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Text(
                    'Pusat Notifikasi',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                // ── Notification List ───────────────────────────
                Expanded(
                  child: notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                size: 64,
                                color: AppColors.secondary.withOpacity(0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada notifikasi',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              _NotificationTile(notif: notifications[index]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_NotificationItem> _buildNotifications(TaskService provider) {
    final items = <_NotificationItem>[];
    final now = DateTime.now();

    for (final folder in provider.folders) {
      for (final task in folder.tasks) {
        if (task.deadline == null || task.isDone) continue;
        final diff = task.deadline!.difference(now);

        if (diff.isNegative) {
          items.add(_NotificationItem(
            title: 'Peringatan !',
            body: 'Tugas ${task.title} sudah melewati deadline!',
            timeAgo: _formatTimeAgo(task.deadline!, now),
          ));
        } else if (diff.inHours < 24) {
          final hourStr = diff.inHours > 0
              ? '${diff.inHours} jam lagi'
              : '${diff.inMinutes} menit lagi';
          items.add(_NotificationItem(
            title: 'Peringatan !',
            body: 'Tugas ${task.title} di kumpulkan $hourStr !',
            timeAgo: _formatTimeAgo(task.deadline!, now),
          ));
        }
      }
    }

    for (final folder in provider.folders) {
      if (folder.tag != null && folder.tasks.isNotEmpty) {
        final pending = folder.tasks.where((t) => !t.isDone).length;
        if (pending > 0) {
          items.add(_NotificationItem(
            title: 'Jadwal Belajar',
            body:
                'Kamu punya $pending tugas belum selesai di ${folder.name}.',
            timeAgo: '1 jam lalu',
          ));
        }
      }
    }

    return items;
  }

  String _formatTimeAgo(DateTime time, DateTime now) {
    final diff = now.difference(time).abs();
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hari yang lalu';
  }
}

class _NotificationItem {
  final String title;
  final String body;
  final String timeAgo;
  const _NotificationItem(
      {required this.title, required this.body, required this.timeAgo});
}

class _NotificationTile extends StatelessWidget {
  final _NotificationItem notif;
  const _NotificationTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_rounded,
                  color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textDark, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.timeAgo,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
