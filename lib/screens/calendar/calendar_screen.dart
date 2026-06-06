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
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  int get _startWeekday =>
      DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

  int get _daysInMonth =>
      DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

  void _prevMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      });

  bool _isToday(int day) {
    final now = DateTime.now();
    return _focusedMonth.year == now.year &&
        _focusedMonth.month == now.month &&
        day == now.day;
  }

  bool _isSelected(int day) =>
      _selectedDay != null &&
      _selectedDay!.year == _focusedMonth.year &&
      _selectedDay!.month == _focusedMonth.month &&
      _selectedDay!.day == day;

  List<({TaskModel task, String folderName})> _tasksForDay(
      TaskService provider, int day) {
    final target = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    final result = <({TaskModel task, String folderName})>[];
    for (final folder in provider.folders) {
      for (final task in folder.tasks) {
        if (task.deadline == null) continue;
        final d = task.deadline!;
        if (d.year == target.year &&
            d.month == target.month &&
            d.day == target.day) {
          result.add((task: task, folderName: folder.name));
        }
      }
    }
    return result;
  }

  List<({TaskModel task, String folderName})> _selectedDayTasks(
      TaskService provider) {
    if (_selectedDay == null) return [];
    final day = _selectedDay!;
    final result = <({TaskModel task, String folderName})>[];
    for (final folder in provider.folders) {
      for (final task in folder.tasks) {
        if (task.deadline == null) continue;
        final d = task.deadline!;
        if (d.year == day.year && d.month == day.month && d.day == day.day) {
          result.add((task: task, folderName: folder.name));
        }
      }
    }
    return result;
  }

  bool _dayHasDeadline(TaskService provider, int day) =>
      _tasksForDay(provider, day).any((e) => !e.task.isDone);

  bool _dayHasDone(TaskService provider, int day) =>
      _tasksForDay(provider, day).any((e) => e.task.isDone);

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskService>(
      builder: (context, provider, _) {
        final selectedTasks = _selectedDayTasks(provider);
        final selectedDayLabel = _selectedDay != null
            ? DateFormat('EEEE', 'id_ID').format(_selectedDay!)
            : '';
        final selectedDayNum = _selectedDay?.day.toString() ?? '';

        return Scaffold(
          backgroundColor: const Color(0xFFEDE9F6),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Header ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 20, 8),
                  child: Row(
                    children: [
                      if (widget.standalone) ...[
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        'Kalender',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    child: Column(
                      children: [
                        // ── Calendar Card ──────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding:
                              const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Column(
                            children: [
                              // Month nav
                              Row(
                                children: [
                                  Text(
                                    DateFormat('MMMM yyyy', 'id_ID')
                                        .format(_focusedMonth),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: _prevMonth,
                                    child: const Icon(
                                        Icons.chevron_left_rounded,
                                        color: AppColors.primary,
                                        size: 22),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: _nextMonth,
                                    child: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.primary,
                                        size: 22),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Weekday headers
                              Row(
                                children: [
                                  'Sun',
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat'
                                ]
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

                              // Grid
                              _CalendarGrid(
                                startWeekday: _startWeekday,
                                daysInMonth: _daysInMonth,
                                isToday: _isToday,
                                isSelected: _isSelected,
                                hasDeadline: (day) =>
                                    _dayHasDeadline(provider, day),
                                hasDone: (day) =>
                                    _dayHasDone(provider, day),
                                onDayTap: (day) => setState(() =>
                                    _selectedDay = DateTime(
                                        _focusedMonth.year,
                                        _focusedMonth.month,
                                        day)),
                              ),

                              const SizedBox(height: 12),

                              // Legend
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  _LegendDot(
                                      color: Colors.red,
                                      label: 'Deadline'),
                                  const SizedBox(width: 24),
                                  _LegendDot(
                                      color: Colors.green,
                                      label: 'Jadwal Belajar'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Selected Day Panel ─────────────────
                        if (_selectedDay != null)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedDayLabel,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                        Text(
                                          selectedDayNum,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 32,
                                            color: AppColors.primary,
                                            height: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add,
                                          color: Colors.white, size: 20),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (selectedTasks.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    child: Text(
                                      'Tidak ada tugas pada hari ini',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textGrey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                else
                                  ...selectedTasks.take(3).map(
                                        (item) => _DayTaskTile(
                                          task: item.task,
                                          onDone: () => provider
                                              .toggleTask('', item.task.id),
                                        ),
                                      ),
                                if (selectedTasks.length > 3)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '+${selectedTasks.length - 3}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final int startWeekday;
  final int daysInMonth;
  final bool Function(int) isToday;
  final bool Function(int) isSelected;
  final bool Function(int) hasDeadline;
  final bool Function(int) hasDone;
  final void Function(int) onDayTap;

  const _CalendarGrid({
    required this.startWeekday,
    required this.daysInMonth,
    required this.isToday,
    required this.isSelected,
    required this.hasDeadline,
    required this.hasDone,
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
      final deadline = hasDeadline(day);
      final done = hasDone(day);

      Color? bgColor;
      Color textColor = AppColors.textDark;

      if (deadline) {
        bgColor = Colors.red;
        textColor = Colors.white;
      } else if (done) {
        bgColor = Colors.green;
        textColor = Colors.white;
      } else if (today) {
        bgColor = AppColors.primary.withOpacity(0.15);
        textColor = AppColors.primary;
      }

      cells.add(
        GestureDetector(
          onTap: () => onDayTap(day),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: selected && bgColor == null
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight:
                      today || selected ? FontWeight.w700 : FontWeight.w400,
                  color: textColor,
                ),
              ),
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
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
      ],
    );
  }
}

class _DayTaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onDone;
  const _DayTaskTile({required this.task, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              task.title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
                decoration:
                    task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDone,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: task.isDone ? Colors.green : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
