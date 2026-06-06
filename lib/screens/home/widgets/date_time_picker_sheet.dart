// lib/screens/home/widgets/date_time_picker_sheet.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';

/// Menampilkan bottom sheet untuk memilih tanggal + jam deadline.
/// Mengembalikan [DateTime] yang sudah include jam, atau null jika dibatalkan.
Future<DateTime?> showDateTimePickerSheet(
  BuildContext context, {
  DateTime? initial,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DateTimePickerSheet(initial: initial),
  );
}

// ─────────────────────────────────────────────────────────────
class _DateTimePickerSheet extends StatefulWidget {
  final DateTime? initial;
  const _DateTimePickerSheet({this.initial});

  @override
  State<_DateTimePickerSheet> createState() => _DateTimePickerSheetState();
}

class _DateTimePickerSheetState extends State<_DateTimePickerSheet> {
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = widget.initial ?? DateTime(now.year, now.month, now.day);
    if (widget.initial != null &&
        (widget.initial!.hour != 0 || widget.initial!.minute != 0)) {
      _selectedTime =
          TimeOfDay(hour: widget.initial!.hour, minute: widget.initial!.minute);
    }
  }

  // ── Teks preview ──────────────────────────────────────────
  String get _previewText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final d = _selectedDate;
    final dateLabel = d == today
        ? 'Hari ini'
        : d == tomorrow
            ? 'Besok'
            : DateFormat('d MMM yyyy', 'id_ID').format(d);
    if (_selectedTime != null) {
      final jam = _selectedTime!.format(context);
      return '$dateLabel jam $jam';
    }
    return dateLabel;
  }

  // ── Pilih waktu ───────────────────────────────────────────
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 23, minute: 59),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ── Shortcut tanggal ──────────────────────────────────────
  void _applyShortcut(int daysFromNow) {
    final now = DateTime.now();
    setState(() {
      _selectedDate =
          DateTime(now.year, now.month, now.day + daysFromNow);
    });
  }

  // ── Konfirmasi ────────────────────────────────────────────
  void _confirm() {
    final time = _selectedTime ?? const TimeOfDay(hour: 23, minute: 59);
    final result = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      time.hour,
      time.minute,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEDE9F6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── drag handle ─────────────────────────────────
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Judul ──────────────────────────────
                    Text(
                      'Date',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),

                    // ── Preview teks ───────────────────────
                    Row(
                      children: [
                        const Icon(Icons.edit_outlined,
                            color: AppColors.secondary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _previewText,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Divider(color: AppColors.secondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),

                    // ── Shortcut ───────────────────────────
                    Row(
                      children: [
                        _ShortcutBtn(
                          icon: Icons.calendar_today_rounded,
                          label: 'Hari ini',
                          isSelected: _selectedDate == today,
                          onTap: () => _applyShortcut(0),
                        ),
                        const SizedBox(width: 8),
                        _ShortcutBtn(
                          icon: Icons.wb_sunny_outlined,
                          label: 'Besok',
                          isSelected: _selectedDate ==
                              today.add(const Duration(days: 1)),
                          onTap: () => _applyShortcut(1),
                        ),
                        const SizedBox(width: 8),
                        _ShortcutBtn(
                          icon: Icons.calendar_month_outlined,
                          label: 'Minggu\ndepan',
                          isSelected: _selectedDate ==
                              today.add(const Duration(days: 7)),
                          onTap: () => _applyShortcut(7),
                        ),
                        const SizedBox(width: 8),
                        _ShortcutBtn(
                          icon: Icons.weekend_outlined,
                          label: 'Pekan\nDepan',
                          isSelected: _selectedDate ==
                              today.add(const Duration(days: 14)),
                          onTap: () => _applyShortcut(14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Kalender ───────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CalendarDatePicker(
                        initialDate: _selectedDate,
                        firstDate: today,
                        lastDate: DateTime(2030),
                        onDateChanged: (d) =>
                            setState(() => _selectedDate = d),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Waktu & Ulangi ─────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Waktu
                          InkWell(
                            onTap: _pickTime,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.access_time_rounded,
                                        color: AppColors.secondary, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Waktu',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _selectedTime != null
                                        ? _selectedTime!.format(context)
                                        : 'Tidak ada',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: _selectedTime != null
                                          ? AppColors.primary
                                          : AppColors.textGrey,
                                      fontWeight: _selectedTime != null
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: AppColors.textGrey, size: 18),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: Colors.grey.shade100),
                          // Ulangi (placeholder)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.repeat_rounded,
                                      color: AppColors.secondary, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Ulangi',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Tidak ada',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right_rounded,
                                    color: AppColors.textGrey, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Tombol Konfirmasi ──────────────────
                    Row(
                      children: [
                        // Hapus
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, null),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.primary.withValues(alpha: 0.3)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Hapus',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textGrey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Simpan
                        Expanded(
                          flex: 2,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.secondary, AppColors.primary],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _confirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'Simpan',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SHORTCUT BUTTON ─────────────────────────────────────────
class _ShortcutBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShortcutBtn({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? Colors.white : AppColors.secondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textDark,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
