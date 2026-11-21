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
    this.size = 210,
    this.onTap,
  });

  @override
  State<VoiceOrb> createState() => _VoiceOrbState();
}

class _VoiceOrbState extends State<VoiceOrb> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // Continuous smooth planetary rotation (Pluto rotation)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    // Breathing & pulse controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Audio & wave reactivity controller
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationController, _pulseController, _waveController]),
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.size * 1.35, widget.size * 1.35),
            painter: _Pluto3DOrbPainter(
              rotation: _rotationController.value * 2 * math.pi,
              pulse: _pulseController.value,
              wave: _waveController.value,
              state: widget.state,
              coreSize: widget.size * 0.72,
            ),
          );
        },
      ),
    );
  }
}

class _Pluto3DOrbPainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final double wave;
  final VoiceOrbState state;
  final double coreSize;

  _Pluto3DOrbPainter({
    required this.rotation,
    required this.pulse,
    required this.wave,
    required this.state,
    required this.coreSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = coreSize / 2;

    // Atmospheric colors depending on assistant state
    Color atmosphereColor;
    Color highlightColor;
    Color flareColor;

    switch (state) {
      case VoiceOrbState.listening:
        atmosphereColor = const Color(0xFF00F2FE); // Electric Cyan
        highlightColor = const Color(0xFF38BDF8);
        flareColor = const Color(0xFF00E5FF);
        break;
      case VoiceOrbState.thinking:
        atmosphereColor = const Color(0xFF7C4DFF); // Cosmic Purple
        highlightColor = const Color(0xFFA855F7);
        flareColor = const Color(0xFFC084FC);
        break;
      case VoiceOrbState.speaking:
        atmosphereColor = const Color(0xFF38BDF8); // Active Audio Blue
        highlightColor = const Color(0xFF00F2FE);
        flareColor = const Color(0xFF67E8F9);
        break;
      case VoiceOrbState.idle:
      default:
        // Pluto's signature cold nitrogen-blue atmospheric haze (NASA New Horizons)
        atmosphereColor = const Color(0xFF38BDF8).withOpacity(0.85);
        highlightColor = const Color(0xFF7DD3FC);
        flareColor = const Color(0xFF0284C7);
        break;
    }

    // -------------------------------------------------------------
    // 1. LAYER: Expanding Gravitational / Soundwave Ripples (Back)
    // -------------------------------------------------------------
    final pulseScale = 1.0 + (pulse * 0.12);
    final waveScale = 1.0 + (wave * 0.22);

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = atmosphereColor.withOpacity(state == VoiceOrbState.idle ? 0.15 : 0.35);

    canvas.drawCircle(center, radius * 1.35 * pulseScale, wavePaint);

    if (state == VoiceOrbState.listening || state == VoiceOrbState.speaking) {
      final activeWavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = atmosphereColor.withOpacity(0.28);
      canvas.drawCircle(center, radius * 1.55 * waveScale, activeWavePaint);
    }

    // -------------------------------------------------------------
    // 2. LAYER: Pluto's Blue Rayleigh Atmospheric Haze
    // -------------------------------------------------------------
    final hazeRadius = radius * 1.28;
    final hazePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          atmosphereColor.withOpacity(0.38),
          atmosphereColor.withOpacity(0.12),
          Colors.transparent,
        ],
        stops: const [0.72, 0.90, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: hazeRadius));
    canvas.drawCircle(center, hazeRadius, hazePaint);

    // -------------------------------------------------------------
    // 3. LAYER: 3D Orbital Particle Dust Ring (Back Half: z < 0)
    // -------------------------------------------------------------
    _drawOrbitalRing(canvas, center, radius, isFront: false, atmosphereColor: atmosphereColor);

    // -------------------------------------------------------------
    // 4. LAYER: 3D Spherical Pluto Body (Clipped to sphere)
    // -------------------------------------------------------------
    canvas.save();
    final planetPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(planetPath);

    // 4A. Pluto Deep Surface Base Tone (Tholin Ochre & Mahogany)
    final basePlanetPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.35),
        radius: 1.1,
        colors: [
          Color(0xFF8B4513), // Tholin saddle brown
          Color(0xFF6B2B11), // Deep mahogany
          Color(0xFF451A03), // Dark burnt tholin
          Color(0xFF1E130D), // Nightside shadow
        ],
        stops: [0.0, 0.45, 0.80, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePlanetPaint);

    // 4B. 3D Rotating Pluto Surface Features (Tombaugh Regio Heart & Tholins)
    _drawPluto3DFeatures(canvas, center, radius, rotation);

    // 4C. Volumetric 3D Shadow & Limb Darkening
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 1.15,
        colors: [
          Colors.transparent,
          Colors.transparent,
          const Color(0xFF0F0B08).withOpacity(0.55),
          const Color(0xFF080605).withOpacity(0.92),
        ],
        stops: const [0.0, 0.50, 0.82, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shadowPaint);

    // 4D. Nitrogen Ice Specular Glint (Top-Left Highlight)
    final glintPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.40, -0.42),
        radius: 0.45,
        colors: [
          Colors.white.withOpacity(0.40),
          highlightColor.withOpacity(0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, glintPaint);

    // 4E. Atmospheric Rayleigh Rim Glow inside sphere edge
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..shader = SweepGradient(
        colors: [
          atmosphereColor.withOpacity(0.85),
          highlightColor.withOpacity(0.60),
          atmosphereColor.withOpacity(0.20),
          atmosphereColor.withOpacity(0.85),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 1.5, rimPaint);

    canvas.restore(); // End planet clip

    // -------------------------------------------------------------
    // 5. LAYER: 3D Orbital Particle Dust Ring (Front Half: z > 0)
    // -------------------------------------------------------------
    _drawOrbitalRing(canvas, center, radius, isFront: true, atmosphereColor: atmosphereColor);

    // -------------------------------------------------------------
    // 6. LAYER: Glowing Holographic "MAX" Centerpiece
    // -------------------------------------------------------------
    _drawMaxEmblem(canvas, center, radius, atmosphereColor);
  }

  /// Draw 3D rotating planetary terrain: Tombaugh Regio (The Heart), Cthulhu Macula, and Ice Plains
  void _drawPluto3DFeatures(Canvas canvas, Offset center, double radius, double rotAngle) {
    // We map features as spherical coordinates that rotate with rotAngle
    // Pluto's famous heart (Tombaugh Regio / Sputnik Planitia)
    final heartAngle = rotAngle % (2 * math.pi);

    // Check if the Heart is on the visible side (-PI/2 to PI/2 relative to viewer)
    final heartX = math.sin(heartAngle);
    final heartZ = math.cos(heartAngle);

    if (heartZ > -0.2) {
      // Visible hemisphere
      final heartCenterNormX = heartX * 0.72;
      final heartCenterNormY = 0.08; // slightly south of equator

      final hx = center.dx + heartCenterNormX * radius;
      final hy = center.dy + heartCenterNormY * radius;
      final heartSize = radius * 0.58 * (heartZ + 0.35).clamp(0.2, 1.0);

      // The Heart (Tombaugh Regio) - Ivory/Cream/Nitrogen Ice
      final heartPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF7ED), // Sputnik Planitia creamy nitrogen ice
            const Color(0xFFF1E9DF), // Nitrogen/CO glacier
            const Color(0xFFE0F2FE).withOpacity(0.9), // Pale frost
            const Color(0xFFBAE6FD).withOpacity(0.3), // Blue nitrogen rim
            Colors.transparent,
          ],
          stops: const [0.0, 0.40, 0.70, 0.88, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(hx, hy), radius: heartSize));

      // Draw characteristic lobed shape of the Pluto Heart
      final heartPath = Path();
      heartPath.moveTo(hx, hy + heartSize * 0.45);
      // Left lobe
      heartPath.cubicTo(
        hx - heartSize * 0.75, hy - heartSize * 0.20,
        hx - heartSize * 0.65, hy - heartSize * 0.85,
        hx, hy - heartSize * 0.35,
      );
      // Right lobe
      heartPath.cubicTo(
        hx + heartSize * 0.65, hy - heartSize * 0.85,
        hx + heartSize * 0.75, hy - heartSize * 0.20,
        hx, hy + heartSize * 0.45,
      );
      heartPath.close();

      canvas.drawPath(heartPath, heartPaint);
    }

    // Secondary feature: Equatorial dark macula (Cthulhu Macula)
    final cthulhuAngle = (rotAngle + math.pi) % (2 * math.pi);
    final cthulhuX = math.sin(cthulhuAngle);
    final cthulhuZ = math.cos(cthulhuAngle);

    if (cthulhuZ > -0.1) {
      final cx = center.dx + cthulhuX * 0.65 * radius;
      final cy = center.dy + 0.28 * radius;
      final cthulhuPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF1E110A).withOpacity(0.85),
            const Color(0xFF3B1A0E).withOpacity(0.60),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius * 0.48));

      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: radius * 0.85, height: radius * 0.38),
        cthulhuPaint,
      );
    }

    // Polar Nitrogen Ice Cap (North Pole)
    final polePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 0.45,
        colors: [
          const Color(0xFFF8FAFC).withOpacity(0.70),
          const Color(0xFFBAE6FD).withOpacity(0.45),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(Offset(center.dx, center.dy - radius * 0.75), radius * 0.45, polePaint);
  }

  /// Draw 3D tilted orbital ring & dust particles (depth sorted)
  void _drawOrbitalRing(Canvas canvas, Offset center, double radius, {required bool isFront, required Color atmosphereColor}) {
    final ringRadiusX = radius * 1.48;
    final ringRadiusY = radius * 0.46;
    const tiltAngle = -22.0 * (math.pi / 180.0); // 22 degree tilt

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tiltAngle);

    final ringRect = Rect.fromCenter(center: Offset.zero, width: ringRadiusX * 2, height: ringRadiusY * 2);

    // Draw the ring line
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isFront ? 1.8 : 1.0
      ..color = atmosphereColor.withOpacity(isFront ? 0.45 : 0.18);

    if (isFront) {
      // Front half of ellipse: y > 0
      canvas.drawArc(ringRect, 0, math.pi, false, ringPaint);
    } else {
      // Back half of ellipse: y < 0
      canvas.drawArc(ringRect, math.pi, math.pi, false, ringPaint);
    }

    // Orbiting Stardust Particles (Charon Moons / Cosmic Dust)
    const int numParticles = 8;
    for (int i = 0; i < numParticles; i++) {
      final particleTheta = rotation * 1.8 + (i * (2 * math.pi / numParticles));
      final px = ringRadiusX * math.cos(particleTheta);
      final py = ringRadiusY * math.sin(particleTheta);

      final inFront = py > 0;
      if (inFront == isFront) {
        final particleAlpha = isFront ? 0.90 : 0.35;
        final particleSize = isFront ? 2.8 : 1.8;

        final particleGlow = Paint()
          ..color = atmosphereColor.withOpacity(particleAlpha * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(px, py), particleSize * 2, particleGlow);

        final particleCore = Paint()
          ..color = Colors.white.withOpacity(particleAlpha);
        canvas.drawCircle(Offset(px, py), particleSize, particleCore);
      }
    }

    canvas.restore();
  }

  /// Draw the bold, glowing 3D "MAX" typography centered on the orb
  void _drawMaxEmblem(Canvas canvas, Offset center, double radius, Color accentColor) {
    // 1. Dark Glass Backplate for pristine readability over rotating terrain
    final backplateRadius = radius * 0.50;
    final backplatePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF070A12).withOpacity(0.85),
          const Color(0xFF0B101D).withOpacity(0.60),
          Colors.transparent,
        ],
        stops: const [0.0, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: backplateRadius));
    canvas.drawCircle(center, backplateRadius, backplatePaint);

    // 2. Cyan / Neon Energy Ring around MAX core
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..shader = SweepGradient(
        colors: [
          accentColor.withOpacity(0.1),
          accentColor.withOpacity(0.85),
          Colors.white.withOpacity(0.95),
          accentColor.withOpacity(0.1),
        ],
        transform: GradientRotation(rotation * 2),
      ).createShader(Rect.fromCircle(center: center, radius: backplateRadius * 0.72));
    canvas.drawCircle(center, backplateRadius * 0.72, ringPaint);

    // 3. Audio/Voice Reactive Brackets flanking MAX
    final bracketOffset = backplateRadius * 0.82;
    final bracketPaint = Paint()
      ..color = accentColor.withOpacity(state == VoiceOrbState.idle ? 0.45 : 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Left bracket
    canvas.drawLine(
      Offset(center.dx - bracketOffset, center.dy - 10),
      Offset(center.dx - bracketOffset, center.dy + 10),
      bracketPaint,
    );
    // Right bracket
    canvas.drawLine(
      Offset(center.dx + bracketOffset, center.dy - 10),
      Offset(center.dx + bracketOffset, center.dy + 10),
      bracketPaint,
    );

    // 4. Render "MAX" Text with Multi-Pass 3D Neon Styling
    const text = 'MAX';
    final fontSize = radius * 0.38;

    // Pass A: Deep drop shadow
    final textPainterShadow = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 3.5,
          color: Colors.black.withOpacity(0.95),
          shadows: [
            Shadow(
              color: accentColor.withOpacity(0.9),
              blurRadius: 18,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainterShadow.paint(
      canvas,
      Offset(center.dx - (textPainterShadow.width / 2) + 1.0, center.dy - (textPainterShadow.height / 2) + 2.0),
    );

    // Pass B: Metallic White / Electric Cyan Gradient Text Core
    final textPainterCore = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 3.5,
          foreground: Paint()
            ..shader = LinearGradient(
              colors: [
                Colors.white,
                const Color(0xFFE0F2FE),
                accentColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(Rect.fromLTWH(0, 0, textPainterShadow.width, textPainterShadow.height)),
          shadows: [
            Shadow(
              color: accentColor.withOpacity(0.75),
              blurRadius: 10,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainterCore.paint(
      canvas,
      Offset(center.dx - (textPainterCore.width / 2), center.dy - (textPainterCore.height / 2)),
    );
  }

  @override
  bool shouldRepaint(covariant _Pluto3DOrbPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.pulse != pulse ||
        oldDelegate.wave != wave ||
        oldDelegate.state != state;
  }
}
