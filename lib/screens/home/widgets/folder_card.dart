// lib/screens/home/widgets/folder_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../models/task_model.dart';
import 'package:provider/provider.dart';
import '../../../services/task_service.dart';

class FolderCard extends StatefulWidget {
  final FolderModel folder;
  final bool initiallyExpanded;
  final void Function(String taskId) onToggleTask;
  final VoidCallback onAddTask;

  const FolderCard({
    super.key,
    required this.folder,
    required this.onToggleTask,
    required this.onAddTask,
    this.initiallyExpanded = false,
  });

  @override
  State<FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends State<FolderCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _animController;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: _expanded ? 1.0 : 0.0,
    );
    _rotateAnim = Tween<double>(begin: 0, end: 0.5).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final folder = widget.folder;
    final hasTasks = folder.tasks.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header Row ───────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Name + Tag
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          folder.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        if (folder.tag != null) ...[
                          const SizedBox(width: 8),
                          _TagChip(
                            label: folder.tag!,
                            color: folder.tagColor,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Count
                  Text(
                    '${folder.taskCount}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Arrow
                  RotationTransition(
                    turns: _rotateAnim,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded Content ─────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                const Divider(height: 1, indent: 16, endIndent: 16),
                const SizedBox(height: 4),

                if (!hasTasks)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          'Belum ada tugas',
                          style: GoogleFonts.poppins(
                            color: AppColors.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Task rows
                ...folder.tasks.map(
                  (task) => _TaskRow(
                    folderId: folder.id,
                    task: task,
                    onToggle: () => widget.onToggleTask(task.id),
                  ),
                ),

                // Add task button
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: widget.onAddTask,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ─── TASK ROW ────────────────────────────────────────────────
class _TaskRow extends StatelessWidget {
  final String folderId;
  final TaskModel task;
  final VoidCallback onToggle;

  const _TaskRow(
      {required this.folderId, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final service = context.read<TaskService>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: task.isDone,
              onChanged: (_) => onToggle(),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: BorderSide(
                color: AppColors.primary.withOpacity(0.4),
                width: 1.5,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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

          // show edit + delete only when task is done
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

// ─── TAG CHIP ────────────────────────────────────────────────
class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$label',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
