// lib/screens/home/widgets/edit_task_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../models/task_model.dart';
import '../../../services/task_service.dart';

class EditTaskScreen extends StatefulWidget {
  final String currentFolderId;
  final TaskModel task;

  const EditTaskScreen({
    super.key,
    required this.currentFolderId,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  
  String? _selectedFolderId;
  DateTime? _selectedDateTime;
  String _selectedPriority = 'low'; // low, medium, high (sesuai backend Go kamu)
  String _selectedReminder = 'Tidak Ada';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _selectedFolderId = widget.currentFolderId;
    _selectedDateTime = widget.task.deadline;
    _selectedPriority = widget.task.priority?.toLowerCase() ?? 'low';

    final offset = widget.task.reminderOffsetMinutes;
    if (offset == null) {
      _selectedReminder = 'Tidak Ada';
    } else if (offset == 60) {
      _selectedReminder = '1 Jam Sebelum';
    } else if (offset == 180) {
      _selectedReminder = '3 Jam Sebelum';
    } else if (offset == 1440) {
      _selectedReminder = '1 Hari Sebelum';
    } else if (offset == 4320) {
      _selectedReminder = '3 Hari Sebelum';
    } else {
      _selectedReminder = 'Tidak Ada';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat("EEEE, d MMMM yyyy - HH:mm", "id_ID").format(dt);
  }

  // ── FIKS TOTAL: Menggunakan Native Picker Kombinasi Date & Time Anti-Error ──
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    
    // 1. Pilih Tanggal
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    if (!mounted) return;

    // 2. Pilih Jam & Menit
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    // 3. Gabungkan menjadi objek DateTime tunggal
    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // ── Aksi Hapus Tugas ──────────────────────────────────────────
  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Tugas',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus tugas "${widget.task.title}"?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await context.read<TaskService>().deleteTask(widget.task.id);
        if (!mounted) return;
        Navigator.pop(context); // Tutup halaman edit
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tugas berhasil dihapus', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus tugas', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Aksi PATCH Update Data Tugas ke Backend Go ────────────────
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedReminder != 'Tidak Ada' && _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tenggat terlebih dahulu sebelum mengatur pengingat'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    int? offset;
    switch (_selectedReminder) {
      case '1 Jam Sebelum':
        offset = 60;
        break;
      case '3 Jam Sebelum':
        offset = 180;
        break;
      case '1 Hari Sebelum':
        offset = 1440;
        break;
      case '3 Hari Sebelum':
        offset = 4320;
        break;
      case 'Tidak Ada':
      default:
        offset = null;
        break;
    }

    try {
      final taskService = context.read<TaskService>();
      
      // Menembak route PATCH melalui TaskService terintegrasi
      await taskService.updateTaskComplete(
        taskId: widget.task.id,
        title: _titleController.text.trim(),
        deadline: _selectedDateTime,
        priority: _selectedPriority,
        isDone: widget.task.isDone,
        folderId: _selectedFolderId!,
        reminderOffsetMinutes: offset,
      );

      if (!mounted) return;
      Navigator.pop(context); // Kembali ke dashboard
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tugas berhasil diperbarui', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui data tugas', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context, listen: false);
    final filteredFolders = taskService.folders.where((f) => f.name != 'Belum Dikelompokkan').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Tugas',
          style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Nama Tugas ─────────────────────────────────
                      _buildFieldLabel('Nama Tugas'),
                      TextFormField(
                        controller: _titleController,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Nama tugas...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama tugas tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 18),

                      // ── Dropdown Mata Kuliah ────────────────────────
                      _buildFieldLabel('Mata Kuliah'),
                      DropdownButtonFormField<String>(
                        value: _selectedFolderId,
                        style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textDark, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        items: filteredFolders.map((f) {
                          return DropdownMenuItem(value: f.id, child: Text(f.name));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedFolderId = val),
                      ),
                      const SizedBox(height: 18),

                      // ── Date & Time Picker ──────────────────────────
                      _buildFieldLabel('Tenggat'),
                      InkWell(
                        onTap: _pickDateTime,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, color: AppColors.secondary, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedDateTime == null ? 'Pilih Tanggal & Waktu' : _formatDateTime(_selectedDateTime!),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: _selectedDateTime == null ? FontWeight.w400 : FontWeight.w600,
                                    color: _selectedDateTime == null ? AppColors.textGrey : AppColors.textDark,
                                  ),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_right, color: AppColors.textGrey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Seleksi Prioritas Akademik ─────────────────
                      _buildFieldLabel('Prioritas'),
                      Row(
                        children: [
                          _buildPriorityItem('high', '🔴 Tinggi'),
                          const SizedBox(width: 8),
                          _buildPriorityItem('medium', '🟡 Sedang'),
                          const SizedBox(width: 8),
                          _buildPriorityItem('low', '🟢 Rendah'),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // ── Pengingat Tugas ────────────────────────────
                      _buildFieldLabel('Pengingat'),
                      DropdownButtonFormField<String>(
                        value: _selectedReminder,
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        items: ['Tidak Ada', '1 Jam Sebelum', '3 Jam Sebelum', '1 Hari Sebelum', '3 Hari Sebelum'].map((r) {
                          return DropdownMenuItem(value: r, child: Text(r));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedReminder = val!),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Panel Tombol Aksi Bawah ──────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleDelete,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Hapus Tugas',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.error, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Simpan Perubahan',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
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

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
    );
  }

  Widget _buildPriorityItem(String type, String label) {
    final isSelected = _selectedPriority == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPriority = type),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12, 
                fontWeight: FontWeight.w600, 
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}