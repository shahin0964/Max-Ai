import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GradientLogo extends StatelessWidget {
  final double size;
  final bool showGlow;

  const GradientLogo({
    super.key,
    this.size = 64,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.neonPurple.withOpacity(0.35),
                  blurRadius: size * 0.4,
                  spreadRadius: size * 0.05,
                ),
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.3),
                  blurRadius: size * 0.3,
                  spreadRadius: size * 0.02,
                ),
              ]
            : null,
      ),
      child: ShaderMask(
        shaderCallback: (bounds) => AppColors.logoGradient.createShader(bounds),
        child: CustomPaint(
          size: Size(size, size),
          painter: _LogoPainter(),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Smooth stylized 'M' curve
    path.moveTo(w * 0.18, h * 0.82);
    path.lineTo(w * 0.32, h * 0.24);
    path.lineTo(w * 0.50, h * 0.58);
    path.lineTo(w * 0.68, h * 0.24);
    path.lineTo(w * 0.82, h * 0.82);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
