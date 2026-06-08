// lib/widgets/task_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskCategoryCard extends StatefulWidget {
  final FolderModel category;
  final void Function(String taskId) onToggleTask;
  final bool initiallyExpanded;

  const TaskCategoryCard({
    super.key,
    required this.category,
    required this.onToggleTask,
    this.initiallyExpanded = false,
  });

  @override
  State<TaskCategoryCard> createState() => _TaskCategoryCardState();
}

class _TaskCategoryCardState extends State<TaskCategoryCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final count = cat.tasks.length;
    final hasTag = cat.tag != null;
    final hasItems = cat.tasks.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: widget.initiallyExpanded,
          onExpansionChanged: (v) => setState(() => _expanded = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          title: Row(
            children: [
              Text(
                cat.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
              if (hasTag) ...[
                const SizedBox(width: 8),
                _TagChip(label: cat.tag!),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: GoogleFonts.poppins(
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
            ],
          ),
          children: hasItems
              ? cat.tasks
                  .map((task) => _TaskRow(
                        folderId: cat.id,
                        task: task,
                        onToggle: () => widget.onToggleTask(task.id),
                      ))
                  .toList()
              : [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Text(
                      'Tidak ada tugas',
                      style: GoogleFonts.poppins(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}

// ================= TASK ROW =================
class _TaskRow extends StatelessWidget {
  final String folderId;
  final TaskModel task;
  final VoidCallback onToggle;

  const _TaskRow({
    required this.folderId,
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.read<TaskService>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Checkbox(
            value: task.isDone,
            onChanged: (_) => onToggle(),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: Text(
              task.title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: task.isDone ? AppColors.textGrey : AppColors.textDark,
                decoration: task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          // Tombol edit – tampil untuk semua task
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.purple, size: 20),
            tooltip: 'Edit tugas',
            onPressed: () => _showEditDialog(context, service),
          ),
          // Tombol delete – tampil untuk semua task
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            tooltip: 'Hapus tugas',
            onPressed: () => _confirmDelete(context, service),
          ),
        ],
      ),
    );
  }

  /// Dialog edit lengkap: judul, deadline, prioritas
  Future<void> _showEditDialog(BuildContext context, TaskService service) async {
    final titleCtrl = TextEditingController(text: task.title);
    DateTime? selectedDate = task.deadline?.toLocal();
    final rawPriority = task.priority;
    String? selectedPriority = (rawPriority != null && rawPriority.isNotEmpty) ? rawPriority : null;

    // Normalise priority ke label Indonesia untuk tampilan
    String? toLabel(String? p) {
      if (p == null) return null;
      switch (p.toLowerCase()) {
        case 'high':
        case 'tinggi':
          return 'Tinggi';
        case 'low':
        case 'rendah':
          return 'Rendah';
        default:
          return 'Sedang';
      }
    }

    String? displayPriority = toLabel(selectedPriority);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            'Edit Tugas',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Judul ───────────────────────────────────
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Judul tugas',
                    labelStyle: GoogleFonts.poppins(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Deadline ─────────────────────────────────
                Text('Deadline', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate ?? now,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 5),
                    );
                    if (picked != null) {
                      if (!ctx.mounted) return;
                      final timePicked = await showTimePicker(
                        context: ctx,
                        initialTime: TimeOfDay.fromDateTime(selectedDate ?? now),
                      );
                      setDialogState(() {
                        selectedDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          timePicked?.hour ?? 0,
                          timePicked?.minute ?? 0,
                        );
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} ${selectedDate!.hour.toString().padLeft(2, '0')}:${selectedDate!.minute.toString().padLeft(2, '0')}'
                              : 'Pilih tanggal & jam',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Prioritas ────────────────────────────────
                Text('Prioritas', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: displayPriority,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  hint: Text('Pilih prioritas', style: GoogleFonts.poppins()),
                  items: ['Tinggi', 'Sedang', 'Rendah']
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p, style: GoogleFonts.poppins()),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() => displayPriority = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final newTitle = titleCtrl.text.trim();
      if (newTitle.isEmpty) return;
      if (!context.mounted) return;

      try {
        await service.updateTask(
          taskId: task.id,
          title: newTitle,
          deadline: selectedDate,
          priority: displayPriority,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tugas berhasil diperbarui')),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui tugas')),
          );
        }
      }
    }
  }

  /// Konfirmasi hapus task
  Future<void> _confirmDelete(BuildContext context, TaskService service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus Tugas', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Yakin ingin menghapus tugas "${task.title}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await service.deleteTask(task.id, folderId: folderId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tugas berhasil dihapus')),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus tugas')),
          );
        }
      }
    }
  }
}


// ================= TAG =================
class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.chipWed.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$label',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
