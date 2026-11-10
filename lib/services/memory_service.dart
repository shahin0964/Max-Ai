import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/memory_item.dart';

class MemoryService extends ChangeNotifier {
  static final MemoryService instance = MemoryService._internal();
  MemoryService._internal();

  static const _kMemoryKey = 'maxai_memories_v1';
  late SharedPreferences _prefs;
  final List<MemoryItem> _items = [];

  List<MemoryItem> get items => List.unmodifiable(_items);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getStringList(_kMemoryKey) ?? [];
    _items.clear();
    for (final itemStr in raw) {
      try {
        final map = jsonDecode(itemStr) as Map<String, dynamic>;
        _items.add(MemoryItem.fromJson(map));
      } catch (e) {
        debugPrint('Error parsing memory item: $e');
      }
    }

    if (_items.isEmpty) {
      // Seed initial helpful memories
      _items.addAll([
        MemoryItem(
          id: const Uuid().v4(),
          title: 'AI Persona & Core',
          content: 'Max AI is an autonomous, on-device AI assistant inspired by OpenJarvis architecture.',
          category: 'identity',
          tags: ['system', 'persona'],
        ),
        MemoryItem(
          id: const Uuid().v4(),
          title: 'Owner Preferences',
          content: 'Prefers fast, concise responses, clean code solutions, and high-tech futuristic design.',
          category: 'preference',
          tags: ['preference', 'user'],
        ),
      ]);
      await _save();
    }
    notifyListeners();
  }

  Future<void> addMemory({
    required String title,
    required String content,
    String category = 'fact',
    List<String>? tags,
  }) async {
    final item = MemoryItem(
      id: const Uuid().v4(),
      title: title.trim(),
      content: content.trim(),
      category: category,
      tags: tags ?? [],
      createdAt: DateTime.now(),
    );
    _items.insert(0, item);
    await _save();
    notifyListeners();
  }

  Future<void> deleteMemory(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _items.clear();
    await _save();
    notifyListeners();
  }

  List<MemoryItem> search(String query) {
    if (query.isEmpty) return _items;
    final q = query.toLowerCase();
    return _items.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.content.toLowerCase().contains(q) ||
          item.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  String buildPromptContext() {
    if (_items.isEmpty) return '';
    final buffer = StringBuffer('\n\n--- [OpenJarvis Long-Term Memory Context] ---\n');
    for (final m in _items.take(8)) {
      buffer.writeln('- [${m.category.toUpperCase()}] ${m.title}: ${m.content}');
    }
    buffer.writeln('-------------------------------------------\n');
    return buffer.toString();
  }

  Future<void> _save() async {
    final list = _items.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs.setStringList(_kMemoryKey, list);
  }
}
