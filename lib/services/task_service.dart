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

  // ================= LOAD =================
  Future<void> loadDashboard() async {
    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        _fetchFoldersAndTasks(),
        _fetchTodayDeadline(),
      ]);
    } catch (e) {
      _error = 'Gagal load data';
    }

    _setLoading(false);
  }

  // ================= FETCH FOLDER + TASK =================
  Future<void> _fetchFoldersAndTasks() async {
    try {
      final matkulRes = await _dio.get(ApiEndpoints.tasks);
      final deadlineRes = await _dio.get(ApiEndpoints.deadlines);

      List matkulList = [];
      List deadlineList = [];

      if (matkulRes.data is Map && matkulRes.data['data'] != null) {
        matkulList = matkulRes.data['data'];
      }

      if (deadlineRes.data is Map && deadlineRes.data['data'] != null) {
        deadlineList = deadlineRes.data['data'];
      }

      // 🔥 GROUP TASK KE FOLDER
      List<TaskCategory> temp = [];

      for (var m in matkulList) {
        final matkulId = m['id'];

        final tasks = deadlineList
            .where((d) => d['matkul_id'] == matkulId)
            .map((d) => TaskModel.fromJson(d))
            .toList();

        temp.add(TaskCategory(
          id: matkulId,
          name: m['name'] ?? 'Tanpa Nama',
          tasks: tasks,
        ));
      }

      _categories = temp;

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

      if (resp.data is Map && resp.data['data'] != null) {
        final list = resp.data['data'];

        if (list.isNotEmpty) {
          _todayDeadline = DeadlineModel.fromJson(list.first);
        }
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

  // ================= ADD FOLDER =================
  Future<void> addFolder(String name) async {
    try {
      await _dio.post(
        ApiEndpoints.tasks,
        data: {
          "name": name,
        },
      );

      await loadDashboard();
    } catch (e) {
      _error = "Gagal tambah folder";
      notifyListeners();
      rethrow;
    }
  }

  // ================= ADD TASK =================
  Future<void> addTask({
    required String title,
    required String matkulId,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.deadlines,
        data: {
          "title": title,
          "matkul_id": matkulId,
        },
      );

      await loadDashboard();
    } catch (e) {
      _error = "Gagal tambah task";
      notifyListeners();
      rethrow;
    }
  }

  // ================= DELETE TASK =================
  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete("${ApiEndpoints.deadlines}/$id");

      await loadDashboard();
    } catch (e) {
      _error = "Gagal hapus task";
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