// lib/services/task_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/task_model.dart';
import 'api_client.dart';

class TaskService extends ChangeNotifier {
  List<FolderModel> _folders = [];
  bool _isLoading = false;
  String? _error;

  List<FolderModel> get folders => _folders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Dio get _dio => ApiClient.instance.dio;

  Future<void> loadDashboard() async {
    _setLoading(true);

    try {
      final matkulResp = await _dio.get(ApiEndpoints.matkul);
      final taskResp = await _dio.get(ApiEndpoints.tasks);

      final matkulData =
          matkulResp.data['data'] ?? matkulResp.data;
      final taskData =
          taskResp.data['data'] ?? taskResp.data;

      List<FolderModel> result = [];

      for (var m in matkulData) {
        final folderId = m['id'].toString();

        final tasks = taskData
            .where((t) =>
                t['matkul_id'].toString() == folderId)
            .map<TaskModel>((e) => TaskModel.fromJson(e))
            .toList();

        result.add(
          FolderModel(
            id: folderId,
            name: m['name'],
            tasks: tasks,
          ),
        );
      }

      _folders = result;
    } catch (e) {
      _error = "Gagal load";
    }

    _setLoading(false);
  }

  Future<void> addFolder({required String name}) async {
    await _dio.post(
      ApiEndpoints.matkul,
      data: {"name": name},
    );
    await loadDashboard();
  }

  Future<void> addTask({
    required String title,
    required String folderId,
  }) async {
    await _dio.post(
      ApiEndpoints.tasks,
      data: {
        "title": title,
        "matkul_id": folderId,
      },
    );
    await loadDashboard();
  }

  Future<void> deleteTask(String id) async {
    await _dio.delete(
      ApiEndpoints.taskById.replaceAll(':id', id),
    );
    await loadDashboard();
  }

  Future<void> toggleTask({
    required String taskId,
    required bool value,
  }) async {
    await _dio.patch(
      ApiEndpoints.taskById.replaceAll(':id', taskId),
      data: {"is_done": value},
    );
    await loadDashboard();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}