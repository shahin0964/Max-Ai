import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../../data/services/tool_registry_service.dart';

class YaadeinScreen extends StatefulWidget {
  const YaadeinScreen({super.key});

  @override
  State<YaadeinScreen> createState() => _YaadeinScreenState();
}

class _YaadeinScreenState extends State<YaadeinScreen> {
  bool _autoRememberEnabled = true;
  List<String> _memories = [];

  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Daily Morning Briefing',
      'steps': 'Weather · Top News · Tasks',
      'prompt': 'Good morning! Give me the weather, top news, and daily motivation.',
    },
    {
      'title': 'Research & Summarize',
      'steps': 'In-depth Analysis',
      'prompt': 'Summarize the latest breakthrough in AI technology this week.',
    },
    {
      'title': 'Termux System Health',
      'steps': 'Diagnostics · Memory',
      'prompt': 'Run system diagnostics and let me know device status.',
    },
    {
      'title': 'Creative Script Generator',
      'steps': 'Shorts · Viral Script',
      'prompt': 'Write a viral 30-second YouTube Shorts script about future tech.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    final list = await ToolRegistryService.getStoredMemories();
    if (list.isEmpty) {
      _memories = [
        'Shahin prefers direct, high-speed execution.',
        'Primary device: Android Phone with Termux rootless tools.',
        'Favorite AI Model: Gemini 3.8 Flash.',
      ];
    } else {
      _memories = List.from(list);
    }
    if (mounted) setState(() {});
  }

  void _runTask(Map<String, dynamic> task) {
    context.read<ChatProvider>().sendMessage(task['prompt']!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Executing "${task['title']}" with Max AI! ⚡'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _addNewMemory() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101422),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
        title: const Text('Add Memory Fact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g. Shahin lives in Dhaka, loves AI...',
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0B0E18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F2FE), foregroundColor: Colors.black),
            onPressed: () async {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                await ToolRegistryService.saveQuickMemory(text);
                setState(() => _memories.add(text));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fact saved to Yaadein memory!')));
              }
            },
            child: const Text('Save Fact', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111624),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Yaadein (Continuous Memory)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Auto Remember Switch Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111624),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C4DFF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.psychology_rounded, color: Color(0xFF7C4DFF), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Continuous Learning',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Automatically retains facts & preferences',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _autoRememberEnabled,
                          activeColor: const Color(0xFF00F2FE),
                          onChanged: (v) => setState(() => _autoRememberEnabled = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  _sectionHeader('ACTIVE KNOWLEDGE FACTS', onAdd: _addNewMemory),

                  ..._memories.map((m) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111624),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bookmark_border_rounded, color: Color(0xFF00F2FE), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                m,
                                style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 18),
                  _sectionHeader('AUTONOMOUS TASKS & MACROS'),

                  ..._tasks.map((t) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111624),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00F2FE).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.bolt_rounded, color: Color(0xFF00F2FE), size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t['title']!,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    t['steps']!,
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E293B),
                                foregroundColor: const Color(0xFF00F2FE),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () => _runTask(t),
                              child: const Text('Run', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {VoidCallback? onAdd}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.9,
            ),
          ),
          if (onAdd != null)
            GestureDetector(
              onTap: onAdd,
              child: const Text(
                '+ Add Fact',
                style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold, fontSize: 11.5),
              ),
            ),
        ],
      ),
    );
  }
}
