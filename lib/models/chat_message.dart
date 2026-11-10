enum MessageRole { user, assistant, system, tool }

class ToolCallRecord {
  final String toolName;
  final String inputSummary;
  final String outputSummary;
  final bool isSuccess;

  ToolCallRecord({
    required this.toolName,
    required this.inputSummary,
    required this.outputSummary,
    this.isSuccess = true,
  });

  Map<String, dynamic> toJson() => {
        'toolName': toolName,
        'inputSummary': inputSummary,
        'outputSummary': outputSummary,
        'isSuccess': isSuccess,
      };

  factory ToolCallRecord.fromJson(Map<String, dynamic> json) => ToolCallRecord(
        toolName: json['toolName'] ?? '',
        inputSummary: json['inputSummary'] ?? '',
        outputSummary: json['outputSummary'] ?? '',
        isSuccess: json['isSuccess'] ?? true,
      );
}

class ChatMessage {
  final String id;
  final MessageRole role;
  String content;
  final DateTime timestamp;
  final String? modelName;
  final String? providerName;
  final int? latencyMs;
  final List<ToolCallRecord>? toolCalls;
  final List<String>? reasoningSteps;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.modelName,
    this.providerName,
    this.latencyMs,
    this.toolCalls,
    this.reasoningSteps,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'modelName': modelName,
        'providerName': providerName,
        'latencyMs': latencyMs,
        'toolCalls': toolCalls?.map((t) => t.toJson()).toList(),
        'reasoningSteps': reasoningSteps,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] ?? '',
        role: MessageRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => MessageRole.user,
        ),
        content: json['content'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        modelName: json['modelName'],
        providerName: json['providerName'],
        latencyMs: json['latencyMs'],
        toolCalls: (json['toolCalls'] as List<dynamic>?)
            ?.map((t) => ToolCallRecord.fromJson(t as Map<String, dynamic>))
            .toList(),
        reasoningSteps: (json['reasoningSteps'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
      );
}
