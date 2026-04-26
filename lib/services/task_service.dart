// lib/services/task_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/task_model.dart';
import 'api_client.dart';

class TaskService extends ChangeNotifier {
  List<TaskCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<TaskCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Dio get _dio => ApiClient.instance.dio;

  // ================= LOAD =================
  Future<void> loadDashboard() async {
    _setLoading(true);
    _error = null;

    try {
      await _fetchFoldersWithTasks();
    } catch (e) {
      _error = 'Gagal load data';
    }

    _setLoading(false);
  }

  // ================= FETCH FOLDER + TASK =================
  Future<void> _fetchFoldersWithTasks() async {
    try {
      final resp = await _dio.get(ApiEndpoints.tasks); // /matkul

      final data = resp.data;
      List listData = [];

      if (data is List) {
        listData = data;
      } else if (data is Map && data['data'] != null) {
        listData = data['data'];
      }

      List<TaskCategory> result = [];

      for (var folder in listData) {
        final folderId = folder['id'].toString();

        // ambil task per folder
        List<TaskModel> tasks = [];
        try {
          final taskResp = await _dio.get(
            "/tasks?matkul_id=$folderId",
          );

          final taskData = taskResp.data;
          List listTask = [];

          if (taskData is List) {
            listTask = taskData;
          } else if (taskData is Map && taskData['data'] != null) {
            listTask = taskData['data'];
          }

          tasks =
              listTask.map((e) => TaskModel.fromJson(e)).toList();
        } catch (_) {}

        result.add(
          TaskCategory(
            id: folderId,
            name: folder['name'] ?? 'Folder',
            tasks: tasks,
          ),
        );
      }

      _categories = result;
      notifyListeners();
    } catch (e) {
      debugPrint("ERROR FETCH: $e");
      _categories = [];
      notifyListeners();
    }
  }

  // ================= ADD FOLDER =================
  Future<void> addFolder({required String name}) async {
    try {
      await _dio.post(
        ApiEndpoints.tasks,
        data: {"name": name},
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
    required String folderId,
  }) async {
    try {
      await _dio.post(
        "/tasks",
        data: {
          "title": title,
          "matkul_id": folderId,
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
  Future<void> deleteTask(String taskId) async {
    try {
      await _dio.delete("/tasks/$taskId");
      await loadDashboard();
    } catch (e) {
      _error = "Gagal hapus";
      notifyListeners();
    }
  }

  // ================= TOGGLE =================
  Future<void> toggleTask(String taskId, bool value) async {
    try {
      await _dio.patch(
        "/tasks/$taskId",
        data: {"is_done": value},
      );

      await loadDashboard();
    } catch (_) {}
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}