import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/agent_task.dart';
import '../models/chat_message.dart';
import 'agent_tools_service.dart';
import 'ai_engine_service.dart';

class AgentExecutorService extends ChangeNotifier {
  static final AgentExecutorService instance = AgentExecutorService._internal();
  AgentExecutorService._internal();

  final List<AgentTask> _tasks = [];
  AgentTask? _activeTask;
  bool _isBusy = false;

  List<AgentTask> get tasks => List.unmodifiable(_tasks);
  AgentTask? get activeTask => _activeTask;
  bool get isBusy => _isBusy;

  Future<AgentTask> runAutonomousGoal(String goal) async {
    final task = AgentTask(
      id: const Uuid().v4(),
      goal: goal,
      status: TaskStatus.inProgress,
    );
    _tasks.insert(0, task);
    _activeTask = task;
    _isBusy = true;
    notifyListeners();

    try {
      // Step 1: Initial Cognitive Planning
      final step1 = AgentStep(
        stepNumber: 1,
        thought: 'Analyzing user goal and determining optimal action path: "$goal"',
        status: TaskStatus.inProgress,
      );
      task.steps.add(step1);
      notifyListeners();

      final systemPrompt = '''
You are an autonomous OpenJarvis agent executor.
${AgentToolsService.toolsDescription}

Given the goal, analyze what needs to be done.
If a tool is needed, respond with:
ACTION: tool_name
INPUT: tool_input_here

If no tool is needed or you are done, respond with:
FINAL_ANSWER: your comprehensive answer here.
''';

      final history = [
        ChatMessage(
          id: 'goal-input',
          role: MessageRole.user,
          content: 'Goal: $goal',
          timestamp: DateTime.now(),
        )
      ];

      // Turn 1: Model Plan & Action Decision
      final response1 = await AIEngineService.instance.generateResponse(
        history: history,
        customSystemPrompt: systemPrompt,
      );

      final text1 = response1.text;

      if (text1.contains('ACTION:') && text1.contains('INPUT:')) {
        final toolName = _extractRegex(text1, r'ACTION:\s*([a-zA-Z0-9_]+)');
        final toolInput = _extractRegex(text1, r'INPUT:\s*(.*)');

        step1.status = TaskStatus.completed;

        // Step 2: Tool Execution
        final step2 = AgentStep(
          stepNumber: 2,
          thought: 'Invoking autonomous agent tool "$toolName" with input "$toolInput"',
          toolName: toolName,
          toolInput: toolInput,
          status: TaskStatus.toolExecuting,
        );
        task.steps.add(step2);
        notifyListeners();

        final observation =
            await AgentToolsService.instance.executeTool(toolName, toolInput);
        step2.toolOutput = observation;
        step2.status = TaskStatus.completed;
        notifyListeners();

        // Step 3: Synthesis
        final step3 = AgentStep(
          stepNumber: 3,
          thought: 'Synthesizing tool observation into final resolution.',
          status: TaskStatus.inProgress,
        );
        task.steps.add(step3);
        notifyListeners();

        history.add(ChatMessage(
          id: 'step1-agent',
          role: MessageRole.assistant,
          content: text1,
          timestamp: DateTime.now(),
        ));
        history.add(ChatMessage(
          id: 'step2-tool',
          role: MessageRole.user,
          content: 'OBSERVATION: $observation\nNow formulate the FINAL_ANSWER.',
          timestamp: DateTime.now(),
        ));

        final response2 = await AIEngineService.instance.generateResponse(
          history: history,
          customSystemPrompt: systemPrompt,
        );

        step3.status = TaskStatus.completed;
        task.finalResult = _cleanFinalAnswer(response2.text);
        task.status = TaskStatus.completed;
      } else {
        step1.status = TaskStatus.completed;
        task.finalResult = _cleanFinalAnswer(text1);
        task.status = TaskStatus.completed;
      }
    } catch (e) {
      task.status = TaskStatus.failed;
      task.finalResult = 'Agent execution encountered an anomaly: $e';
    } finally {
      task.updatedAt = DateTime.now();
      _isBusy = false;
      notifyListeners();
    }

    return task;
  }

  String _extractRegex(String source, String pattern) {
    final reg = RegExp(pattern, caseSensitive: false);
    final match = reg.firstMatch(source);
    return match?.group(1)?.trim() ?? '';
  }

  String _cleanFinalAnswer(String raw) {
    if (raw.contains('FINAL_ANSWER:')) {
      return raw.substring(raw.indexOf('FINAL_ANSWER:') + 13).trim();
    }
    return raw.trim();
  }
}
