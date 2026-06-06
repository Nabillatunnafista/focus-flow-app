// lib/screens/tasks/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';

class TaskListScreen extends StatefulWidget {
  /// When [standalone] is true, shows a back button (used as a standalone route).
  /// When false (default), it's embedded inside HomeScreen's IndexedStack.
  final bool standalone;
  const TaskListScreen({super.key, this.standalone = false});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool _showDone = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskService>(
      builder: (context, provider, _) {
        final allTasks = <({TaskModel task, String folderName})>[];
        for (final folder in provider.folders) {
          for (final task in folder.tasks) {
            allTasks.add((task: task, folderName: folder.name));
          }
        }

        final pending = allTasks.where((e) => !e.task.isDone).toList();
        final done = allTasks.where((e) => e.task.isDone).toList();
        final displayed = _showDone ? done : pending;

        return Scaffold(
          backgroundColor: const Color(0xFFEDE9F6),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Header ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 20, 12),
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
                        'Daftar Semua Tugas',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Toggle Tabs ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'Belum Selesai',
                          isActive: !_showDone,
                          onTap: () => setState(() => _showDone = false),
                        ),
                        _TabButton(
                          label: 'Selesai',
                          isActive: _showDone,
                          onTap: () => setState(() => _showDone = true),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Task List ─────────────────────────────────
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : displayed.isEmpty
                          ? Center(
                              child: Text(
                                _showDone
                                    ? 'Belum ada tugas yang selesai'
                                    : 'Semua tugas sudah selesai 🎉',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textGrey,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                  20, 0, 20, 100),
                              itemCount: displayed.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = displayed[index];
                                return _TaskListTile(
                                  task: item.task,
                                  folderName: item.folderName,
                                  onToggle: () =>
                                      provider.toggleTask('', item.task.id),
                                  onDelete: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Hapus Tugas'),
                                        content: const Text(
                                            'Yakin ingin menghapus?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                context, false),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                context, true),
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await provider.deleteTask(item.task.id);
                                    }
                                  },
                                );
                              },
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

// ─── TAB BUTTON ──────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── TASK LIST TILE ──────────────────────────────────────────
class _TaskListTile extends StatelessWidget {
  final TaskModel task;
  final String folderName;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskListTile({
    required this.task,
    required this.folderName,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final deadlineStr = task.deadline != null
        ? '${DateFormat('HH.mm').format(task.deadline!)} - ${DateFormat('d MMMM yyyy', 'id_ID').format(task.deadline!)}'
        : '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (deadlineStr.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      deadlineStr,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: task.isDone ? Colors.green : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: task.isDone ? Colors.white : Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
