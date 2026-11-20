import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  void _showAddTaskDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Offline Task', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Task description...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<TaskProvider>().addTask(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined, color: AppColors.textSecondary),
            tooltip: 'Clear Completed',
            onPressed: () => taskProvider.clearCompleted(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : taskProvider.tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No offline tasks yet',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add via chat with "add task <name>" or tap +',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    return TaskTile(
                      task: task,
                      onToggle: () => taskProvider.toggleTask(task.id),
                      onDelete: () => taskProvider.deleteTask(task.id),
                    );
                  },
                ),
    );
  }
}
