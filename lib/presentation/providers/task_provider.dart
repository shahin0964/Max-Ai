import 'package:flutter/material.dart';
import '../../data/models/local_task.dart';
import '../../data/services/offline_task_service.dart';

class TaskProvider extends ChangeNotifier {
  final OfflineTaskService _service = OfflineTaskService();

  List<LocalTask> _tasks = [];
  bool _isLoading = false;

  List<LocalTask> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _service.getTasks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(String title, {DateTime? dueDate}) async {
    if (title.trim().isEmpty) return;
    await _service.addTask(title, dueDate: dueDate);
    await loadTasks();
  }

  Future<void> toggleTask(String id) async {
    await _service.toggleTask(id);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _service.deleteTask(id);
    await loadTasks();
  }

  Future<void> clearCompleted() async {
    await _service.clearCompleted();
    await loadTasks();
  }
}
