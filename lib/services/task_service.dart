// lib/services/task_service.dart
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

  // ── Load all data for Dashboard ────────────────────────
  Future<void> loadDashboard({bool useMock = true}) async {
    _setLoading(true);
    _error = null;
    try {
      if (useMock) {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 600));
        _categories = MockData.categories;
        _todayDeadline = MockData.todayDeadline;
      } else {
        await Future.wait([_fetchCategories(), _fetchTodayDeadline()]);
      }
    } catch (e) {
      _error = 'Gagal memuat data: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ── Fetch categories + tasks ───────────────────────────
  Future<void> _fetchCategories() async {
    final resp = await _dio.get(ApiEndpoints.tasks);
    final list = (resp.data as List<dynamic>)
        .map((c) => TaskCategory.fromJson(c as Map<String, dynamic>))
        .toList();
    _categories = list;
  }

  // ── Fetch today's deadline ─────────────────────────────
  Future<void> _fetchTodayDeadline() async {
    try {
      final resp = await _dio.get(ApiEndpoints.deadlines);
      final list = resp.data as List<dynamic>;
      if (list.isNotEmpty) {
        _todayDeadline =
            DeadlineModel.fromJson(list.first as Map<String, dynamic>);
      }
    } catch (_) {
      // No deadline today is fine
    }
  }

  // ── Toggle task completion ─────────────────────────────
  Future<void> toggleTask(String categoryId, String taskId) async {
    final catIdx = _categories.indexWhere((c) => c.id == categoryId);
    if (catIdx == -1) return;

    final taskIdx = _categories[catIdx].tasks.indexWhere((t) => t.id == taskId);
    if (taskIdx == -1) return;

    final task = _categories[catIdx].tasks[taskIdx];
    final newStatus =
        task.isDone ? TaskStatus.pending : TaskStatus.done;

    // Optimistic update
    _categories[catIdx].tasks[taskIdx] = task.copyWith(status: newStatus);
    notifyListeners();

    try {
      await _dio.patch(
        ApiEndpoints.taskDone.replaceAll(':id', taskId),
        data: {'status': newStatus == TaskStatus.done ? 'done' : 'pending'},
      );
    } catch (_) {
      // Rollback on failure
      _categories[catIdx].tasks[taskIdx] = task;
      notifyListeners();
    }
  }

  // ── Mark today's deadline as done ─────────────────────
  void markDeadlineDone() {
    if (_todayDeadline != null) {
      _todayDeadline!.isDone = true;
      notifyListeners();
    }
  }

  // ── Add task (stub — expand as needed) ────────────────
  Future<void> addTask({
    required String title,
    String? categoryId,
    DateTime? deadline,
    String? submission,
  }) async {
    try {
      final resp = await _dio.post(ApiEndpoints.tasks, data: {
        'title': title,
        if (categoryId != null) 'category_id': categoryId,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
        if (submission != null) 'submission': submission,
      });
      final newTask = TaskModel.fromJson(resp.data as Map<String, dynamic>);
      final catIdx =
          _categories.indexWhere((c) => c.id == (categoryId ?? 'uncategorized'));
      if (catIdx != -1) {
        _categories[catIdx].tasks.add(newTask);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Gagal menambah tugas.';
      notifyListeners();
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}