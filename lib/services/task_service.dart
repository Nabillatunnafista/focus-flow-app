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
      final resp = await _dio.get(ApiEndpoints.tasks);

      final data = resp.data;

      List listData = [];

      if (data is List) {
        listData = data;
      } else if (data is Map && data['data'] != null) {
        listData = data['data'];
      }

      final tasks =
          listData.map((e) => TaskModel.fromJson(e)).toList();

      // sementara 1 folder (karena backend belum ada folder)
      _categories = [
        TaskCategory(
          id: "1",
          name: "Semua Tugas",
          tasks: tasks,
        )
      ];
    } catch (e) {
      _error = "Gagal load data";
    }

    _setLoading(false);
  }

  // ================= ADD FOLDER =================
  Future<void> addFolder({required String name}) async {
    try {
      await _dio.post(
        ApiEndpoints.tasks,
        data: {
          "name": name,
          "code": "FOLDER",
          "semester": "0",
        },
      );

      await loadDashboard();
    } catch (e) {
      _error = "Gagal tambah folder";
      notifyListeners();
    }
  }

  // ================= ADD TASK =================
  Future<void> addTask({
    required String title,
    String? categoryId,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.tasks,
        data: {
          "name": title,
          "code": "TASK",
          "semester": "4",
        },
      );

      await loadDashboard();
    } catch (e) {
      _error = "Gagal tambah task";
      notifyListeners();
    }
  }

  // ================= DELETE =================
  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete("${ApiEndpoints.tasks}/$id");
      await loadDashboard();
    } catch (e) {
      _error = "Gagal hapus task";
      notifyListeners();
    }
  }

  // ================= TOGGLE =================
  Future<void> toggleTask(String categoryId, String taskId) async {
    try {
      await _dio.patch(
        ApiEndpoints.taskDone.replaceAll(':id', taskId),
        data: {
          "is_done": true,
        },
      );

      await loadDashboard();
    } catch (e) {
      _error = "Gagal update task";
      notifyListeners();
    }
  }

  // ================= HELPER =================
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}