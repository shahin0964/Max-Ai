import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  static const String _memoryKey = 'max_ai_long_term_memory';
  final TextEditingController _searchController = TextEditingController();
  List<String> _allMemories = [];
  List<String> _filteredMemories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_memoryKey) ?? [
      'user_nickname: Shahin',
      'favorite_ai_model: Gemini 3.8 Flash',
      'preferred_environment: Termux Android',
      'developer_role: Autonomous AI Architect',
      'app_identity: Max AI (com.max.ai)',
    ];
    setState(() {
      _allMemories = list;
      _filteredMemories = list;
      _isLoading = false;
    });
  }

  Future<void> _saveMemoriesList(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_memoryKey, list);
    setState(() {
      _allMemories = list;
      _filterMemories(_searchController.text);
    });
  }

  void _filterMemories(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredMemories = _allMemories);
    } else {
      final q = query.toLowerCase();
      setState(() {
        _filteredMemories = _allMemories
            .where((m) => m.toLowerCase().contains(q))
            .toList();
      });
    }
  }

  void _showAddMemoryDialog() {
    final keyController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.surfaceLight),
        ),
        title: const Text(
          'Remember New Fact / Preference',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Topic / Key (e.g. coffee, hobby, city)',
                labelText: 'Memory Key',
                labelStyle: TextStyle(color: AppColors.neonCyan),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'What should Max AI remember?',
                labelText: 'Content / Detail',
                labelStyle: TextStyle(color: AppColors.neonCyan),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final k = keyController.text.trim();
              final c = contentController.text.trim();
              if (k.isNotEmpty && c.isNotEmpty) {
                final updated = List<String>.from(_allMemories)..add('$k: $c');
                await _saveMemoriesList(updated);
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save Fact'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMemory(int index) async {
    final itemToRemove = _filteredMemories[index];
    final updated = List<String>.from(_allMemories)..remove(itemToRemove);
    await _saveMemoriesList(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Continuous Long-Term Memory',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.neonCyan),
            onPressed: _showAddMemoryDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Memory Stat Capsule
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology_rounded, color: AppColors.neonCyan, size: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_allMemories.length} Facts Saved',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Max AI recalls these preferences across sessions',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMemories,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceCard,
                hintText: 'Search stored memories...',
                prefixIcon: const Icon(Icons.search, color: AppColors.neonCyan),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          _filterMemories('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.surfaceLight),
                ),
              ),
            ),
          ),

          // Memories List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.neonCyan))
                : _filteredMemories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.storage_rounded, color: AppColors.textMuted, size: 48),
                            const SizedBox(height: 12),
                            const Text(
                              'No memories found.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _showAddMemoryDialog,
                              icon: const Icon(Icons.add, color: AppColors.neonCyan),
                              label: const Text('Add Memory', style: TextStyle(color: AppColors.neonCyan)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredMemories.length,
                        itemBuilder: (context, index) {
                          final item = _filteredMemories[index];
                          final parts = item.split(': ');
                          final key = parts[0];
                          final val = parts.length > 1 ? parts.sublist(1).join(': ') : '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.surfaceLight),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.electricBlue.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.bookmark_border_rounded,
                                      color: AppColors.neonCyan, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        key,
                                        style: const TextStyle(
                                          color: AppColors.neonCyan,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        val.isNotEmpty ? val : item,
                                        style: const TextStyle(color: Colors.white, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      color: Colors.white38, size: 20),
                                  onPressed: () => _deleteMemory(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
