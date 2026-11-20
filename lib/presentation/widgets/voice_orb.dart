import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum VoiceOrbState {
  idle,
  listening,
  thinking,
  speaking,
}

class VoiceOrb extends StatefulWidget {
  final VoiceOrbState state;
  final double size;
  final VoidCallback? onTap;

  const VoiceOrb({
    super.key,
    this.state = VoiceOrbState.idle,
    this.size = 200,
    this.onTap,
  });

  @override
  State<VoiceOrb> createState() => _VoiceOrbState();
}

class _VoiceOrbState extends State<VoiceOrb> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _rotationController, _waveController]),
        builder: (context, _) {
          double pulseScale;
          double ringOpacity;
          List<Color> gradientColors;

          switch (widget.state) {
            case VoiceOrbState.listening:
              pulseScale = 1.0 + (_pulseController.value * 0.22);
              ringOpacity = 0.55;
              gradientColors = [
                AppColors.mayaAccentCyan,
                const Color(0xFF2979FF),
                AppColors.mayaPrimary,
              ];
              break;
            case VoiceOrbState.thinking:
              pulseScale = 1.0 + (_pulseController.value * 0.12);
              ringOpacity = 0.45;
              gradientColors = [
                AppColors.mayaPrimary,
                AppColors.mayaAccentPink,
                AppColors.mayaAccentCyan,
              ];
              break;
            case VoiceOrbState.speaking:
              pulseScale = 1.0 + (_waveController.value * 0.18);
              ringOpacity = 0.50;
              gradientColors = [
                AppColors.mayaAccentTeal,
                AppColors.mayaAccentCyan,
                AppColors.mayaPrimary,
              ];
              break;
            case VoiceOrbState.idle:
            default:
              pulseScale = 1.0 + (_pulseController.value * 0.08);
              ringOpacity = 0.25;
              gradientColors = [
                AppColors.mayaAccentCyan.withOpacity(0.9),
                AppColors.mayaPrimary,
                AppColors.mayaPrimaryDark,
              ];
              break;
          }

          final coreSize = widget.size * 0.55;

          return SizedBox(
            width: widget.size * 1.35,
            height: widget.size * 1.35,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Layer 1: Outermost Expanding Ripple Wave
                Container(
                  width: widget.size * pulseScale,
                  height: widget.size * pulseScale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: gradientColors.first.withOpacity(ringOpacity * 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withOpacity(0.18),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),

                // Layer 2: Middle Concentric Atmospheric Aura
                Container(
                  width: widget.size * 0.82 * pulseScale,
                  height: widget.size * 0.82 * pulseScale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        gradientColors[1].withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: gradientColors[1].withOpacity(ringOpacity * 0.7),
                      width: 2.0,
                    ),
                  ),
                ),

                // Layer 3: Rotating Energy Ring (Thinking & Listening)
                Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: Container(
                    width: coreSize * 1.32,
                    height: coreSize * 1.32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Colors.transparent,
                          gradientColors.first.withOpacity(0.8),
                          gradientColors.last.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Layer 4: Deep Inner Glow Core (Solid Floating Orb)
                Container(
                  width: coreSize,
                  height: coreSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withOpacity(0.7),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: gradientColors.last.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.state == VoiceOrbState.speaking
                          ? Icons.graphic_eq_rounded
                          : widget.state == VoiceOrbState.thinking
                              ? Icons.auto_awesome
                              : Icons.mic_rounded,
                      color: Colors.white,
                      size: coreSize * 0.44,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
