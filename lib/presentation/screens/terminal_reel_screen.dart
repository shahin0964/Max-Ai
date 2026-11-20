import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/tool_registry_service.dart';

class TerminalReelScreen extends StatefulWidget {
  const TerminalReelScreen({super.key});

  @override
  State<TerminalReelScreen> createState() => _TerminalReelScreenState();
}

class _TerminalReelScreenState extends State<TerminalReelScreen> {
  final ToolRegistryService _toolRegistry = ToolRegistryService();
  final TextEditingController _cmdController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _consoleLogs = [
    '⚡ Max AI Termux Bridge Initialized v5.2',
    'Connected via com.termux.RUN_COMMAND intent',
    'Rootless environment ready: aarch64-linux-android',
    'Type any bash command below to execute...',
  ];

  final List<String> _quickCommands = [
    'uname -a',
    'whoami',
    'uptime',
    'df -h',
    'git status',
    'python3 --version',
    'ls -la',
  ];

  @override
  void dispose() {
    _cmdController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _executeCommand(String cmd) async {
    final command = cmd.trim();
    if (command.isEmpty) return;

    setState(() {
      _consoleLogs.add('\$ $command');
    });
    _cmdController.clear();
    _scrollToBottom();

    final result = await _toolRegistry.executeTool('termux_run', {'command': command});

    setState(() {
      _consoleLogs.add(result);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: const [
            Icon(Icons.terminal_rounded, color: Color(0xFF22C55E), size: 22),
            SizedBox(width: 8),
            Text(
              'Termux Live Terminal Reel',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white70),
            onPressed: () {
              setState(() {
                _consoleLogs.clear();
                _consoleLogs.add('Console cleared.');
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Command Chips
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickCommands.length,
              itemBuilder: (context, index) {
                final cmd = _quickCommands[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: const Color(0xFF1E293B),
                    label: Text(
                      cmd,
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                    onPressed: () => _executeCommand(cmd),
                  ),
                );
              },
            ),
          ),

          // Main Terminal Console View
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF050B14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _consoleLogs.length,
                itemBuilder: (context, index) {
                  final log = _consoleLogs[index];
                  final isUserCmd = log.startsWith('\$');
                  final isError = log.contains('Error') || log.contains('error');

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      log,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        height: 1.4,
                        color: isUserCmd
                            ? const Color(0xFF38BDF8)
                            : isError
                                ? const Color(0xFFF87171)
                                : const Color(0xFF4ADE80),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Input command bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF0F172A),
            child: Row(
              children: [
                const Text(
                  '\$ ',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _cmdController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter bash command...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _executeCommand,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.neonCyan),
                  onPressed: () => _executeCommand(_cmdController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
