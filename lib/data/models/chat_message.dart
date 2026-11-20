enum MessageSender { user, assistant, system }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isOffline;
  final int? tokenCount;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isOffline = false,
    this.tokenCount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'sender': sender.name,
        'timestamp': timestamp.toIso8601String(),
        'isOffline': isOffline,
        'tokenCount': tokenCount,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        text: json['text'] as String,
        sender: MessageSender.values.firstWhere(
          (e) => e.name == json['sender'],
          orElse: () => MessageSender.assistant,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        isOffline: json['isOffline'] as bool? ?? false,
        tokenCount: json['tokenCount'] as int?,
      );
}
