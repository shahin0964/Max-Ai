class LocalTask {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;

  LocalTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
  });

  LocalTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
  }) {
    return LocalTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
      };

  factory LocalTask.fromJson(Map<String, dynamic> json) => LocalTask(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      );
}
