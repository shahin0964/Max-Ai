import 'package:flutter/material.dart';
import '../../models/memory_item.dart';
import '../../services/memory_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddMemoryDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String category = 'fact';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.cyan, width: 1),
            ),
            title: const Text(
              'NEW EPISODIC MEMORY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppTheme.cyan,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Title / Subject',
                      labelStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Details / Directive',
                      labelStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Category:',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['fact', 'preference', 'identity', 'task'].map((cat) {
                      final isSelected = category == cat;
                      return ChoiceChip(
                        label: Text(cat.toUpperCase()),
                        selected: isSelected,
                        selectedColor: AppTheme.cyan.withValues(alpha: 0.25),
                        backgroundColor: AppTheme.surface,
                        side: BorderSide(
                          color: isSelected ? AppTheme.cyan : Colors.white12,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.cyan : AppTheme.textSecondary,
                        ),
                        onSelected: (val) {
                          if (val) setDlgState(() => category = cat);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    MemoryService.instance.addMemory(
                      title: titleController.text,
                      content: contentController.text,
                      category: category,
                    );
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cyan,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Store Fact'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memory = MemoryService.instance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.violet),
          tooltip: 'Open Slidebar',
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('OPENJARVIS MEMORY STACK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.cyan),
            onPressed: () => _showAddMemoryDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              // Search Glass Field
              GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                borderRadius: 20,
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: AppTheme.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Search stored memories, facts & tags...',
                          hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16, color: AppTheme.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Category Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['ALL', 'FACT', 'PREFERENCE', 'IDENTITY', 'TASK'].map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        selectedColor: AppTheme.cyan.withValues(alpha: 0.25),
                        backgroundColor: AppTheme.surface,
                        side: BorderSide(
                          color: isSel ? AppTheme.cyan : Colors.white12,
                          width: 0.8,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? AppTheme.cyan : AppTheme.textSecondary,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 10),

              // Memory Items List
              Expanded(
                child: ListenableBuilder(
                  listenable: memory,
                  builder: (context, _) {
                    var items = memory.search(_searchController.text);
                    if (_selectedCategory != 'ALL') {
                      items = items
                          .where((m) =>
                              m.category.toUpperCase() == _selectedCategory)
                          .toList();
                    }

                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          'No memory records match the query.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildMemoryCard(item);
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

  Widget _buildMemoryCard(MemoryItem item) {
    Color catColor = AppTheme.cyan;
    if (item.category == 'preference') catColor = AppTheme.violet;
    if (item.category == 'identity') catColor = AppTheme.emerald;
    if (item.category == 'task') catColor = AppTheme.amber;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        padding: const EdgeInsets.all(12),
        borderColor: catColor.withValues(alpha: 0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: catColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.textMuted),
                  onPressed: () => MemoryService.instance.deleteMemory(item.id),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.content,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.35,
              ),
            ),
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: item.tags.map((t) {
                  return Text(
                    '#$t',
                    style: TextStyle(
                      fontSize: 10,
                      color: catColor.withValues(alpha: 0.8),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
