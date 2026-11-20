import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/local_task.dart';

class OfflineTaskService {
  static const String _tasksKey = 'max_ai_local_tasks';
  final _uuid = const Uuid();

  Future<List<LocalTask>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) return [];

    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => LocalTask.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTasks(List<LocalTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await prefs.setString(_tasksKey, encoded);
  }

  Future<LocalTask> addTask(String title, {DateTime? dueDate}) async {
    final tasks = await getTasks();
    final newTask = LocalTask(
      id: _uuid.v4(),
      title: title.trim(),
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );
    tasks.insert(0, newTask);
    await saveTasks(tasks);
    return newTask;
  }

  Future<void> toggleTask(String id) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(isCompleted: !tasks[index].isCompleted);
      await saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    await saveTasks(tasks);
  }

  Future<int> clearCompleted() async {
    final tasks = await getTasks();
    final before = tasks.length;
    tasks.removeWhere((t) => t.isCompleted);
    await saveTasks(tasks);
    return before - tasks.length;
  }

  /// Parses natural language input for offline task commands.
  /// Returns a friendly response if handled, or null if not a task command.
  Future<String?> processOfflineInput(String input) async {
    final text = input.trim().toLowerCase();

    // 1. Add Task: "add task Buy groceries" or "task: Buy groceries" or "নোট করো: বাজার করা"
    if (text.startsWith('add task ') || text.startsWith('task: ') || text.startsWith('নোট করো ') || text.startsWith('নতুন কাজ ')) {
      String title = input;
      if (text.startsWith('add task ')) title = input.substring(9);
      if (text.startsWith('task: ')) title = input.substring(6);
      if (text.startsWith('নোট করো ')) title = input.substring(9);
      if (text.startsWith('নতুন কাজ ')) title = input.substring(9);

      final task = await addTask(title);
      return '✅ [Offline Mode] টাস্ক সফলভাবে সেভ করা হয়েছে:\n"${task.title}"';
    }

    // 2. List Tasks: "list tasks", "my tasks", "সব কাজ দেখাও", "টাস্ক লিস্ট"
    if (text == 'list tasks' || text == 'tasks' || text == 'টাস্ক' || text == 'সব কাজ' || text.contains('task list')) {
      final tasks = await getTasks();
      if (tasks.isEmpty) {
        return '📋 [Offline Mode] আপনার কোনো পেন্ডিং টাস্ক নেই!';
      }
      final buffer = StringBuffer('📋 [Offline Mode] আপনার টাস্ক তালিকা:\n\n');
      for (int i = 0; i < tasks.length; i++) {
        final t = tasks[i];
        final status = t.isCompleted ? '☑️ (সম্পন্ন)' : '⬜ (বাকি)';
        buffer.writeln('${i + 1}. $status ${t.title}');
      }
      return buffer.toString().trim();
    }

    // 3. Clear Completed
    if (text.contains('clear completed') || text.contains('মুছে ফেলো')) {
      final count = await clearCompleted();
      return '🗑️ [Offline Mode] $count টি সম্পন্ন হওয়া টাস্ক মুছে ফেলা হয়েছে।';
    }

    // 4. Default offline fallback
    return '⚡ [Offline Mode] ইন্টারনেট সংযোগ নেই।\n'
           'আপনি অফলাইনে লোকাল টাস্ক পরিচালনা করতে পারেন।\n'
           'উদাহরণ:\n'
           '• "add task কাল সকাল ১০টায় মিটিং"\n'
           '• "list tasks" (সব কাজ দেখতে)\n'
           '• "clear completed"';
  }
}
