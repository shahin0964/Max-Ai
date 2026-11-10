import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TextEditingController _cmdController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _logs = [
    {'type': 'sys', 'text': 'Max AI OpenJarvis Core Shell v2.4 initialized.'},
    {'type': 'sys', 'text': 'Device Node: aarch64-linux-android | Ready for commands.'},
    {'type': 'sys', 'text': 'Type "help", "status", "ping", "mem", or any task instruction.'},
  ];

  void _executeCommand() {
    final cmd = _cmdController.text.trim();
    if (cmd.isEmpty) return;

    setState(() {
      _logs.add({'type': 'input', 'text': '\$ $cmd'});
      _cmdController.clear();
    });

    // Simulate smart terminal responses
    if (cmd == 'help') {
      _logs.add({'type': 'output', 'text': 'Available Shell Directives:\n- status: Check OpenJarvis agent health\n- ping: Test LAN / Cloud endpoint latency\n- mem: View episodic vector memory usage\n- clear: Clear terminal viewport'});
    } else if (cmd == 'status') {
      _logs.add({'type': 'output', 'text': 'CORE: ONLINE\nVOICE ENGINE: ElevenLabs (wDsJlOXPqcvIUKdLXjDs)\nFAILOVER: Gemini 3.8 Flash -> Ollama\nMEMORY NODES: 12 vectors loaded'});
    } else if (cmd == 'ping') {
      _logs.add({'type': 'output', 'text': 'PING generativelanguage.googleapis.com: 42ms\nPING 192.168.1.105:11434 (Local Node): 4ms'});
    } else if (cmd == 'mem') {
      _logs.add({'type': 'output', 'text': 'Allocated Heap: 48.2 MB / 512 MB\nVector Embedding DB: max_ai_memory.db (0.8 MB)'});
    } else if (cmd == 'clear') {
      setState(() => _logs.clear());
      return;
    } else {
      _logs.add({'type': 'output', 'text': '[EXECUTED] Task "$cmd" dispatched to OpenJarvis Agent Worker.'});
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _cmdController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('MAX AI CYBER TERMINAL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: AppTheme.textMuted),
            tooltip: 'Clear Terminal',
            onPressed: () => setState(() => _logs.clear()),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Terminal Output Viewport
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF050811),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.3)),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _logs.length,
                  itemBuilder: (ctx, i) {
                    final item = _logs[i];
                    Color col;
                    if (item['type'] == 'input') {
                      col = AppTheme.cyan;
                    } else if (item['type'] == 'sys') {
                      col = AppTheme.textMuted;
                    } else {
                      col = AppTheme.emerald;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        item['text']!,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: col,
                          height: 1.35,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Command Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: AppTheme.surfaceElevated,
              child: Row(
                children: [
                  const Text('\$', style: TextStyle(color: AppTheme.cyan, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _cmdController,
                      style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace', fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Enter command or bash instruction...',
                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _executeCommand(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppTheme.cyan, size: 20),
                    onPressed: _executeCommand,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
