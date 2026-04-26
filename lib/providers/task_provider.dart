// lib/providers/task_provider.dart

import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final List<FolderModel> _folders = [
    FolderModel(
      id: '1',
      name: 'OOP',
      tag: null,
      tasks: [
        TaskModel(
          id: 't1',
          title: 'nonton yutup tutorial jadi CEO',
          deadline: DateTime.now(),
        ),
        TaskModel(
          id: 't2',
          title: 'buka figma focusflow',
          deadline: DateTime.now(),
        ),
      ],
    ),
    FolderModel(
      id: '2',
      name: 'PBO',
      tag: 'Rabu',
      tagColor: const Color(0xFF9B7EBD),
      tasks: [
        TaskModel(
          id: 't3',
          title: 'Laprak minggu ke-4',
          deadline: DateTime(2026, 4, 22, 23, 59),
        ),
      ],
    ),
    FolderModel(
      id: '3',
      name: 'Basis Data',
      tasks: [],
    ),
    FolderModel(
      id: '4',
      name: 'Proyek IOT',
      tasks: [
        TaskModel(id: 't4', title: 'Setup ESP32'),
        TaskModel(id: 't5', title: 'Buat diagram sensor'),
        TaskModel(id: 't6', title: 'Presentasi akhir'),
      ],
    ),
  ];

  List<FolderModel> get folders => List.unmodifiable(_folders);

  // ─── TODAY DEADLINES ─────────────────────────────────────────
  List<({String folderName, TaskModel task})> get todayDeadlines {
    final now = DateTime.now();
    final result = <({String folderName, TaskModel task})>[];

    for (final folder in _folders) {
      for (final task in folder.tasks) {
        if (task.deadline != null) {
          final d = task.deadline!;
          if (d.year == now.year && d.month == now.month && d.day == now.day) {
            result.add((folderName: folder.name, task: task));
          }
        }
      }
    }
    return result;
  }

  // ─── ADD FOLDER ───────────────────────────────────────────────
  void addFolder(String name, {String? tag}) {
    final folder = FolderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      tag: tag?.isNotEmpty == true ? tag : null,
    );
    _folders.add(folder);
    notifyListeners();
  }

  // ─── ADD TASK ─────────────────────────────────────────────────
  void addTask({
    required String folderId,
    required String title,
    DateTime? deadline,
    String? priority,
  }) {
    final idx = _folders.indexWhere((f) => f.id == folderId);
    if (idx == -1) return;

    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      deadline: deadline,
      priority: priority,
    );

    _folders[idx].tasks.add(task);
    notifyListeners();
  }

  // ─── TOGGLE TASK ─────────────────────────────────────────────
  void toggleTask(String folderId, String taskId) {
    final folderIdx = _folders.indexWhere((f) => f.id == folderId);
    if (folderIdx == -1) return;

    final taskIdx =
        _folders[folderIdx].tasks.indexWhere((t) => t.id == taskId);
    if (taskIdx == -1) return;

    _folders[folderIdx].tasks[taskIdx].isDone =
        !_folders[folderIdx].tasks[taskIdx].isDone;
    notifyListeners();
  }

  // ─── DELETE TASK ─────────────────────────────────────────────
  void deleteTask(String folderId, String taskId) {
    final folderIdx = _folders.indexWhere((f) => f.id == folderId);
    if (folderIdx == -1) return;

    _folders[folderIdx].tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  // ─── MARK DEADLINE DONE ──────────────────────────────────────
  void markTaskDone(String folderId, String taskId) {
    final folderIdx = _folders.indexWhere((f) => f.id == folderId);
    if (folderIdx == -1) return;

    final taskIdx =
        _folders[folderIdx].tasks.indexWhere((t) => t.id == taskId);
    if (taskIdx == -1) return;

    _folders[folderIdx].tasks[taskIdx].isDone = true;
    notifyListeners();
  }
}