class MemoryItem {
  final String id;
  final String title;
  final String content;
  final String category; // 'preference', 'fact', 'identity', 'task'
  final DateTime createdAt;
  final List<String> tags;

  MemoryItem({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'fact',
    DateTime? createdAt,
    List<String>? tags,
  })  : createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'tags': tags,
      };

  factory MemoryItem.fromJson(Map<String, dynamic> json) => MemoryItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        category: json['category'] ?? 'fact',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        tags: (json['tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
      );
}
