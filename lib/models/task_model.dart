// lib/models/task_model.dart

enum TaskStatus { pending, done }

class TaskModel {
  final String id;
  final String title;
  final TaskStatus status;

  TaskModel({
    required this.id,
    required this.title,
    required this.status,
  });

  bool get isDone => status == TaskStatus.done;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'].toString(),
      title: json['name'] ?? '',
      status: json['is_done'] == true
          ? TaskStatus.done
          : TaskStatus.pending,
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    TaskStatus? status,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
    );
  }
}

// ================= CATEGORY =================
class TaskCategory {
  final String id;
  final String name;
  final List<TaskModel> tasks;

  // 🔥 TAMBAHAN BIAR TIDAK ERROR
  final String? colorTag;

  TaskCategory({
    required this.id,
    required this.name,
    required this.tasks,
    this.colorTag,
  });
}

// ================= DEADLINE =================
class DeadlineModel {
  String title;
  DateTime deadline;
  bool isDone;

  DeadlineModel({
    required this.title,
    required this.deadline,
    this.isDone = false,
  });

  factory DeadlineModel.fromJson(Map<String, dynamic> json) {
    return DeadlineModel(
      title: json['name'] ?? 'Deadline',
      deadline: DateTime.tryParse(json['deadline'] ?? '') ??
          DateTime.now(),
    );
  }
}