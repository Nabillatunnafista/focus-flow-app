// lib/models/task_model.dart

enum TaskStatus { pending, done }

class TaskModel {
  final String id;
  final String title;
  final String? categoryId;
  final String? categoryName;
  final DateTime? deadline;
  final String? submission; // e.g. "classroom", "email"
  TaskStatus status;
  final String? tag; // e.g. "Rabu", "Senin"

  TaskModel({
    required this.id,
    required this.title,
    this.categoryId,
    this.categoryName,
    this.deadline,
    this.submission,
    this.status = TaskStatus.pending,
    this.tag,
  });

  bool get isDone => status == TaskStatus.done;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'] as String)
          : null,
      submission: json['submission'] as String?,
      status: json['status'] == 'done' ? TaskStatus.done : TaskStatus.pending,
      tag: json['tag'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category_id': categoryId,
    'deadline': deadline?.toIso8601String(),
    'submission': submission,
    'status': status == TaskStatus.done ? 'done' : 'pending',
    'tag': tag,
  };

  TaskModel copyWith({TaskStatus? status}) {
    return TaskModel(
      id: id,
      title: title,
      categoryId: categoryId,
      categoryName: categoryName,
      deadline: deadline,
      submission: submission,
      status: status ?? this.status,
      tag: tag,
    );
  }
}

// ──────────────────────────────────────
// Category Model
// ──────────────────────────────────────

class TaskCategory {
  final String id;
  final String name;
  final List<TaskModel> tasks;
  final String? colorTag; // e.g. "Rabu", "Senin"

  const TaskCategory({
    required this.id,
    required this.name,
    required this.tasks,
    this.colorTag,
  });

  int get pendingCount => tasks.where((t) => !t.isDone).length;

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    final taskList = (json['tasks'] as List<dynamic>?)
            ?.map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];
    return TaskCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      tasks: taskList,
      colorTag: json['color_tag'] as String?,
    );
  }
}

// ──────────────────────────────────────
// Deadline / Today Deadline Model
// ──────────────────────────────────────

class DeadlineModel {
  final String id;
  final String title;
  final DateTime deadline;
  final String? submission;
  bool isDone;

  DeadlineModel({
    required this.id,
    required this.title,
    required this.deadline,
    this.submission,
    this.isDone = false,
  });

  factory DeadlineModel.fromJson(Map<String, dynamic> json) {
    return DeadlineModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      deadline: DateTime.parse(json['deadline'] as String),
      submission: json['submission'] as String?,
      isDone: json['is_done'] as bool? ?? false,
    );
  }
}

// ──────────────────────────────────────
// Mock Data — remove when API is ready
// ──────────────────────────────────────

class MockData {
  static List<TaskCategory> get categories => [
    TaskCategory(
      id: 'uncategorized',
      name: 'Belum Dikelompokkan',
      tasks: [
        TaskModel(
          id: 't1',
          title: 'nonton yutup tutorial jadi CEO',
          status: TaskStatus.pending,
        ),
        TaskModel(
          id: 't2',
          title: 'buka figma focusflow',
          status: TaskStatus.pending,
        ),
      ],
    ),
    TaskCategory(
      id: 'pbo',
      name: 'PBO',
      colorTag: 'Rabu',
      tasks: [
        TaskModel(
          id: 't3',
          title: 'Laprak minggu ke-4',
          status: TaskStatus.pending,
        ),
      ],
    ),
    TaskCategory(
      id: 'basis_data',
      name: 'Basis Data',
      tasks: [],
    ),
    TaskCategory(
      id: 'proyek_iot',
      name: 'Proyek IOT',
      tasks: [
        TaskModel(id: 't4', title: 'Desain skema sensor suhu', status: TaskStatus.pending),
        TaskModel(id: 't5', title: 'Setup MQTT broker lokal', status: TaskStatus.pending),
        TaskModel(id: 't6', title: 'Buat dashboard monitoring', status: TaskStatus.pending),
      ],
    ),
  ];

  static DeadlineModel get todayDeadline => DeadlineModel(
    id: 'd1',
    title: 'Workshop Pengembangan Agile',
    deadline: DateTime(2026, 4, 21, 23, 59),
    submission: 'classroom',
    isDone: false,
  );
}