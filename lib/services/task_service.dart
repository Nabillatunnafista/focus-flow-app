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
        _fetchCategories(),
        _fetchDeadline(),
      ]);
    } catch (e) {
      _error = 'Gagal load: $e';
    }

    _setLoading(false);
  }

  // ================= FETCH FOLDER =================
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

      _categories = listData.map((e) {
        return TaskCategory(
          id: e['id'].toString(),
          name: e['name'] ?? '',
          tasks: [],
          colorTag: e['code'],
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("FETCH ERROR: $e");
      _categories = [];
      notifyListeners();
    }
  }

  // ================= DEADLINE =================
  Future<void> _fetchDeadline() async {
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

  // ================= ADD FOLDER =================
  Future<void> addFolder({
    required String name,
    String? code,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.tasks,
        data: {
          "name": name,
          "code": code ?? "GEN101",
          "semester": "4",
        },
      );

      await loadDashboard(); // 🔥 refresh UI
    } catch (e) {
      _error = "Gagal tambah folder";
      notifyListeners();
    }
  }

  // ================= DELETE FOLDER =================
  Future<void> deleteFolder(String id) async {
    try {
      await _dio.delete("${ApiEndpoints.tasks}/$id");

      await loadDashboard();
    } catch (e) {
      _error = "Gagal hapus folder";
      notifyListeners();
    }
  }

  // ================= DEADLINE DONE =================
  void markDeadlineDone() {
    if (_todayDeadline != null) {
      _todayDeadline!.isDone = true;
      notifyListeners();
    }
  }

  // ================= HELPER =================
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}