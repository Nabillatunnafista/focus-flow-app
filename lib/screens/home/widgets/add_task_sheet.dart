// lib/screens/home/widgets/add_task_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/task_service.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _ctrl = TextEditingController();
  String? _folderId;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TaskService>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _ctrl),
          DropdownButton(
            items: service.folders.map((f) {
              return DropdownMenuItem(
                value: f.id,
                child: Text(f.name),
              );
            }).toList(),
            onChanged: (v) => _folderId = v,
          ),
          ElevatedButton(
            onPressed: () async {
              await service.addTask(
                title: _ctrl.text,
                folderId: _folderId!,
              );
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}