// lib/screens/home/widgets/add_folder_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/task_service.dart';

class AddFolderDialog extends StatelessWidget {
  const AddFolderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController();

    return AlertDialog(
      title: const Text("Tambah Folder"),
      content: TextField(controller: ctrl),
      actions: [
        TextButton(
          onPressed: () async {
            await context
                .read<TaskService>()
                .addFolder(name: ctrl.text);
            Navigator.pop(context);
          },
          child: const Text("OK"),
        )
      ],
    );
  }
}