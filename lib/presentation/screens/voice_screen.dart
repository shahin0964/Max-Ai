import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isListening = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.graphic_eq_rounded,
                        color: AppColors.neonCyan, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Pulsating Concentric Glowing Rings with Center Mic
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final scale = 1.0 + (_pulseController.value * 0.12);
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
                            color: AppColors.neonPurple.withOpacity(0.2),
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

            const SizedBox(height: 48),

            // Status Text
            Text(
              _isListening ? 'Listening...' : 'Tap to speak',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isListening ? 'Tap to stop' : 'Microphone paused',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),

            const Spacer(),

            // Audio Soundwave Frequency Visualizer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(24, (index) {
                      final height = 12.0 +
                          (index % 4 == 0
                              ? 36.0 * _pulseController.value
                              : index % 3 == 0
                                  ? 24.0 * (1.0 - _pulseController.value)
                                  : 18.0 * _pulseController.value);
                      final isCyan = index % 2 == 0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: 3.5,
                        height: height,
                        decoration: BoxDecoration(
                          color: isCyan
                              ? AppColors.neonCyan
                              : AppColors.neonPurple,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
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
