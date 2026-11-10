import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/ai_engine_service.dart';
import '../../services/skill_registry_service.dart';
import '../../theme/app_theme.dart';

class TerminalLogEntry {
  final String type; // 'input', 'stdout', 'stderr', 'ai'
  final String text;
  final DateTime timestamp;

  TerminalLogEntry({
    required this.type,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TextEditingController _cmdController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRunning = false;

  final List<TerminalLogEntry> _logs = [
    TerminalLogEntry(type: 'stdout', text: 'Max AI OpenJarvis Linux Shell Environment Initialized.'),
    TerminalLogEntry(type: 'stdout', text: 'Connected to on-device Android sh runtime. Ready for commands.'),
    TerminalLogEntry(type: 'stdout', text: 'Tip: Run native Linux commands or prefix with "ai <query>" for AI assistance.'),
  ];

  final List<String> _quickCommands = [
    'uname -a',
    'df -h',
    'date',
    'pwd',
    'ls -la',
    'ping -c 2 8.8.8.8',
    'cat /proc/meminfo | head -n 4',
  ];

  @override
  void dispose() {
    _cmdController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _executeCommand([String? directCmd]) async {
    final cmd = (directCmd ?? _cmdController.text).trim();
    if (cmd.isEmpty || _isRunning) return;

    if (directCmd == null) {
      _cmdController.clear();
    }

    setState(() {
      _logs.add(TerminalLogEntry(type: 'input', text: '\$ $cmd'));
      _isRunning = true;
    });
    _scrollToBottom();

    // Check special client directives
    if (cmd == 'clear') {
      setState(() {
        _logs.clear();
        _isRunning = false;
      });
      return;
    }

    // AI Query Directive
    if (cmd.toLowerCase().startsWith('ai ')) {
      final query = cmd.substring(3).trim();
      try {
        final reply = await AIEngineService.instance.sendMessage(
          prompt: 'You are Max AI Shell & Linux Terminal Assistant. The user asks: "$query". Explain clearly, provide executable bash commands, and highlight system implications.',
        );
        if (mounted) {
          setState(() {
            _logs.add(TerminalLogEntry(type: 'ai', text: '[MAX AI]:\n$reply'));
            _isRunning = false;
          });
          _scrollToBottom();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _logs.add(TerminalLogEntry(type: 'stderr', text: 'AI Error: $e'));
            _isRunning = false;
          });
          _scrollToBottom();
        }
      }
      return;
    }

    // Real On-Device Android Shell Execution
    try {
      final result = await Process.run('sh', ['-c', cmd]).timeout(const Duration(seconds: 15));

      if (mounted) {
        setState(() {
          final stdoutStr = result.stdout.toString().trim();
          final stderrStr = result.stderr.toString().trim();

          if (stdoutStr.isNotEmpty) {
            _logs.add(TerminalLogEntry(type: 'stdout', text: stdoutStr));
          }
          if (stderrStr.isNotEmpty) {
            _logs.add(TerminalLogEntry(type: 'stderr', text: stderrStr));
          }
          if (stdoutStr.isEmpty && stderrStr.isEmpty) {
            _logs.add(TerminalLogEntry(type: 'stdout', text: '[Exit code ${result.exitCode}]'));
          }
          _isRunning = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _logs.add(TerminalLogEntry(type: 'stderr', text: 'Execution failed: $e'));
          _isRunning = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        title: const Text('ANDROID CYBER TERMINAL', style: TextStyle(fontFamily: 'monospace', letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: AppTheme.cyan),
            tooltip: 'Copy Terminal Output',
            onPressed: () {
              final text = _logs.map((l) => '${l.type == "input" ? "" : "  "}${l.text}').join('\n');
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terminal output copied!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: AppTheme.rose),
            tooltip: 'Clear Viewport',
            onPressed: () => setState(() => _logs.clear()),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: SkillRegistryService.instance,
          builder: (context, _) {
            final isSkillInstalled = SkillRegistryService.instance.isSkillInstalled('terminal_runner');

            return Column(
              children: [
                // Skill check banner
                if (!isSkillInstalled)
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.amber, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppTheme.amber, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Android Shell & Linux Terminal skill is uninstalled.',
                            style: TextStyle(color: AppTheme.amber, fontSize: 11),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => SkillRegistryService.instance.installSkill('terminal_runner'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
                          child: const Text('INSTALL', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                // Quick Command Bar
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickCommands.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (ctx, i) {
                      final c = _quickCommands[i];
                      return ActionChip(
                        label: Text(c, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppTheme.cyan)),
                        backgroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFF1E293B)),
                        onPressed: () => _executeCommand(c),
                      );
                    },
                  ),
                ),

                // Terminal Output Viewport
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020408),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.3)),
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _logs.length,
                      itemBuilder: (ctx, i) {
                        final log = _logs[i];
                        Color color = AppTheme.textPrimary;
                        FontWeight weight = FontWeight.normal;

                        if (log.type == 'input') {
                          color = AppTheme.cyan;
                          weight = FontWeight.bold;
                        } else if (log.type == 'stderr') {
                          color = AppTheme.rose;
                        } else if (log.type == 'ai') {
                          color = AppTheme.amber;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: SelectableText(
                            log.text,
                            style: TextStyle(
                              color: color,
                              fontSize: 11.5,
                              fontFamily: 'monospace',
                              fontWeight: weight,
                              height: 1.35,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Command Input Line
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  color: const Color(0xFF070B14),
                  child: Row(
                    children: [
                      const Text('\$ ', style: TextStyle(color: AppTheme.cyan, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 16)),
                      Expanded(
                        child: TextField(
                          controller: _cmdController,
                          style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Enter command (e.g. ls, ping, or "ai explain memory")...',
                            hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 11.5, fontFamily: 'monospace'),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (val) => _executeCommand(),
                        ),
                      ),
                      IconButton(
                        icon: _isRunning
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cyan))
                            : const Icon(Icons.arrow_forward_ios, color: AppTheme.cyan, size: 16),
                        onPressed: _isRunning ? null : () => _executeCommand(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
