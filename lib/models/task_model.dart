// lib/models/task_model.dart

enum TaskStatus { pending, done }

class TaskModel {
  final String id;
  final String title;
  final TaskStatus status;

  TaskModel({
    required this.id,
    required this.title,
    this.status = TaskStatus.pending, // 🔥 FIX
  });

  bool get isDone => status == TaskStatus.done;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      status: (json['is_done'] ?? false)
          ? TaskStatus.done
          : TaskStatus.pending,
    );
  }
}

class FolderModel {
  final String id;
  final String name;
  final List<TaskModel> tasks;

  FolderModel({
    required this.id,
    required this.name,
    required this.tasks,
  });
}