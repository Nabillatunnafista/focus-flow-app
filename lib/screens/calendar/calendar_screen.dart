// lib/screens/calendar/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';

class CalendarScreen extends StatefulWidget {
  final bool standalone;
  const CalendarScreen({super.key, this.standalone = false});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  int get _startWeekday => DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;
  int get _daysInMonth => DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

  void _prevMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      });

  bool _isToday(int day) {
    final now = DateTime.now();
    return _focusedMonth.year == now.year && _focusedMonth.month == now.month && day == now.day;
  }

  bool _isSelected(int day) =>
      _selectedDay.year == _focusedMonth.year &&
      _selectedDay.month == _focusedMonth.month &&
      _selectedDay.day == day;

  /// Mengambil semua aktivitas (Tugas/Belajar) pada hari tertentu untuk kebutuhan titik indikator
  List<TaskModel> _allActivitiesForDay(TaskService provider, int day) {
    final target = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    final list = <TaskModel>[];
    for (final folder in provider.folders) {
      for (final task in folder.tasks) {
        if (task.deadline == null) continue;
        final d = task.deadline!.toLocal();
        if (d.year == target.year && d.month == target.month && d.day == target.day) {
          list.add(task);
        }
      }
    }
    return list;
  }

  /// Memproses list agenda harian berdasarkan tanggal terpilih
  List<({TaskModel task, String folderName})> _buildFilteredAgenda(TaskService provider) {
    final result = <({TaskModel task, String folderName})>[];
    
    for (final folder in provider.folders) {
      for (final task in folder.tasks) {
        if (task.deadline == null) continue;
        final d = task.deadline!.toLocal();
        if (d.year == _selectedDay.year && d.month == _selectedDay.month && d.day == _selectedDay.day) {
          result.add((task: task, folderName: folder.name));
        }
      }
    }

    // Urutkan agenda berdasarkan waktu jam terdekat
    result.sort((a, b) {
      final timeA = a.task.deadline ?? DateTime(2100);
      final timeB = b.task.deadline ?? DateTime(2100);
      return timeA.compareTo(timeB);
    });

    return result;
  }

  /// Menghitung total ringkasan aktivitas khusus untuk hari ini (Today Summary)
  Map<String, dynamic> _computeTodaySummary(TaskService provider) {
    final now = DateTime.now();
    int totalDeadline = 0;
    int totalSelesai = 0;
    DateTime? nearestDeadline;

    for (final folder in provider.folders) {
      for (final task in folder.tasks) {
        if (task.deadline == null) continue;
        final d = task.deadline!.toLocal();
        if (d.year == now.year && d.month == now.month && d.day == now.day) {
          if (task.isDone) {
            totalSelesai++;
          } else {
            totalDeadline++;
            if (nearestDeadline == null || d.isBefore(nearestDeadline)) {
              nearestDeadline = d;
            }
          }
        }
      }
    }

    return {
      'deadline': totalDeadline,
      'selesai': totalSelesai,
      'nearest': nearestDeadline != null ? DateFormat('HH:mm').format(nearestDeadline) : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskService>(
      builder: (context, provider, _) {
        final agendaList = _buildFilteredAgenda(provider);
        final todaySummary = _computeTodaySummary(provider);
        final selectedDayLabel = DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDay);

        // FIX UTAMA: Mengganti Scaffold & SafeArea menjadi komponen Column biasa agar menembus ke navbar utama
        return Column(
          children: [
            // ── AppBar Pusat Akademik ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  if (widget.standalone) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    'Kalender',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                children: [
                  // ── Card Kalender Bulanan Modern ─────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Navigasi Bulan Bahasa Indonesia
                        Row(
                          children: [
                            Text(
                              DateFormat('MMMM yyyy', 'id_ID').format(_focusedMonth),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary, size: 24),
                              onPressed: _prevMonth,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 24),
                              onPressed: _nextMonth,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Header Nama Hari
                        Row(
                          children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
                              .map((d) => Expanded(
                                    child: Center(
                                      child: Text(
                                        d,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 8),

                        // Grid Angka Tanggal dengan Indikator Titik Aktivitas
                        _CalendarGridView(
                          startWeekday: _startWeekday,
                          daysInMonth: _daysInMonth,
                          isToday: _isToday,
                          isSelected: _isSelected,
                          getActivities: (day) => _allActivitiesForDay(provider, day),
                          onDayTap: (day) => setState(() =>
                              _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, day)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Card Ringkasan Hari Ini ──────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Hari Ini',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildSummaryBadge('📌 ${todaySummary['deadline']} Deadline', Colors.red.shade50),
                            const SizedBox(width: 8),
                            _buildSummaryBadge('✅ ${todaySummary['selesai']} Selesai', Colors.green.shade50),
                          ],
                        ),
                        if (todaySummary['nearest'] != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.alarm_rounded, size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                'Deadline terdekat pukul ${todaySummary['nearest']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Judul Tanggal Terpilih ──────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      selectedDayLabel,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Agenda List View ──────────────────────────────
                  if (agendaList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Tidak ada deadline pada tanggal ini 🎉',
                          style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...agendaList.map((item) {
                      final taskTime = item.task.deadline != null 
                          ? DateFormat('HH:mm').format(item.task.deadline!.toLocal()) 
                          : '--:--';
                      
                      // Tentukan warna dan label prioritas dari field priority tugas
                      Color priorityColor;
                      String priorityLabel;
                      switch (item.task.priority?.toLowerCase()) {
                        case 'high':
                          priorityColor = Colors.red;
                          priorityLabel = 'Prioritas Tinggi';
                          break;
                        case 'medium':
                          priorityColor = Colors.amber;
                          priorityLabel = 'Prioritas Sedang';
                          break;
                        default:
                          priorityColor = Colors.green;
                          priorityLabel = 'Prioritas Rendah';
                      }

                      final isSelesai = item.task.isDone;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              taskTime,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isSelesai ? AppColors.textGrey : AppColors.primary,
                                decoration: isSelesai ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isSelesai ? Colors.green : priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.task.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelesai ? AppColors.textGrey : AppColors.textDark,
                                      decoration: isSelesai ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  Text(
                                    isSelesai ? 'Selesai ✅' : priorityLabel,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: isSelesai ? Colors.green : AppColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isSelesai ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                color: isSelesai ? Colors.green : AppColors.textGrey.withOpacity(0.5),
                              ),
                              onPressed: () => provider.toggleTask(item.folderName, item.task.id),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryBadge(String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
    );
  }
}

class _CalendarGridView extends StatelessWidget {
  final int startWeekday;
  final int daysInMonth;
  final bool Function(int) isToday;
  final bool Function(int) isSelected;
  final List<TaskModel> Function(int) getActivities;
  final void Function(int) onDayTap;

  const _CalendarGridView({
    required this.startWeekday,
    required this.daysInMonth,
    required this.isToday,
    required this.isSelected,
    required this.getActivities,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[];
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final today = isToday(day);
      final selected = isSelected(day);
      final acts = getActivities(day);

      cells.add(
        GestureDetector(
          onTap: () => onDayTap(day),
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
              shape: BoxShape.circle,
              border: today ? Border.all(color: AppColors.primary, width: 1.2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: today || selected ? FontWeight.w700 : FontWeight.w400,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                if (acts.isNotEmpty) _buildDotsIndicator(acts),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      children: cells,
    );
  }

  Widget _buildDotsIndicator(List<TaskModel> activities) {
    final displayed = activities.take(3).toList();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...displayed.map((task) {
          Color dotColor = Colors.green;
          if (task.title.toLowerCase().contains('kewirausahaan') || task.title.toLowerCase().contains('pbo')) {
            dotColor = Colors.red;
          } else if (task.title.toLowerCase().contains('basis data')) {
            dotColor = Colors.amber;
          }
          return Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 0.5),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          );
        }),
        if (activities.length > 3)
          Text(
            '+',
            style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textGrey, height: 1),
          ),
      ],
    );
  }
}