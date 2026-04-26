// lib/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskCategoryCard extends StatefulWidget {
  final TaskCategory category;
  final bool initiallyExpanded;

  const TaskCategoryCard({
    super.key,
    required this.category,
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        initiallyExpanded: widget.initiallyExpanded,
        onExpansionChanged: (v) => setState(() => _expanded = v),

        title: Text(cat.name),

        trailing: Icon(
          _expanded
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down,
        ),

        children: cat.tasks.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("Belum ada tugas"),
                )
              ]
            : cat.tasks.map((task) {
                return ListTile(
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (v) {
                      if (v == null) return;

                      context.read<TaskService>().toggleTask(
                            cat.id,       // categoryId
                            task.id,      // taskId
                          );
                    },
                  ),
                  title: Text(task.title),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context
                          .read<TaskService>()
                          .deleteTask(task.id);
                    },
                  ),
                );
              }).toList(),
      ),
    );
  }
}