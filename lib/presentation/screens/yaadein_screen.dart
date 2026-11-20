import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/rainbow_edge_glow.dart';
import 'chat_screen.dart';
import 'vision_screen.dart';

class YaadeinScreen extends StatefulWidget {
  const YaadeinScreen({super.key});

  @override
  State<YaadeinScreen> createState() => _YaadeinScreenState();
}

class _YaadeinScreenState extends State<YaadeinScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _autoRememberEnabled = true;

  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'gemini se poochho',
      'steps': '8 steps · sawaal · built-in',
      'prompt': 'Tell me the latest world news and summary for today.',
    },
    {
      'title': 'chatgpt se poochho',
      'steps': '8 steps · sawaal · built-in',
      'prompt': 'Write a creative message and plan my day.',
    },
    {
      'title': 'gemini video',
      'steps': '16 steps · video prompt · built-in',
      'prompt': 'Create a video concept and script for YouTube Shorts.',
    },
    {
      'title': 'gemini image',
      'steps': '17 steps · image prompt · built-in',
      'prompt': 'Generate a prompt for a photorealistic 3D portrait.',
    },
    {
      'title': 'chatgpt image',
      'steps': '14 steps · image prompt · built-in',
      'prompt': 'Describe a cyberpunk city in extreme detail.',
    },
  ];

  final List<String> _memories = [
    'Shahin likes fast AI responses and direct execution.',
    'Prefers Hinglish & Bengali communication style.',
    'Primary device: Android Phone with Termux rootless tools.',
  ];

  void _runTask(Map<String, dynamic> task) {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage(task['prompt']!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Executing "${task['title']}" in background!')),
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
  }

  void _addNewMemory() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add to Memory (Yaadein)', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter a fact, preference, or note...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => _memories.add(controller.text.trim()));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fact saved to Maya memory!')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final edgeGlow = context.watch<ChatProvider>().edgeGlowEnabled;

    return RainbowEdgeGlow(
      enabled: edgeGlow,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFEBF3FB),
        drawer: CustomDrawer(selectedIndex: 3, onSelectIndex: (_) {}),
        body: SafeArea(
          child: Column(
            children: [
              // Header matching frame_011.jpg
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Color(0x103060A0), blurRadius: 10, offset: Offset(0, 3)),
                          ],
                        ),
                        child: const Icon(Icons.menu_rounded, color: Color(0xFF1E293B), size: 22),
                      ),
                    ),
                    const Text(
                      'Yaadein',
                      style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Color(0x103060A0), blurRadius: 10, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B), size: 22),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  children: [
                    // Section: Mere baare me
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mere baare me',
                          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF2563EB)),
                          onPressed: _addNewMemory,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ..._memories.map((m) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0C3060A0), blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.psychology_rounded, color: Color(0xFF2563EB), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(m, style: const TextStyle(color: Color(0xFF334155), fontSize: 13)),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 18),

                    // Section: Sikhe hue tasks
                    const Text(
                      'Sikhe hue tasks',
                      style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    ..._tasks.map((t) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Color(0x103060A0), blurRadius: 10, offset: Offset(0, 3)),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t['title']!,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    t['steps']!,
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  foregroundColor: const Color(0xFF2563EB),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                                label: const Text('Chalao', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () => _runTask(t),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 14),

                    // Auto Remember Switch matching frame_011.jpg
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Color(0x103060A0), blurRadius: 10, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Baat ke baad khud yaad rakhe',
                                  style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Har baat khatam hone par kaam ki baatein khud save karti hai',
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _autoRememberEnabled,
                            activeColor: const Color(0xFF2563EB),
                            onChanged: (v) => setState(() => _autoRememberEnabled = v),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Backup & Restore Tile
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Color(0x103060A0), blurRadius: 10, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.cloud_upload_rounded, color: Color(0xFF2563EB), size: 24),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Backup & restore',
                                  style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Apni yaadein aur chats dusre phone pe le jao',
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
