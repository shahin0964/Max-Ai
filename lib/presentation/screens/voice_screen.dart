import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isListening = true;
  String _userSpokenText = '';
  String _aiSpokenResponse = 'Max AI is listening to your voice...';
  bool _isSpeaking = false;

  final List<String> _quickVoiceCommands = [
    'What is the weather today?',
    'Turn on flashlight',
    'Set volume to 80%',
    'Run termux uname -a',
    'Open WhatsApp',
    'আমাকে বাংলায় একটি অনুপ্রেরণামূলক কথা বলো',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _processVoiceCommand(String command) async {
    setState(() {
      _userSpokenText = command;
      _isListening = false;
      _isSpeaking = true;
      _aiSpokenResponse = 'Thinking with Gemini 3.8 Flash...';
    });

    final chatProvider = context.read<ChatProvider>();
    await chatProvider.sendMessage(command);

    if (mounted) {
      final latestMsg = chatProvider.messages.last;
      setState(() {
        _isSpeaking = true;
        _aiSpokenResponse = latestMsg.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Close (X) and Waveform icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.neonCyan.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.mic, color: AppColors.neonCyan, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Voice Guardian Active',
                              style: TextStyle(color: AppColors.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.graphic_eq_rounded, color: AppColors.neonCyan, size: 26),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Pulsating Concentric Glowing Rings with Center Mic
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final scale = 1.0 + (_pulseController.value * 0.15);
                return Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glowing ring
                      Container(
                        width: 250 * scale,
                        height: 250 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neonPurple.withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonCyan.withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      // Middle ring
                      Container(
                        width: 190 * scale,
                        height: 190 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neonBlue.withOpacity(0.4),
                            width: 2,
                          ),
                          gradient: RadialGradient(
                            colors: [
                              AppColors.electricBlue.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Core inner glowing button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isListening = !_isListening;
                            if (_isListening) {
                              _aiSpokenResponse = 'Listening to your voice...';
                            }
                          });
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCyan.withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 36),

            // Spoken Transcription / AI Response Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              child: Column(
                children: [
                  if (_userSpokenText.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.record_voice_over_rounded, color: AppColors.neonCyan, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'You said: "$_userSpokenText"',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    _aiSpokenResponse,
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Soundwave Frequency Visualizer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(24, (i) {
                final heights = [14, 22, 38, 50, 32, 20, 44, 60, 40, 24, 52, 65, 48, 30, 55, 36, 18, 42, 58, 28, 16, 34, 22, 12];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (i * 20)),
                  width: 3.5,
                  height: _isListening || _isSpeaking ? heights[i % heights.length].toDouble() : 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i % 2 == 0 ? AppColors.neonCyan : AppColors.neonPurple,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),

            const Spacer(),

            // Quick Voice Command Chips
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 24),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickVoiceCommands.length,
                itemBuilder: (context, index) {
                  final cmd = _quickVoiceCommands[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: AppColors.surfaceCard,
                      side: const BorderSide(color: AppColors.surfaceLight),
                      label: Text(
                        cmd,
                        style: const TextStyle(color: AppColors.neonCyan, fontSize: 12),
                      ),
                      onPressed: () => _processVoiceCommand(cmd),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
