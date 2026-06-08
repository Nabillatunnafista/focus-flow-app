// lib/screens/home/widgets/add_task_sheet.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../services/task_service.dart';
import 'date_time_picker_sheet.dart';

class AddTaskSheet extends StatefulWidget {
  final String? preselectedFolderId;

  const AddTaskSheet({super.key, this.preselectedFolderId});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _taskCtrl = TextEditingController();
  String? _selectedFolderId;
  DateTime? _selectedDate;
  String? _selectedPriority;
  int? _selectedReminderOffset;

  @override
  void initState() {
    super.initState();
    _selectedFolderId = widget.preselectedFolderId;
  }

  @override
  void dispose() {
    _taskCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    // Diubah menjadi Screen sesuai dengan nama fungsi di file baru kita
    final picked = await showDateTimePickerScreen(
      context,
      initial: _selectedDate,
    );
    
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    final title = _taskCtrl.text.trim();
    if (title.isEmpty || _selectedFolderId == null) return;

    try {
      await context.read<TaskService>().addTask(
            folderId: _selectedFolderId!,
            title: title,
            deadline: _selectedDate,
            priority: _selectedPriority,
            reminderOffsetMinutes: _selectedReminderOffset,
          );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambah task')),
      );
    }
  }

  /// Format label chip deadline: tampilkan tanggal + jam jika ada
  String _formatDeadlineLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final d = DateTime(dt.year, dt.month, dt.day);

    String dateStr;
    if (d == today) {
      dateStr = 'Hari ini';
    } else if (d == tomorrow) {
      dateStr = 'Besok';
    } else {
      dateStr = DateFormat('d MMM', 'id_ID').format(dt);
    }

    // Jika jam bukan 00:00 (artinya user sudah set waktu)
    final hasTime = dt.hour != 0 || dt.minute != 0;
    if (hasTime) {
      final timeStr = DateFormat('HH:mm').format(dt);
      return '$dateStr, $timeStr';
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskService>();
    final folders = provider.folders;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle ─────────────────────────────────
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Task Input ───────────────────────────────────
            TextField(
              controller: _taskCtrl,
              autofocus: true,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Apa yang ingin kamu lakukan?',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
              ),
            ),

            // ── Description label ────────────────────────────
            Text(
              'Deskripsi',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),

            // ── Folder Picker ────────────────────────────────
            _FolderDropdown(
              folders: folders,
              selectedFolderId: _selectedFolderId,
              onChanged: (id) => setState(() => _selectedFolderId = id),
            ),

            const SizedBox(height: 16),

            // ── Action Chips ─────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ActionChip(
                    icon: Icons.calendar_today_outlined,
                    label: _selectedDate != null
                        ? _formatDeadlineLabel(_selectedDate!)
                        : 'Tanggal',
                    onTap: _pickDate,
                    isActive: _selectedDate != null,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.attach_file_outlined,
                    label: 'Lampiran',
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.flag_outlined,
                    label: _selectedPriority ?? 'Prioritas',
                    isActive: _selectedPriority != null,
                    onTap: () => _showPriorityPicker(),
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.alarm_outlined,
                    label: _selectedReminderOffset != null
                        ? _formatReminderLabel(_selectedReminderOffset!)
                        : 'Pengingat',
                    isActive: _selectedReminderOffset != null,
                    onTap: () => _showReminderPicker(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Submit Button ────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_taskCtrl.text.trim().isNotEmpty &&
                            _selectedFolderId != null)
                        ? _submit
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.white.withOpacity(0.3),
                  disabledForegroundColor: Colors.white.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Tambah Tugas',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriorityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Prioritas',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            const SizedBox(height: 12),
            for (final p in ['Tinggi', 'Sedang', 'Rendah'])
              ListTile(
                leading: Icon(
                  Icons.flag,
                  color: p == 'Tinggi'
                      ? Colors.red
                      : p == 'Sedang'
                          ? Colors.orange
                          : Colors.green,
                ),
                title: Text(p, style: GoogleFonts.poppins()),
                onTap: () {
                  setState(() => _selectedPriority = p);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatReminderLabel(int minutes) {
    if (minutes == 60) return '1 jam sebelum';
    if (minutes == 180) return '3 jam sebelum';
    if (minutes == 1440) return '1 hari sebelum';
    if (minutes == 4320) return '3 hari sebelum';
    return '$minutes menit sebelum';
  }

  void _showReminderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Pengingat',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildReminderOption('Tidak ada', null),
            _buildReminderOption('1 jam sebelum deadline', 60),
            _buildReminderOption('3 jam sebelum deadline', 180),
            _buildReminderOption('1 hari sebelum deadline', 1440),
            _buildReminderOption('3 hari sebelum deadline', 4320),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderOption(String label, int? offset) {
    final isSelected = _selectedReminderOffset == offset;
    return ListTile(
      leading: Icon(
        offset == null ? Icons.alarm_off_outlined : Icons.alarm_outlined,
        color: isSelected ? AppColors.primary : AppColors.textGrey,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.primary : AppColors.textDark,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() => _selectedReminderOffset = offset);
        Navigator.pop(context);
      },
    );
  }
}

// ─── FOLDER DROPDOWN ─────────────────────────────────────────
class _FolderDropdown extends StatelessWidget {
  final List folders;
  final String? selectedFolderId;
  final ValueChanged<String?> onChanged;

  const _FolderDropdown({
    required this.folders,
    required this.selectedFolderId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFolderId,
          hint: Text(
            'Pilih Mata Kuliah',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          dropdownColor: AppColors.primary,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white, size: 20),
          isExpanded: true,
          items: folders
              .map((f) => DropdownMenuItem<String>(
                    value: f.id,
                    child: Text(f.name),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── ACTION CHIP ─────────────────────────────────────────────
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? AppColors.primary : Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:
                    isActive ? AppColors.primary : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}