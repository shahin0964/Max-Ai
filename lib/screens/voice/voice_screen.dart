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
        title: const Text('HOLOGRAPHIC VOICE COCKPIT'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
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

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Status Indicator Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Center Holographic Reactor Orb
                  Center(
                    child: HolographicReactorOrb(
                      size: 240,
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

                  const Spacer(),

                  // Live Transcription Display
                  GlassPanel(
                    padding: const EdgeInsets.all(16),
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
                        const SizedBox(height: 8),
                        Text(
                          voice.lastWords.isNotEmpty ? voice.lastWords : _liveTranscript,
                          style: TextStyle(
                            fontSize: 14,
                            color: voice.isListening
                                ? AppTheme.emerald
                                : AppTheme.textPrimary,
                            height: 1.35,
                          ),
                        ),
                        if (_aiReply.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.volume_up, size: 14, color: AppTheme.violet),
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
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Stop / Reset
                      IconButton(
                        icon: const Icon(Icons.stop_circle_outlined, size: 28),
                        color: AppTheme.textMuted,
                        onPressed: () {
                          voice.stopListening();
                          voice.stopSpeaking();
                        },
                      ),
                      const SizedBox(width: 24),

                      // Large Glowing Mic Button
                      GestureDetector(
                        onTap: () {
                          if (voice.isListening) {
                            voice.stopListening();
                          } else {
                            _startVoiceInteraction();
                          }
                        },
                        child: Container(
                          width: 64,
                          height: 64,
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
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            voice.isListening ? Icons.mic : Icons.mic_none,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Speak Test
                      IconButton(
                        icon: const Icon(Icons.replay, size: 26),
                        color: AppTheme.textMuted,
                        onPressed: () {
                          if (_aiReply.isNotEmpty) {
                            voice.speak(_aiReply);
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
