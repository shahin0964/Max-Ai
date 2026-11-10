enum TaskStatus { pending, inProgress, toolExecuting, completed, failed }

class AgentStep {
  final int stepNumber;
  final String thought;
  final String? toolName;
  final String? toolInput;
  String? toolOutput;
  TaskStatus status;
  final DateTime timestamp;

  AgentStep({
    required this.stepNumber,
    required this.thought,
    this.toolName,
    this.toolInput,
    this.toolOutput,
    this.status = TaskStatus.inProgress,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'thought': thought,
        'toolName': toolName,
        'toolInput': toolInput,
        'toolOutput': toolOutput,
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AgentStep.fromJson(Map<String, dynamic> json) => AgentStep(
        stepNumber: json['stepNumber'] ?? 1,
        thought: json['thought'] ?? '',
        toolName: json['toolName'],
        toolInput: json['toolInput'],
        toolOutput: json['toolOutput'],
        status: TaskStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => TaskStatus.completed,
        ),
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      );
}

class AgentTask {
  final String id;
  final String goal;
  TaskStatus status;
  final List<AgentStep> steps;
  String? finalResult;
  final DateTime createdAt;
  DateTime updatedAt;

  AgentTask({
    required this.id,
    required this.goal,
    this.status = TaskStatus.pending,
    List<AgentStep>? steps,
    this.finalResult,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : steps = steps ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'goal': goal,
        'status': status.name,
        'steps': steps.map((s) => s.toJson()).toList(),
        'finalResult': finalResult,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AgentTask.fromJson(Map<String, dynamic> json) => AgentTask(
        id: json['id'] ?? '',
        goal: json['goal'] ?? '',
        status: TaskStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => TaskStatus.pending,
        ),
        steps: (json['steps'] as List<dynamic>?)
            ?.map((s) => AgentStep.fromJson(s as Map<String, dynamic>))
            .toList(),
        finalResult: json['finalResult'],
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      );
}
