import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/tool_registry_service.dart';

class ToolsManagerScreen extends StatefulWidget {
  const ToolsManagerScreen({super.key});

  @override
  State<ToolsManagerScreen> createState() => _ToolsManagerScreenState();
}

class _ToolsManagerScreenState extends State<ToolsManagerScreen> {
  final ToolRegistryService _toolRegistry = ToolRegistryService();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'System & Termux',
    'Communication',
    'Screen & Touch',
    'Hardware',
    'Entertainment',
    'Memory & Macro',
  ];

  String _getCategoryForTool(String name) {
    if (name.contains('termux') || name == 'open_app') return 'System & Termux';
    if (name.contains('whatsapp') || name == 'make_call' || name == 'send_sms') return 'Communication';
    if (name.contains('tap') || name.contains('screen') || name.contains('swipe')) return 'Screen & Touch';
    if (name.contains('torch') || name.contains('volume')) return 'Hardware';
    if (name.contains('youtube') || name.contains('spotify') || name.contains('weather') || name.contains('search')) return 'Entertainment';
    return 'Memory & Macro';
  }

  void _showTestRunDialog(Map<String, dynamic> tool) {
    final name = tool['name'] as String;
    final params = (tool['parameters']?['properties'] as Map<String, dynamic>?) ?? {};
    final controllers = <String, TextEditingController>{};

    for (final key in params.keys) {
      if (key == 'command') controllers[key] = TextEditingController(text: 'uname -a');
      else if (key == 'app_name') controllers[key] = TextEditingController(text: 'WhatsApp');
      else if (key == 'phone_or_name') controllers[key] = TextEditingController(text: 'Rahul');
      else if (key == 'message') controllers[key] = TextEditingController(text: 'Hello from Max AI!');
      else if (key == 'location') controllers[key] = TextEditingController(text: 'Dhaka, Bangladesh');
      else if (key == 'query') controllers[key] = TextEditingController(text: 'Cyberpunk Synthwave');
      else if (key == 'text') controllers[key] = TextEditingController(text: 'Install');
      else if (key == 'macro_name') controllers[key] = TextEditingController(text: 'gemini image');
      else controllers[key] = TextEditingController(text: '50');
    }

    String? outputText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D142C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt_rounded, color: AppColors.neonCyan, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  Text(
                    tool['description'] ?? '',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  ...params.entries.map((e) {
                    final pName = e.key;
                    final pDesc = e.value['description'] ?? pName;
                    final ctrl = controllers[pName];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: ctrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: pName,
                          labelStyle: const TextStyle(color: AppColors.neonCyan),
                          hintText: pDesc,
                          filled: true,
                          fillColor: AppColors.surfaceCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.surfaceLight),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 10),

                  // Execute Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonCyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'Execute Tool Now',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        final args = <String, dynamic>{};
                        controllers.forEach((k, v) {
                          if (k == 'level_percent' || k == 'x' || k == 'y') {
                            args[k] = int.tryParse(v.text) ?? 50;
                          } else if (k == 'enabled') {
                            args[k] = v.text.toLowerCase() == 'true' || v.text == '1';
                          } else {
                            args[k] = v.text;
                          }
                        });

                        final result = await _toolRegistry.executeTool(name, args);
                        setModalState(() {
                          outputText = result;
                        });
                      },
                    ),
                  ),

                  if (outputText != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF030712),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neonCyan.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Output Terminal Result:',
                            style: TextStyle(color: AppColors.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            outputText!,
                            style: const TextStyle(
                              color: Color(0xFF4ADE80),
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tools = ToolRegistryService.toolsSchema;
    final filteredTools = _selectedCategory == 'All'
        ? tools
        : tools.where((t) => _getCategoryForTool(t['name'] as String) == _selectedCategory).toList();

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
          '19 Extracted Tools Manager',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Filter Category Chips
          Container(
            height: 44,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSel = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.electricBlue : AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel ? AppColors.neonCyan : AppColors.surfaceLight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSel ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Tools List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredTools.length,
              itemBuilder: (context, index) {
                final tool = filteredTools[index];
                final name = tool['name'] as String;
                final desc = tool['description'] as String;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.neonCyan.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.terminal_rounded, color: AppColors.neonCyan, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.online.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: AppColors.online,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        desc,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.neonCyan,
                              side: const BorderSide(color: AppColors.neonCyan),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                            label: const Text('Test Run'),
                            onPressed: () => _showTestRunDialog(tool),
                          ),
                        ],
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
