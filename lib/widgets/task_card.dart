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
          if (task.isDone) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.purple),
              onPressed: () async {
                final controller = TextEditingController(text: task.title);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Edit Tugas'),
                    content: TextField(
                      controller: controller,
                      decoration:
                          const InputDecoration(hintText: 'Judul tugas'),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Simpan')),
                    ],
                  ),
                );

                if (ok == true) {
                  final newTitle = controller.text.trim();
                  if (newTitle.isEmpty) return;
                  try {
                    await service.updateTask(taskId: task.id, title: newTitle);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tugas diperbarui')));
                  } catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal update tugas')));
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Hapus Tugas'),
                    content: const Text('Yakin ingin menghapus tugas ini?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Hapus')),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await service.deleteTask(task.id, folderId: folderId);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Tugas berhasil dihapus')));
                  } catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal hapus tugas')));
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
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
        color: AppColors.chipWed.withOpacity(0.2),
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
