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
        _fetchMatkul(), // 🔥 FIX
        _fetchTodayDeadline(),
      ]);
    } catch (e) {
      _error = 'Gagal memuat data: $e';
    }

    _setLoading(false);
  }

  // ================= FETCH MATKUL =================
  Future<void> _fetchMatkul() async {
    try {
      final resp = await _dio.get(ApiEndpoints.tasks); // /matkul

      final data = resp.data;
      List listData = [];

      if (data is List) {
        listData = data;
      } else if (data is Map && data['data'] != null) {
        listData = data['data'];
      }

      // 🔥 MAP MATKUL → CATEGORY
      _categories = listData.map((e) {
        return TaskCategory(
          id: e['id'].toString(),
          name: e['name'] ?? '',
          tasks: [], // 🔥 kosong (karena backend belum ada task)
          colorTag: e['code'] ?? '',
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("FETCH MATKUL ERROR: $e");
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

  // ================= ADD MATKUL =================
  Future<void> addTask({
    required String title,
    DateTime? deadline,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.tasks, // /matkul
        data: {
          "name": title,
          "code": "GEN101",
          "semester": deadline != null
              ? deadline.year.toString()
              : "4",
        },
      );

      await loadDashboard();
    } catch (e) {
      _error = "Gagal tambah folder";
      notifyListeners();
      rethrow;
    }
  }

  // ================= DELETE MATKUL =================
  Future<void> deleteTask(String taskId) async {
    try {
      await _dio.delete("${ApiEndpoints.tasks}/$taskId");

      await loadDashboard();
    } catch (e) {
      _error = "Gagal hapus folder";
      notifyListeners();
    }
  }

  // ================= DISABLED =================
  Future<void> toggleTask(String categoryId, String taskId) async {
    // 🔥 DISABLE (backend belum support)
    debugPrint("Toggle disabled: backend belum support task");
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}