// lib/services/task_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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

  // ================= LOAD DASHBOARD =================
  Future<void> loadDashboard({bool useMock = false}) async {
    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        _fetchTasks(),
        _fetchTodayDeadline(),
      ]);
    } catch (e) {
      _error = 'Gagal memuat data: $e';
    }

    _setLoading(false);
  }

  // ================= FETCH TASK =================
  Future<void> _fetchTasks() async {
    try {
      final resp = await _dio.get(ApiEndpoints.tasks);

      final data = resp.data;

      List listData = [];

      if (data is List) {
        listData = data;
      } else if (data is Map && data['data'] != null) {
        listData = data['data'];
      }

      // 🔥 MAP KE TASKMODEL
      final tasks = listData
          .map((e) => TaskModel.fromJson(e))
          .toList();

      // 🔥 BACKEND FLAT → BUNGKUS JADI 1 CATEGORY
      _categories = [
        TaskCategory(
          id: "1",
          name: "Tugas Saya",
          tasks: tasks,
          colorTag: "Hari Ini",
        )
      ];

      notifyListeners();
    } catch (e) {
      debugPrint("FETCH ERROR: $e");
      _categories = [];
      notifyListeners();
    }
  }

  // ================= DEADLINE =================
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
    } catch (e) {
      debugPrint("DEADLINE ERROR: $e");
    }
  }

  void markDeadlineDone() {
    if (_todayDeadline != null) {
      _todayDeadline!.isDone = true;
      notifyListeners();
    }
  }

  // ================= ADD TASK =================
  Future<void> addTask({
    required String title,
    DateTime? deadline,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.tasks,
        data: {
          "name": title, // 🔥 WAJIB (bukan title)
          "code": "GEN101",
          "semester": deadline != null
              ? deadline.year.toString()
              : "4",
        },
      );

      // 🔥 REFRESH DATA
      await loadDashboard();
    } catch (e) {
      _error = "Gagal tambah task";
      notifyListeners();
      rethrow;
    }
  }

  // ================= DELETE =================
  Future<void> deleteTask(String taskId) async {
    try {
      await _dio.delete("${ApiEndpoints.tasks}/$taskId");

      await loadDashboard();
    } catch (e) {
      _error = "Gagal hapus tugas";
      notifyListeners();
    }
  }

  // ================= TOGGLE =================
  Future<void> toggleTask(String categoryId, String taskId) async {
    final catIdx =
        _categories.indexWhere((c) => c.id == categoryId);
    if (catIdx == -1) return;

    final taskIdx =
        _categories[catIdx].tasks.indexWhere((t) => t.id == taskId);
    if (taskIdx == -1) return;

    final task = _categories[catIdx].tasks[taskIdx];

    final newStatus =
        task.isDone ? TaskStatus.pending : TaskStatus.done;

    // 🔥 OPTIMISTIC UPDATE
    _categories[catIdx].tasks[taskIdx] =
        task.copyWith(status: newStatus);

    notifyListeners();

    try {
      await _dio.patch(
        ApiEndpoints.taskDone.replaceAll(':id', taskId),
        data: {
          "is_done": newStatus == TaskStatus.done,
        },
      );
    } catch (e) {
      // 🔥 ROLLBACK
      _categories[catIdx].tasks[taskIdx] = task;
      notifyListeners();
    }
  }

  // ================= HELPER =================
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}