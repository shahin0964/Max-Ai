import 'package:flutter/material.dart';
import '../../models/agent_task.dart';
import '../../services/agent_executor_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/agent_step_timeline.dart';
import '../../widgets/glass_panel.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  final TextEditingController _goalController = TextEditingController();

  void _dispatchGoal([String? preset]) {
    final text = (preset ?? _goalController.text).trim();
    if (text.isEmpty) return;

    _goalController.clear();
    AgentExecutorService.instance.runAutonomousGoal(text);
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final executor = AgentExecutorService.instance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.amber),
          tooltip: 'Open Slidebar',
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('AUTONOMOUS AGENT HUB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppTheme.amber, size: 20),
            onPressed: () => _showAgentInfoDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Input Glass Box
              GlassPanel(
                borderColor: AppTheme.amber.withValues(alpha: 0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_mode, color: AppTheme.amber, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'MISSION DIRECTIVE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppTheme.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _goalController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText:
                            'e.g. Inspect device memory, search latest news on local LLMs, and store result to memory.',
                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListenableBuilder(
                      listenable: executor,
                      builder: (context, _) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: executor.isBusy ? null : () => _dispatchGoal(),
                            icon: executor.isBusy
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : const Icon(Icons.play_arrow, size: 18),
                            label: Text(executor.isBusy ? 'EXECUTING...' : 'DISPATCH AGENT'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Quick preset mission goals
              const Text(
                'MISSION TEMPLATES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTemplateChip(
                      '🔋 Check Telemetry & Diagnose',
                      'Fetch device telemetry, inspect battery & memory levels, and generate a brief optimization health report.',
                    ),
                    _buildTemplateChip(
                      '🌐 Deep Web Research',
                      'Search the web for OpenJarvis multimodal capabilities and summarize the key findings.',
                    ),
                    _buildTemplateChip(
                      '💾 Memory Sync',
                      'Recall all stored user facts from memory and suggest 2 helpful daily routines.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Active & Past Tasks
              Expanded(
                child: ListenableBuilder(
                  listenable: executor,
                  builder: (context, _) {
                    final tasks = executor.tasks;
                    if (tasks.isEmpty) {
                      return const Center(
                        child: Text(
                          'No autonomous tasks executed yet.\nEnter a mission directive above to start.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskView(task);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String label, String goal) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton(
        onPressed: () => _dispatchGoal(goal),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0x33FFAA00)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildTaskView(AgentTask task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassPanel(
        borderColor: task.status == TaskStatus.completed
            ? AppTheme.emerald.withValues(alpha: 0.3)
            : AppTheme.amber.withValues(alpha: 0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  task.status == TaskStatus.completed
                      ? Icons.check_circle
                      : Icons.track_changes,
                  size: 16,
                  color: task.status == TaskStatus.completed
                      ? AppTheme.emerald
                      : AppTheme.amber,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.goal,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Step Timeline
            AgentStepTimeline(steps: task.steps),

            // Final Result
            if (task.finalResult != null && task.finalResult!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.cyan.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.task_alt, size: 14, color: AppTheme.cyan),
                        SizedBox(width: 6),
                        Text(
                          'MISSION RESOLUTION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppTheme.cyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.finalResult!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAgentInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.amber, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.hub, color: AppTheme.amber),
            SizedBox(width: 8),
            Text(
              'OpenJarvis ReAct Loop',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'Max AI utilizes an autonomous ReAct (Reasoning + Acting) execution engine. When given a mission, it determines tool requirements (Web Search, Device Telemetry, Memory Query, Math) and chains sequential observations to solve complex goals.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood', style: TextStyle(color: AppTheme.amber)),
          ),
        ],
      ),
    );
  }
}
