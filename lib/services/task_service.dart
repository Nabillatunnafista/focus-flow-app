// lib/services/task_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/task_model.dart';
import 'api_client.dart';

typedef TodayDeadlineItem = ({String folderName, TaskModel task});

class TaskService extends ChangeNotifier {
  final List<FolderModel> _folders = [];
  final List<TodayDeadlineItem> _todayDeadlines = [];
  final Set<String> _deadlineIds = <String>{};
  bool _isLoading = false;
  String? _error;

  List<FolderModel> get folders => List.unmodifiable(_folders);
  List<TodayDeadlineItem> get todayDeadlines =>
      List.unmodifiable(_todayDeadlines);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Dio get _dio => ApiClient.instance.dio;

  Future<void> loadDashboard() async {
    _setLoading(true);
    _error = null;

    try {
      await _fetchFolders();
      await _fetchTasks();
      await _fetchTodayDeadlines();
    } on DioException catch (e) {
      _error = _parseError(e);
    } catch (e) {
      _error = 'Gagal memuat data: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addFolder(String name, {String? tag}) async {
    try {
      await _dio.post(
        ApiEndpoints.createMatkul,
        data: {
          'name': name,
          if (tag != null && tag.isNotEmpty) 'tag': tag,
        },
      );
      await loadDashboard();
    } on DioException catch (e) {
      _error = _parseError(e);
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'Gagal tambah pelajaran: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addTask({
    required String folderId,
    required String title,
    DateTime? deadline,
    String? priority,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.createTask,
        data: {
          'name': title,
          'title': title,
          if (folderId.isNotEmpty) 'matkul_id': folderId,
          if (deadline != null) 'deadline': deadline.toIso8601String(),
          if (priority != null && priority.isNotEmpty)
            'priority': _normalizePriority(priority),
        },
      );

      await loadDashboard();
    } on DioException catch (e) {
      _error = _parseError(e);
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'Gagal tambah task: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleTask(String folderId, String taskId) async {
    final found = _findTask(folderId: folderId, taskId: taskId) ??
        _findTask(taskId: taskId);
    if (found == null) return;

    final oldValue = found.task.isDone;
    found.task.isDone = !oldValue;
    notifyListeners();

    try {
      await _patchTaskStatus(taskId, found.task.isDone);
    } on DioException catch (e) {
      // Keep optimistic UI state even if network fails; show error instead of rollback
      _error = _parseError(e);
      notifyListeners();
    } catch (e) {
      _error = 'Gagal ubah status task: $e';
      notifyListeners();
    }
  }

  Future<void> markTaskDone(String folderId, String taskId) async {
    await _markTaskDone(taskId: taskId, folderId: folderId);
  }

  Future<void> markTaskDoneById(String taskId) async {
    await _markTaskDone(taskId: taskId);
  }

  Future<void> deleteTask(String taskId, {String? folderId}) async {
    final found = _findTask(folderId: folderId, taskId: taskId) ??
        _findTask(taskId: taskId);

    TaskModel? removed;
    if (found != null) {
      removed = _folders[found.folderIndex].tasks.removeAt(found.taskIndex);
      notifyListeners();
    }

    try {
      await _dio.delete(ApiEndpoints.deleteTask.replaceAll(':id', taskId));
    } on DioException catch (e) {
      if (removed != null && found != null) {
        _folders[found.folderIndex].tasks.insert(found.taskIndex, removed);
      }
      _error = _parseError(e);
      notifyListeners();
      rethrow;
    } catch (e) {
      if (removed != null && found != null) {
        _folders[found.folderIndex].tasks.insert(found.taskIndex, removed);
      }
      _error = 'Gagal hapus task: $e';
      notifyListeners();
      rethrow;
    }
  }

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
          'name': title,
          if (deadline != null) 'deadline': deadline.toIso8601String(),
          if (priority != null && priority.isNotEmpty)
            'priority': _normalizePriority(priority),
        },
      );

      await loadDashboard();
    } on DioException catch (e) {
      _error = _parseError(e);
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'Gagal update task: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _fetchFolders() async {
    _folders.clear();

    try {
      final resp = await _dio.get(ApiEndpoints.listMatkul);
      final listData = _extractList(resp.data);

      for (final item in listData) {
        final json = _asMap(item);
        if (json.isEmpty) continue;

        final id = _readString(json, const ['id', '_id', 'matkul_id']) ?? '';
        final name = _readString(json, const ['name', 'title', 'matkul']) ?? '';
        final tag = _readString(json, const ['tag', 'label', 'day']);

        if (id.isEmpty || name.isEmpty) continue;
        if (_folders.any((f) => f.id == id)) continue;

        _folders.add(
          FolderModel(
            id: id,
            name: name,
            tag: tag,
          ),
        );
      }
    } catch (_) {
      // Keep empty list; tasks can still be shown in fallback folder.
    }
  }

  Future<void> _fetchTasks() async {
    for (final folder in _folders) {
      folder.tasks.clear();
    }

    final resp = await _dio.get(ApiEndpoints.listTasks);
    final listData = _extractList(resp.data);
    FolderModel? uncategorized;

    for (final item in listData) {
      final json = _asMap(item);
      if (json.isEmpty) continue;

      final task = TaskModel.fromJson(json);
      if (task.id.isEmpty || task.title.isEmpty) continue;

      final folderId = _readString(
        json,
        const ['matkul_id', 'matkulId', 'folder_id', 'category_id'],
      );
      final folderName = _readString(
        json,
        const ['matkul_name', 'matkulName', 'folder_name', 'category_name'],
      );

      FolderModel? target;
      if (folderId != null && folderId.isNotEmpty) {
        for (final folder in _folders) {
          if (folder.id == folderId) {
            target = folder;
            break;
          }
        }
      }

      if (target == null && folderName != null && folderName.isNotEmpty) {
        for (final folder in _folders) {
          if (folder.name.toLowerCase() == folderName.toLowerCase()) {
            target = folder;
            break;
          }
        }
      }

      target ??= uncategorized ??=
          FolderModel(id: 'uncategorized', name: 'Belum Dikelompokkan');
      target.tasks.add(task);
    }

    if (uncategorized != null && uncategorized.tasks.isNotEmpty) {
      _folders.add(uncategorized);
    }

    if (_folders.isEmpty) {
      _folders.add(FolderModel(id: 'uncategorized', name: 'Semua Tugas'));
    }

    notifyListeners();
  }

  Future<void> _fetchTodayDeadlines() async {
    _todayDeadlines
      ..clear()
      ..addAll(_buildTodayDeadlinesFromFolders());

    _deadlineIds.clear();

    try {
      final resp = await _dio.get(ApiEndpoints.listDeadlines);
      final listData = _extractList(resp.data);
      final apiItems = <TodayDeadlineItem>[];

      for (final item in listData) {
        final json = _asMap(item);
        if (json.isEmpty) continue;

        final task = TaskModel.fromJson(json);
        if (task.id.isNotEmpty) {
          _deadlineIds.add(task.id);
        }
        if (task.deadline == null || !_isToday(task.deadline!)) continue;

        final folderName = _readString(
              json,
              const [
                'matkul_name',
                'matkulName',
                'folder_name',
                'category_name'
              ],
            ) ??
            'Deadline';

        apiItems.add((folderName: folderName, task: task));
      }

      if (apiItems.isNotEmpty) {
        _todayDeadlines
          ..clear()
          ..addAll(apiItems);
      }
    } catch (e) {
      debugPrint('FETCH DEADLINES ERROR: $e');
    }

    notifyListeners();
  }

  Future<void> _markTaskDone({
    required String taskId,
    String? folderId,
  }) async {
    final found = _findTask(folderId: folderId, taskId: taskId) ??
        _findTask(taskId: taskId);
    if (found != null) {
      if (found.task.isDone) return;

      final oldValue = found.task.isDone;
      found.task.isDone = true;
      notifyListeners();

      try {
        await _patchTaskStatus(taskId, true);
      } on DioException catch (e) {
        found.task.isDone = oldValue;
        _error = _parseError(e);
        notifyListeners();
      } catch (e) {
        found.task.isDone = oldValue;
        _error = 'Gagal mengubah status task: $e';
        notifyListeners();
      }
      return;
    }

    if (_deadlineIds.contains(taskId)) {
      try {
        await _dio.patch(ApiEndpoints.toggleDeadline.replaceAll(':id', taskId));
        await _fetchTodayDeadlines();
      } on DioException catch (e) {
        _error = _parseError(e);
        notifyListeners();
      } catch (e) {
        _error = 'Gagal menyelesaikan deadline: $e';
        notifyListeners();
      }
      return;
    }
  }

  Future<void> _patchTaskStatus(String taskId, bool isDone) async {
    final resp = await _dio.patch(
      ApiEndpoints.updateTask.replaceAll(':id', taskId),
      data: {
        // include multiple keys for broader backend compatibility
        'is_done': isDone,
        'isDone': isDone,
        'completed': isDone ? 1 : 0,
        'status': isDone ? 'done' : 'pending',
      },
    );

    // If API returns updated task object, apply it to local model to avoid desync
    try {
      final data = resp.data;
      final map =
          _asMap(data is Map && data['data'] != null ? data['data'] : data);
      if (map.isNotEmpty) {
        final updated = TaskModel.fromJson(map);
        final lookup = _findTask(taskId: taskId);
        if (lookup != null) {
          _folders[lookup.folderIndex].tasks[lookup.taskIndex] = updated;
          notifyListeners();
        }
      }
    } catch (_) {
      // ignore parsing errors; optimistically keep local state
    }
  }

  _TaskLookup? _findTask({String? folderId, required String taskId}) {
    if (folderId != null && folderId.isNotEmpty) {
      final folderIndex = _folders.indexWhere((f) => f.id == folderId);
      if (folderIndex != -1) {
        final taskIndex =
            _folders[folderIndex].tasks.indexWhere((t) => t.id == taskId);
        if (taskIndex != -1) {
          return _TaskLookup(
            folderIndex: folderIndex,
            taskIndex: taskIndex,
            task: _folders[folderIndex].tasks[taskIndex],
          );
        }
      }
    }

    for (var i = 0; i < _folders.length; i++) {
      final taskIndex = _folders[i].tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        return _TaskLookup(
          folderIndex: i,
          taskIndex: taskIndex,
          task: _folders[i].tasks[taskIndex],
        );
      }
    }

    return null;
  }

  List<TodayDeadlineItem> _buildTodayDeadlinesFromFolders() {
    final items = <TodayDeadlineItem>[];
    for (final folder in _folders) {
      for (final task in folder.tasks) {
        if (task.deadline != null && _isToday(task.deadline!)) {
          items.add((folderName: folder.name, task: task));
        }
      }
    }
    return items;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) return inner;
    }
    if (data is Map) {
      final inner = data['data'];
      if (inner is List) return inner;
    }
    return const <dynamic>[];
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return const <String, dynamic>{};
  }

  String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final str = value.toString().trim();
      if (str.isNotEmpty) return str;
    }
    return null;
  }

  bool _isToday(DateTime value) {
    final now = DateTime.now();
    return value.year == now.year &&
        value.month == now.month &&
        value.day == now.day;
  }

  String _normalizePriority(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized == 'tinggi') return 'high';
    if (normalized == 'rendah') return 'low';
    if (normalized == 'sedang') return 'medium';
    return normalized.isEmpty ? 'medium' : normalized;
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error']?['message'];
      if (message != null) return message.toString();
    }
    if (data is Map) {
      final message = data['message'];
      if (message != null) return message.toString();
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Server tidak terjangkau.';
    }
    return 'Terjadi kesalahan sistem.';
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}

class _TaskLookup {
  final int folderIndex;
  final int taskIndex;
  final TaskModel task;

  const _TaskLookup({
    required this.folderIndex,
    required this.taskIndex,
    required this.task,
  });
}
