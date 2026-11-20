import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/local_task.dart';

class TaskTile extends StatelessWidget {
  final LocalTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted
              ? AppColors.surfaceLight
              : AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: IconButton(
          icon: Icon(
            task.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: task.isCompleted ? AppColors.success : AppColors.textMuted,
          ),
          onPressed: onToggle,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
            decoration:
                task.isCompleted ? TextDecoration.lineThrough : null,
            fontSize: 15,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
