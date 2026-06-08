// lib/screens/home/widgets/deadline_card.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../models/task_model.dart';

class DeadlineCard extends StatefulWidget {
  final String folderName;
  final TaskModel task;
  final VoidCallback onDone;

  const DeadlineCard({
    super.key,
    required this.folderName,
    required this.task,
    required this.onDone,
  });

  @override
  State<DeadlineCard> createState() => _DeadlineCardState();
}

class _DeadlineCardState extends State<DeadlineCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // TIMER PERIODIC: Memaksa widget update tampilan setiap 1 menit secara otomatis
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hapus timer saat halaman ditinggalkan agar hemat memori baterai
    super.dispose();
  }

  /// Format: "Selasa, 21 April 2026 - 23:59"
  String _formatDeadline(DateTime dt) {
    return DateFormat("EEEE, d MMMM yyyy - HH:mm", "id_ID").format(dt.toLocal());
  }

  /// Perhitungan mundur yang otomatis ter-update real-time oleh timer
  String _countdown(DateTime deadline) {
    final diff = deadline.toLocal().difference(DateTime.now());
    if (diff.isNegative) return 'Terlambat!';
    if (diff.inDays >= 1) return '${diff.inDays} hari lagi';
    if (diff.inHours >= 1) return '${diff.inHours} jam lagi';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} menit lagi';
    return 'Sekarang!';
  }

  Color _countdownColor(DateTime deadline) {
    final diff = deadline.toLocal().difference(DateTime.now());
    if (diff.isNegative) return Colors.red.shade600;
    if (diff.inHours < 1) return Colors.orange.shade700;
    if (diff.inHours < 3) return Colors.amber.shade700;
    return Colors.green.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final dl = widget.task.deadline;
    final deadlineStr = dl != null ? _formatDeadline(dl) : '';
    final countdown = dl != null ? _countdown(dl) : null;
    final countdownColor = dl != null ? _countdownColor(dl) : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Nama Mata Kuliah + Badge Countdown ──────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.folderName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (countdown != null && !widget.task.isDone) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: countdownColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    countdown,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: countdownColor,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 6),

          // ── Judul / Deskripsi Tugas ───────────────────────
          Text(
            widget.task.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 6),

          // ── Tanggal + Jam Tenggat ────────────────────────
          if (deadlineStr.isNotEmpty)
            Row(
              children: [
                Icon(Icons.event_rounded,
                    size: 13, color: AppColors.secondary.withOpacity(0.8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Tenggat: $deadlineStr',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12),

          // ── Tombol Selesai ────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: widget.task.isDone
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '✓ Selesai',
                      style: GoogleFonts.poppins(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: widget.onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size.zero,
                      elevation: 0,
                    ),
                    child: Text(
                      'Selesai',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}