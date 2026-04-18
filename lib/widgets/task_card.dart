// lib/widgets/task_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/task_model.dart';

class TaskCategoryCard extends StatefulWidget {
  final TaskCategory category;
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
    final hasTag = cat.colorTag != null;
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
          leading: null,
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
                _TagChip(label: cat.colorTag!),
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
          // If has items, show checkboxes; else show nothing
          children: hasItems
              ? cat.tasks
                    .map((task) => _TaskRow(
                          task: task,
                          onToggle: () => widget.onToggleTask(task.id),
                        ))
                    .toList()
              : [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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

class _TaskRow extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  const _TaskRow({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Checkbox(
            value: task.isDone,
            onChanged: (_) => onToggle(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: Text(
              task.title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: task.isDone ? AppColors.textGrey : AppColors.textDark,
                decoration:
                    task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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