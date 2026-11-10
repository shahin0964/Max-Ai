import 'package:flutter/material.dart';
import '../models/agent_task.dart';
import '../theme/app_theme.dart';
import 'glass_panel.dart';

class AgentStepTimeline extends StatelessWidget {
  final List<AgentStep> steps;

  const AgentStepTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.hub, size: 14, color: AppTheme.amber),
              SizedBox(width: 6),
              Text(
                'AGENT EXECUTION TIMELINE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.amber,
                ),
              ),
            ],
          ),
        ),
        ...steps.map((step) => _buildStepCard(step)),
      ],
    );
  }

  Widget _buildStepCard(AgentStep step) {
    Color statusColor = AppTheme.cyan;
    IconData statusIcon = Icons.check_circle_outline;

    switch (step.status) {
      case TaskStatus.pending:
        statusColor = AppTheme.textMuted;
        statusIcon = Icons.hourglass_empty;
        break;
      case TaskStatus.inProgress:
        statusColor = AppTheme.cyan;
        statusIcon = Icons.sync;
        break;
      case TaskStatus.toolExecuting:
        statusColor = AppTheme.amber;
        statusIcon = Icons.build_circle_outlined;
        break;
      case TaskStatus.completed:
        statusColor = AppTheme.emerald;
        statusIcon = Icons.check_circle;
        break;
      case TaskStatus.failed:
        statusColor = AppTheme.rose;
        statusIcon = Icons.error_outline;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        padding: const EdgeInsets.all(12),
        borderColor: statusColor.withValues(alpha: 0.3),
        backgroundColor: AppTheme.surface.withValues(alpha: 0.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'STEP ${step.stepNumber}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step.toolName != null ? 'Tool: ${step.toolName}' : 'Reasoning Thought',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                Icon(statusIcon, size: 14, color: statusColor),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              step.thought,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
            if (step.toolOutput != null && step.toolOutput!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.emerald.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OBSERVATION',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.emerald,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.toolOutput!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppTheme.textPrimary,
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
}
