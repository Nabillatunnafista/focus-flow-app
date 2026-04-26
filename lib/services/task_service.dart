// lib/services/task_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/task_model.dart';
import 'api_client.dart';

class TaskService extends ChangeNotifier {
  List<TaskCategory> _categories = [];
  List<DeadlineModel> _deadlines = [];
  bool _isLoading = false;
  String? _error;

  List<TaskCategory> get categories => _categories;
  List<DeadlineModel> get deadlines => _deadlines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Dio get _dio => ApiClient.instance.dio;

  // ================= LOAD DASHBOARD =================
  Future<void> loadDashboard({bool useMock = false}) async {
    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        _fetchTasks(),
        _fetchDeadlines(),
      ]);
    } catch (e) {
      _error = 'Gagal memuat data: $e';
    }

    _setLoading(false);
  }

  // ================= FETCH TASKS (GET /tasks) =================
  Future<void> _fetchTasks() async {
    try {
      final resp = await _dio.get(ApiEndpoints.listTasks);

      final data = resp.data;
      List listData = [];

      if (data is List) {
        listData = data;
      } else if (data is Map && data['data'] != null) {
        listData = data['data'];
      }

      final tasks = listData.map((e) => TaskModel.fromJson(e)).toList();

      // Bungkus dalam 1 TaskCategory
      _categories = [
        TaskCategory(
          id: "1",
          name: "Semua Tugas",
          tasks: tasks,
          colorTag: "Hari Ini",
        )
      ];

      notifyListeners();
    } catch (e) {
      debugPrint("FETCH TASKS ERROR: $e");
      _categories = [];
      notifyListeners();
    }
  }

  // ================= FETCH DEADLINES (GET /deadlines) =================
  Future<void> _fetchDeadlines() async {
    try {
      final resp = await _dio.get(ApiEndpoints.listDeadlines);

      final data = resp.data;
      List listData = [];

      if (data is List) {
        listData = data;
      } else if (data is Map && data['data'] != null) {
        listData = data['data'];
      }

      _deadlines = listData.map((e) => DeadlineModel.fromJson(e)).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("FETCH DEADLINES ERROR: $e");
      _deadlines = [];
      notifyListeners();
    }
  }

  // ================= CREATE TASK (POST /tasks) =================
  Future<void> createTask({
    required String title,
    DateTime? deadline,
    String? priority,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.createTask,
        data: {
          "name": title,
          "priority": priority ?? "medium",
          "deadline": deadline?.toIso8601String(),
        },
      );

      await loadDashboard();
    } catch (e) {
      _error = "Gagal tambah task: $e";
      notifyListeners();
      rethrow;
    }
  }

  // ================= UPDATE TASK (PATCH /tasks/:id) =================
  Future<void> updateTask({
    required String taskId,
    required String title,
    DateTime? deadline,
    String? priority,
  }) async {
    try {
      await _dio.patch(
        ApiEndpoints.updateTask.replaceAll(':id', taskId),
        data: {
          "name": title,
          "priority": priority,
          "deadline": deadline?.toIso8601String(),
        },
      );

      await loadDashboard();
    } catch (e) {
      _error = "Gagal update task: $e";
      notifyListeners();
      rethrow;
    }
  }

  // ================= DELETE TASK (DELETE /tasks/:id) =================
  Future<void> deleteTask(String taskId) async {
    try {
      await _dio.delete(
        ApiEndpoints.deleteTask.replaceAll(':id', taskId),
      );

      await loadDashboard();
    } catch (e) {
      _error = "Gagal hapus tugas: $e";
      notifyListeners();
      rethrow;
    }
  }

  // ================= TOGGLE TASK STATUS (PATCH /tasks/:id) =================
  Future<void> toggleTask(String taskId) async {
    // Cari task di kategori
    TaskModel? task;
    int categoryIdx = -1;
    int taskIdx = -1;

    for (int i = 0; i < _categories.length; i++) {
      final idx = _categories[i].tasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        categoryIdx = i;
        taskIdx = idx;
        task = _categories[i].tasks[idx];
        break;
      }
    }

    if (categoryIdx == -1 || taskIdx == -1 || task == null) return;

    final oldTask = task.copyWith();
    final newStatus = task.isDone ? TaskStatus.pending : TaskStatus.done;

    // Optimistic update
    _categories[categoryIdx].tasks[taskIdx] =
        task.copyWith(status: newStatus, isDone: !task.isDone);
    notifyListeners();

    try {
      await _dio.patch(
        ApiEndpoints.updateTask.replaceAll(':id', taskId),
        data: {
          "is_done": newStatus == TaskStatus.done,
        },
      );
    } catch (e) {
      // Rollback
      _categories[categoryIdx].tasks[taskIdx] = oldTask;
      notifyListeners();
      _error = "Gagal toggle task: $e";
    }
  }

  // ================= CREATE DEADLINE (POST /deadlines) =================
  Future<void> createDeadline({
    required String title,
    required DateTime deadline,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.createDeadline,
        data: {
          "name": title,
          "deadline": deadline.toIso8601String(),
        },
      );

      await _fetchDeadlines();
    } catch (e) {
      _error = "Gagal tambah deadline: $e";
      notifyListeners();
      rethrow;
    }
  }

  // ================= TOGGLE DEADLINE (PATCH /deadlines/:id/toggle) =================
  Future<void> toggleDeadline(String deadlineId) async {
    try {
      await _dio.patch(
        ApiEndpoints.toggleDeadline.replaceAll(':id', deadlineId),
      );

      await _fetchDeadlines();
    } catch (e) {
      _error = "Gagal toggle deadline: $e";
      notifyListeners();
      rethrow;
    }
  }

  // ================= DELETE DEADLINE (DELETE /deadlines/:id) =================
  Future<void> deleteDeadline(String deadlineId) async {
    try {
      await _dio.delete(
        ApiEndpoints.deleteDeadline.replaceAll(':id', deadlineId),
      );

      await _fetchDeadlines();
    } catch (e) {
      _error = "Gagal hapus deadline: $e";
      notifyListeners();
      rethrow;
    }
  }

  // ================= HELPER =================
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
