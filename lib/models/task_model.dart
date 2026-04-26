// lib/models/task_model.dart

import 'package:flutter/material.dart';

// ================= TASK =================
class TaskModel {
  final String id;
  final String title;
  bool isDone;
  final DateTime? deadline;
  final String? priority;

  TaskModel({
    required this.id,
    required this.title,
    this.isDone = false,
    this.deadline,
    this.priority,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    bool? isDone,
    DateTime? deadline,
    String? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
    );
  }
}

// ================= FOLDER =================
class FolderModel {
  final String id;
  final String name;
  final String? tag;
  final Color tagColor;
  final List<TaskModel> tasks;

  FolderModel({
    required this.id,
    required this.name,
    this.tag,
    this.tagColor = const Color(0xFF9B7EBD),
    List<TaskModel>? tasks,
  }) : tasks = tasks ?? [];

  FolderModel copyWith({
    String? id,
    String? name,
    String? tag,
    Color? tagColor,
    List<TaskModel>? tasks,
  }) {
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      tagColor: tagColor ?? this.tagColor,
      tasks: tasks ?? List.from(this.tasks),
    );
  }

  int get taskCount => tasks.length;

  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    return tasks.where((t) {
      if (t.deadline == null) return false;
      final d = t.deadline!;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
  }
}