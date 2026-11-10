import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:uuid/uuid.dart';
import '../../models/chat_message.dart';
import '../../services/ai_engine_service.dart';
import '../../services/voice_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/holographic_reactor_orb.dart';
import '../../widgets/hud_telemetry_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Welcome initial message
    _messages.add(ChatMessage(
      id: const Uuid().v4(),
      role: MessageRole.assistant,
      content:
          '⚡ **Max AI Core Online.**\n\nHybrid on-device & cloud cognitive system powered by OpenJarvis architecture. Ready to assist with reasoning, tool operations, or real-time voice intelligence.',
      timestamp: DateTime.now(),
      modelName: 'System',
    ));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _handleSend([String? presetText]) async {
    final text = (presetText ?? _inputController.text).trim();
    if (text.isEmpty || _isGenerating) return;

    _inputController.clear();
    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isGenerating = true;
    });
    _scrollToBottom();

    // AI Generation
    final response = await AIEngineService.instance.generateResponse(
      history: _messages,
    );

    if (mounted) {
      final assistantMsg = ChatMessage(
        id: const Uuid().v4(),
        role: MessageRole.assistant,
        content: response.text,
        timestamp: DateTime.now(),
        modelName: response.model,
        providerName: response.provider,
        latencyMs: response.latencyMs,
      );

      setState(() {
        _messages.add(assistantMsg);
        _isGenerating = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final voice = VoiceService.instance;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top HUD Bar with Sidebar Menu & Reactor Orb preview
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 12, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: AppTheme.cyan, size: 24),
                    tooltip: 'Open Slidebar',
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: HudTelemetryBar(),
                  ),
                  const SizedBox(width: 8),
                  ListenableBuilder(
                    listenable: voice,
                    builder: (context, _) {
                      return HolographicReactorOrb(
                        size: 38,
                        state: voice.state,
                        onTap: () {
                          // Quick voice toggle
                          if (voice.isListening) {
                            voice.stopListening();
                          } else {
                            voice.startListening(onResult: (res) {
                              _handleSend(res);
                            });
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            // Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageItem(_messages[index]);
                },
              ),
            ),

            // Generating indicator
            if (_isGenerating)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.cyan),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Max AI is reasoning...',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.cyan.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

            // Quick Prompt Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  _buildPromptChip('⚡ Telemetry Status', 'Give me full system and memory diagnostics.'),
                  _buildPromptChip('🌐 Research Tech', 'Search web for the latest OpenJarvis AI framework architecture.'),
                  _buildPromptChip('🧮 Compute Math', 'Solve: 4096 * 32 / 1024 and explain the memory math.'),
                  _buildPromptChip('💾 Recall Memory', 'What facts do you remember about me?'),
                ],
              ),
            ),

            // Bottom Input Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                borderRadius: 24,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        maxLines: 4,
                        minLines: 1,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Transmit command or query to Max AI...',
                          hintStyle: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                    ListenableBuilder(
                      listenable: voice,
                      builder: (context, _) {
                        return IconButton(
                          icon: Icon(
                            voice.isListening ? Icons.mic : Icons.mic_none,
                            color: voice.isListening ? AppTheme.emerald : AppTheme.cyan,
                          ),
                          onPressed: () {
                            if (voice.isListening) {
                              voice.stopListening();
                            } else {
                              voice.startListening(onResult: (res) {
                                _handleSend(res);
                              });
                            }
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, color: AppTheme.cyan),
                      onPressed: () => _handleSend(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String label, String prompt) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label),
        labelStyle: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        backgroundColor: AppTheme.surfaceElevated,
        side: const BorderSide(color: AppTheme.surfaceGlassBorder, width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _handleSend(prompt),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    final isUser = msg.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.cyan.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.psychology, size: 16, color: AppTheme.cyan),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GlassPanel(
              padding: const EdgeInsets.all(12),
              borderRadius: 16,
              borderColor: isUser
                  ? AppTheme.cyan.withValues(alpha: 0.3)
                  : AppTheme.surfaceGlassBorder,
              backgroundColor: isUser
                  ? AppTheme.cyan.withValues(alpha: 0.12)
                  : AppTheme.surfaceElevated.withValues(alpha: 0.75),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: msg.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                      code: const TextStyle(
                        backgroundColor: Color(0x33000000),
                        fontFamily: 'monospace',
                        color: AppTheme.cyan,
                        fontSize: 12,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.surfaceGlassBorder),
                      ),
                    ),
                  ),
                  if (!isUser && msg.latencyMs != null && msg.latencyMs! > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${msg.modelName ?? "Engine"} • ${msg.latencyMs}ms',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => VoiceService.instance.speak(msg.content),
                          child: const Icon(
                            Icons.volume_up_outlined,
                            size: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 6),
        ],
      ),
    );
  }
}
