import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/task_model.dart';
import 'api_client.dart';

class TaskService extends ChangeNotifier {
  List<TaskCategory> _categories = [];
  DeadlineModel? _todayDeadline;
  bool _isLoading = false;
  String? _error;

  List<TaskCategory> get categories => _categories;
  DeadlineModel? get todayDeadline => _todayDeadline;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Dio get _dio => ApiClient.instance.dio;

  Future<void> loadDashboard({bool useMock = false}) async {
    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        _fetchCategories(),
        _fetchTodayDeadline(),
      ]);
    } catch (e) {
      _error = 'Gagal memuat data: $e';
    }

    _setLoading(false);
  }

  Future<void> _fetchCategories() async {
    try {
      final resp = await _dio.get(ApiEndpoints.tasks);

      final data = resp.data;
      List listData = [];

      if (data is List) {
        listData = data;
      } else if (data is Map && data['data'] != null) {
        listData = data['data'];
      }

      _categories =
          listData.map((e) => TaskCategory.fromJson(e)).toList();

      notifyListeners();
    } catch (e) {
      _error = 'Gagal ambil data';
      notifyListeners();
    }
  }

  Future<void> _fetchTodayDeadline() async {
    try {
      final resp = await _dio.get(ApiEndpoints.deadlines);
      final data = resp.data;

      List listData = [];

      if (data is List) {
        listData = data;
      } else if (data is Map && data['data'] != null) {
        listData = data['data'];
      }

      if (listData.isNotEmpty) {
        _todayDeadline = DeadlineModel.fromJson(listData.first);
      }

      notifyListeners();
    } catch (_) {}
  }

  void markDeadlineDone() {
    if (_todayDeadline != null) {
      _todayDeadline!.isDone = true;
      notifyListeners();
    }
  }

  Future<void> toggleTask(String categoryId, String taskId) async {
    final catIdx = _categories.indexWhere((c) => c.id == categoryId);
    if (catIdx == -1) return;

    final taskIdx =
        _categories[catIdx].tasks.indexWhere((t) => t.id == taskId);
    if (taskIdx == -1) return;

    final task = _categories[catIdx].tasks[taskIdx];

    final newStatus =
        task.isDone ? TaskStatus.pending : TaskStatus.done;

    _categories[catIdx].tasks[taskIdx] =
        task.copyWith(status: newStatus);
    notifyListeners();

    try {
      await _dio.patch(
        ApiEndpoints.taskDone.replaceAll(':id', taskId),
        data: {
          'status': newStatus == TaskStatus.done ? 'done' : 'pending',
        },
      );
    } catch (_) {
      _categories[catIdx].tasks[taskIdx] = task;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    String? categoryId,
    DateTime? deadline,
  }) async {
    _setLoading(true);

    try {
      await _dio.post(
        ApiEndpoints.tasks,
        data: {
          'title': title,
          if (categoryId != null) 'category_id': categoryId,
          if (deadline != null)
            'deadline': deadline.toIso8601String(),
        },
      );

      await loadDashboard();
    } catch (e) {
      _error = 'Gagal tambah task';
      notifyListeners();
    }

    _setLoading(false);
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
  try {
    await _dio.delete(
      "${ApiEndpoints.tasks}/$taskId",
    );

    await loadDashboard(); // refresh data
  } catch (e) {
    _error = "Gagal hapus tugas";
    notifyListeners();
  }
}
}