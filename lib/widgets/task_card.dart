// lib/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.read<TaskService>();

    return ListTile(
      leading: Checkbox(
        value: task.isDone,
        onChanged: (v) {
          service.toggleTask(
            taskId: task.id,
            value: v!,
          );
        },
      ),
      title: Text(task.title),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          service.deleteTask(task.id);
        },
      ),
    );
  }
}