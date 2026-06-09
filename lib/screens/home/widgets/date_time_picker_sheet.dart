// lib/screens/home/widgets/date_time_picker_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';

/// Membuka halaman pemilih tanggal & waktu secara Full Screen Dialog.
/// Mengembalikan [DateTime] lengkap atau null jika dihapus/dibatalkan.
Future<DateTime?> showDateTimePickerScreen(
  BuildContext context, {
  DateTime? initial,
}) {
  return Navigator.push<DateTime>(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => DateTimePickerScreen(initial: initial),
    ),
  );
}

class DateTimePickerScreen extends StatefulWidget {
  final DateTime? initial;
  const DateTimePickerScreen({super.key, this.initial});

  @override
  State<DateTimePickerScreen> createState() => _DateTimePickerScreenState();
}

class _DateTimePickerScreenState extends State<DateTimePickerScreen> {
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isEditMode = false; // Flag untuk mengecek apakah ini data baru atau edit data lama

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    
    if (widget.initial != null) {
      _isEditMode = true;
      final localInitial = widget.initial!.toLocal();
      _selectedDate = DateTime(localInitial.year, localInitial.month, localInitial.day);
      if (widget.initial!.hour != 0 || widget.initial!.minute != 0) {
        _selectedTime = TimeOfDay(hour: localInitial.hour, minute: localInitial.minute);
      }
    } else {
      _isEditMode = false;
      _selectedDate = DateTime(now.year, now.month, now.day);
    }
  }

  // ── Preview Teks Atas ─────────────────────────────────────
  String get _previewText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final d = _selectedDate;

    final dateLabel = d == today
        ? 'Hari ini'
        : d == tomorrow
            ? 'Besok'
            : DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);

    if (_selectedTime != null) {
      final menitStr = _selectedTime!.minute.toString().padLeft(2, '0');
      final jamStr = _selectedTime!.hour.toString().padLeft(2, '0');
      return '$dateLabel, Pukul $jamStr:$menitStr WIB';
    }
    return dateLabel;
  }

  // ── Fungsi Time Picker ─────────────────────────────────────
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

  // ── Shortcut Handler ──────────────────────────────────────
  void _applyShortcut(int daysFromNow) {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day + daysFromNow);
    });
  }

  // ── Fungsi Hapus dengan Alert Dialog Peringatan ────────────
  Future<void> _handleDelete() async {
    if (!_isEditMode) {
      // Jika data memang belum dimasukkan sebelumnya, langsung tutup halaman (Batal)
      Navigator.pop(context, null);
      return;
    }

    // Jika sedang mengedit data lama, munculkan konfirmasi sebelum menghapus
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Deadline',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus pengaturan tanggal dan waktu deadline ini?',
          style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textGrey, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmDelete == true && mounted) {
      Navigator.pop(context, null); // Kembalikan null untuk menghapus data di form utama
    }
  }

  // ── Konfirmasi Simpan ─────────────────────────────────────
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

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context, widget.initial), // Kembali tanpa merubah data lama
        ),
        title: Text(
          'Tanggal',
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview Banner Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_calendar_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _previewText,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── SHORTCUT CARD TANPA SINGKATAN ───────────────────
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
                          isSelected: _selectedDate == today.add(const Duration(days: 1)),
                          onTap: () => _applyShortcut(1),
                        ),
                        const SizedBox(width: 8),
                        _ShortcutBtn(
                          icon: Icons.calendar_month_outlined,
                          label: 'Minggu Depan', // Ditulis lengkap utuh
                          isSelected: _selectedDate == today.add(const Duration(days: 7)),
                          onTap: () => _applyShortcut(7),
                        ),
                        const SizedBox(width: 8),
                        _ShortcutBtn(
                          icon: Icons.weekend_outlined,
                          label: 'Pekan Depan', // Ditulis lengkap utuh
                          isSelected: _selectedDate == today.add(const Duration(days: 14)),
                          onTap: () => _applyShortcut(14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── KALENDER CARD ───────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CalendarDatePicker(
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        onDateChanged: (d) => setState(() => _selectedDate = d),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── TIME PICKER CARD MODERN ───────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            color: AppColors.secondary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Waktu',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedTime == null
                                      ? 'Pilih Waktu'
                                      : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_right, color: AppColors.textGrey),
                            onPressed: _pickTime,
                          ),
                        ],
                      ),
                    ),
                    
                    // Card Ulangi yang di bawah waktu sudah dihapus bersih dari sini
                  ],
                ),
              ),
            ),

            // ── FOOTER ACTION BUTTONS (DYNAMIC) ──────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleDelete,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _isEditMode ? AppColors.error.withOpacity(0.5) : Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isEditMode ? 'Hapus' : 'Batal', // Berubah dinamis tergantung kondisi data
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: _isEditMode ? AppColors.error : AppColors.textGrey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 14,
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
    );
  }
}

// ─── SHORTCUT COMPONENT ──────────────────────────────────────
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.25)
                    : Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
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