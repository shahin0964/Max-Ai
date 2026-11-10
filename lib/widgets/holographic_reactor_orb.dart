import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';

class HolographicReactorOrb extends StatefulWidget {
  final double size;
  final VoiceState state;
  final VoidCallback? onTap;

  const HolographicReactorOrb({
    super.key,
    this.size = 180,
    this.state = VoiceState.idle,
    this.onTap,
  });

  @override
  State<HolographicReactorOrb> createState() => _HolographicReactorOrbState();
}

class _HolographicReactorOrbState extends State<HolographicReactorOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _ReactorPainter(
              progress: _controller.value,
              state: widget.state,
            ),
          );
        },
      ),
    );
  }
}

class _ReactorPainter extends CustomPainter {
  final double progress;
  final VoiceState state;

  _ReactorPainter({required this.progress, required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    Color primaryGlow = AppTheme.cyan;
    Color secondaryGlow = AppTheme.violet;
    double pulseScale = 1.0;
    double speedMultiplier = 1.0;

    switch (state) {
      case VoiceState.idle:
        pulseScale = 1.0 + 0.05 * math.sin(progress * 2 * math.pi);
        speedMultiplier = 1.0;
        primaryGlow = AppTheme.cyan;
        secondaryGlow = AppTheme.violet;
        break;
      case VoiceState.listening:
        pulseScale = 1.0 + 0.14 * math.sin(progress * 8 * math.pi);
        speedMultiplier = 2.0;
        primaryGlow = AppTheme.emerald;
        secondaryGlow = AppTheme.cyan;
        break;
      case VoiceState.thinking:
        pulseScale = 1.0 + 0.20 * math.sin(progress * 12 * math.pi);
        speedMultiplier = 3.5;
        primaryGlow = AppTheme.amber;
        secondaryGlow = AppTheme.rose;
        break;
      case VoiceState.speaking:
        pulseScale = 1.0 + 0.16 * math.cos(progress * 10 * math.pi);
        speedMultiplier = 2.2;
        primaryGlow = AppTheme.violet;
        secondaryGlow = AppTheme.cyan;
        break;
    }

    final effectiveProgress = (progress * speedMultiplier) % 1.0;

    // 1. Ambient Background Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryGlow.withValues(alpha: 0.35),
          secondaryGlow.withValues(alpha: 0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * pulseScale));
    canvas.drawCircle(center, radius * pulseScale, glowPaint);

    // 2. Quantum Outer Ring with Dash effect
    final outerRingPaint = Paint()
      ..color = primaryGlow.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final outerRadius = radius * 0.88 * pulseScale;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(effectiveProgress * 2 * math.pi);
    for (int i = 0; i < 8; i++) {
      final startAngle = i * (math.pi / 4);
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: outerRadius),
        startAngle,
        math.pi / 8,
        false,
        outerRingPaint,
      );
    }
    canvas.restore();

    // 3. Elliptical 3D Orbital Ring 1 (Tilted X/Y)
    final orbitPaint1 = Paint()
      ..shader = LinearGradient(
        colors: [primaryGlow, secondaryGlow, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.7))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 6 + (effectiveProgress * 2 * math.pi));
    canvas.scale(1.0, 0.45);
    canvas.drawOval(
      Rect.fromCircle(center: Offset.zero, radius: radius * 0.72),
      orbitPaint1,
    );
    // Orbital particle
    final p1X = radius * 0.72 * math.cos(effectiveProgress * 4 * math.pi);
    final p1Y = radius * 0.72 * math.sin(effectiveProgress * 4 * math.pi);
    final p1Paint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
    canvas.drawCircle(Offset(p1X, p1Y), 3.5, p1Paint);
    canvas.restore();

    // 4. Elliptical 3D Orbital Ring 2 (Opposing Tilt)
    final orbitPaint2 = Paint()
      ..shader = LinearGradient(
        colors: [secondaryGlow, primaryGlow, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.7))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 4 - (effectiveProgress * 2 * math.pi));
    canvas.scale(1.0, 0.40);
    canvas.drawOval(
      Rect.fromCircle(center: Offset.zero, radius: radius * 0.65),
      orbitPaint2,
    );
    // Orbital particle
    final p2X = radius * 0.65 * math.cos(-effectiveProgress * 3 * math.pi);
    final p2Y = radius * 0.65 * math.sin(-effectiveProgress * 3 * math.pi);
    canvas.drawCircle(Offset(p2X, p2Y), 3.0, p1Paint);
    canvas.restore();

    // 5. Central Reactor Core (High Intensity Plasma)
    final coreRadius = radius * 0.35 * pulseScale;
    final coreGradient = RadialGradient(
      colors: [
        Colors.white,
        primaryGlow,
        secondaryGlow.withValues(alpha: 0.8),
        Colors.transparent,
      ],
      stops: const [0.0, 0.35, 0.75, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: coreRadius * 1.5));

    final corePaint = Paint()
      ..shader = coreGradient
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, coreRadius, corePaint);

    // Inner Core Accent Ring
    final innerAccentPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, coreRadius * 0.6, innerAccentPaint);
  }

  @override
  bool shouldRepaint(covariant _ReactorPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.state != state;
  }
}
