// lib/screens/home/widgets/folder_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/task_model.dart';
import '../../../services/task_service.dart';

class FolderCard extends StatelessWidget {
  final FolderModel folder;

  const FolderCard({
    super.key,
    required this.folder,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.read<TaskService>();

    return Card(
      child: ExpansionTile(
        title: Text(folder.name),
        children: folder.tasks.map((task) {
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
              icon: const Icon(Icons.delete),
              onPressed: () {
                service.deleteTask(task.id);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}