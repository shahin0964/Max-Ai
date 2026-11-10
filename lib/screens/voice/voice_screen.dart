import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/chat_message.dart';
import '../../services/ai_engine_service.dart';
import '../../services/voice_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/holographic_reactor_orb.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  String _liveTranscript = 'Tap the Reactor Core or Mic to speak with Max AI...';
  String _aiReply = '';

  Future<void> _startVoiceInteraction() async {
    final voice = VoiceService.instance;

    setState(() {
      _liveTranscript = 'Listening... Speak now...';
      _aiReply = '';
    });

    await voice.startListening(
      onResult: (spokenText) async {
        if (spokenText.trim().isEmpty) return;

        setState(() {
          _liveTranscript = spokenText;
        });

        // Set state to thinking
        voice.setState(VoiceState.thinking);

        final history = [
          ChatMessage(
            id: const Uuid().v4(),
            role: MessageRole.user,
            content: spokenText,
            timestamp: DateTime.now(),
          )
        ];

        final response = await AIEngineService.instance.generateResponse(
          history: history,
        );

        if (mounted) {
          setState(() {
            _aiReply = response.text;
          });
          await voice.speak(response.text);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final voice = VoiceService.instance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.emerald),
          tooltip: 'Open Slidebar',
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('HOLOGRAPHIC VOICE COCKPIT'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListenableBuilder(
              listenable: voice,
              builder: (context, _) {
                String statusTitle = 'CORE STANDBY';
                Color statusColor = AppTheme.cyan;

                switch (voice.state) {
                  case VoiceState.idle:
                    statusTitle = 'CORE STANDBY';
                    statusColor = AppTheme.cyan;
                    break;
                  case VoiceState.listening:
                    statusTitle = 'ACOUSTIC SENSORS ACTIVE';
                    statusColor = AppTheme.emerald;
                    break;
                  case VoiceState.thinking:
                    statusTitle = 'COGNITIVE COMPUTING...';
                    statusColor = AppTheme.amber;
                    break;
                  case VoiceState.speaking:
                    statusTitle = 'SYNTHESIZING AUDIO STREAM...';
                    statusColor = AppTheme.violet;
                    break;
                }

                // Dynamic sizing to prevent vertical overflow
                final orbSize = (constraints.maxHeight * 0.32).clamp(140.0, 210.0);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 8),

                        // Status Indicator Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor,
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                statusTitle,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Center Holographic Reactor Orb
                        Center(
                          child: HolographicReactorOrb(
                            size: orbSize,
                            state: voice.state,
                            onTap: () {
                              if (voice.isListening) {
                                voice.stopListening();
                              } else if (voice.isSpeaking) {
                                voice.stopSpeaking();
                              } else {
                                _startVoiceInteraction();
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Live Transcription Display
                        GlassPanel(
                          padding: const EdgeInsets.all(14),
                          borderColor: statusColor.withValues(alpha: 0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.mic, size: 14, color: statusColor),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'LIVE TRANSCRIPT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                voice.lastWords.isNotEmpty
                                    ? voice.lastWords
                                    : _liveTranscript,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: voice.isListening
                                      ? AppTheme.emerald
                                      : AppTheme.textPrimary,
                                  height: 1.35,
                                ),
                              ),
                              if (_aiReply.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.volume_up,
                                        size: 14, color: AppTheme.violet),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'MAX AI SYNTHESIS',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                        color: AppTheme.violet,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _aiReply,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppTheme.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Bottom Controls
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.stop_circle_outlined, size: 28),
                                color: AppTheme.textMuted,
                                onPressed: () {
                                  voice.stopListening();
                                  voice.stopSpeaking();
                                },
                              ),
                              const SizedBox(width: 24),

                              GestureDetector(
                                onTap: () {
                                  if (voice.isListening) {
                                    voice.stopListening();
                                  } else {
                                    _startVoiceInteraction();
                                  }
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: voice.isListening
                                          ? [AppTheme.emerald, AppTheme.cyan]
                                          : [AppTheme.cyan, AppTheme.violet],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (voice.isListening
                                                ? AppTheme.emerald
                                                : AppTheme.cyan)
                                            .withValues(alpha: 0.4),
                                        blurRadius: 18,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    voice.isListening ? Icons.mic : Icons.mic_none,
                                    size: 28,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),

                              IconButton(
                                icon: const Icon(Icons.replay, size: 24),
                                color: AppTheme.textMuted,
                                onPressed: () {
                                  if (_aiReply.isNotEmpty) {
                                    voice.speak(_aiReply);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
