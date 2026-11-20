import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/gradient_logo.dart';
import '../widgets/message_bubble.dart';
import 'vision_screen.dart';
import 'terminal_reel_screen.dart';
import 'memory_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestions = [
    'What can you do?',
    'Termux uname -a',
    'Set a reminder',
    'Turn on flashlight',
    'Explain quantum computing in Bengali',
  ];

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatProvider>().sendMessage(text);
      _inputController.clear();
      _scrollToBottom();
    }
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

  void _showTokenUsageSheet() {
    final stats = context.read<ChatProvider>().lastTokenStats;
    final modelName = stats?.model ?? 'Gemini 3.8 Flash (High)';
    final inputTokens = stats?.inputTokens ?? 2275;
    final outputTokens = stats?.outputTokens ?? 1288;
    final cachedTokens = stats?.cachedTokens ?? 89251;
    final totalTokens = stats?.totalTokens ?? 3563;
    final duration = stats?.durationSeconds ?? 18.4;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.mayaSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text(
              'Reply details',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            const Text(
              'What this reply used',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mayaSurfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mayaBorder),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.mayaPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.memory_rounded, color: AppColors.mayaPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Model', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          Text(modelName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.mayaBorder, height: 24),
                  _statRow(Icons.arrow_downward_rounded, 'Input tokens', '$inputTokens', AppColors.mayaAccentCyan),
                  const SizedBox(height: 10),
                  _statRow(Icons.arrow_upward_rounded, 'Output tokens', '$outputTokens', const Color(0xFF4ADE80)),
                  const SizedBox(height: 10),
                  _statRow(Icons.bolt_rounded, 'Cache read', '$cachedTokens (97% of the input)', Colors.amberAccent),
                  const Divider(color: AppColors.mayaBorder, height: 24),
                  _statRow(Icons.functions_rounded, 'Total', '$totalTokens', Colors.white, isBold: true),
                  const SizedBox(height: 10),
                  _statRow(Icons.timer_outlined, 'Time', '${duration.toStringAsFixed(1)} s', AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String val, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        Text(
          val,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.mayaSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add to Conversation',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attachOption(Icons.camera_alt_rounded, 'Vision AI', AppColors.mayaAccentCyan, () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const VisionScreen()));
                }),
                _attachOption(Icons.terminal_rounded, 'Termux Reel', const Color(0xFF4ADE80), () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalReelScreen()));
                }),
                _attachOption(Icons.psychology_rounded, 'Memory Vault', AppColors.mayaPrimary, () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryScreen()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: AppColors.mayaBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mayaSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                const GradientLogo(size: 34),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: chatProvider.isOnline ? AppColors.online : AppColors.textMuted,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.mayaSurface, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Max AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  chatProvider.isOnline ? 'Active now • Gemini 3.8 Flash' : 'Offline Engine',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            color: AppColors.mayaSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) {
              if (val == 'tokens') {
                _showTokenUsageSheet();
              } else if (val == 'clear') {
                chatProvider.clearChat();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat cleared!')));
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'tokens',
                child: Row(
                  children: [
                    Icon(Icons.query_stats_rounded, color: AppColors.mayaAccentCyan, size: 18),
                    SizedBox(width: 10),
                    Text('Reply details & Tokens', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                    SizedBox(width: 10),
                    Text('Clear Chat History', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // If loading, show Messenger-style typing indicator pill as the last item!
                if (index == chatProvider.messages.length) {
                  return const TypingBubble();
                }
                return MessageBubble(message: chatProvider.messages[index]);
              },
            ),
          ),

          // Horizontal Suggestion Pills
          Container(
            height: 36,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return GestureDetector(
                  onTap: () {
                    _inputController.text = suggestion;
                    _sendMessage();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.mayaSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.mayaBorder),
                    ),
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        color: AppColors.mayaAccentCyan,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Messenger-style Compact Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.mayaSurface,
              border: const Border(top: BorderSide(color: AppColors.mayaBorder, width: 0.8)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.mayaAccentCyan, size: 24),
                    onPressed: _showAttachmentSheet,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.mayaBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.mayaBorder),
                      ),
                      child: TextField(
                        controller: _inputController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Message Max AI...',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        ),
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Messenger-style animated 3-dot typing pill
class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.logoGradient,
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.mayaSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.mayaBorder),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.22;
                    final progress = (_controller.value - delay) % 1.0;
                    final bounce = (progress < 0.5) ? progress * 2 : (1.0 - progress) * 2;
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      width: 7,
                      height: 7,
                      transform: Matrix4.translationValues(0, -bounce * 4, 0),
                      decoration: BoxDecoration(
                        color: AppColors.mayaAccentCyan.withOpacity(0.35 + (bounce * 0.65)),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
