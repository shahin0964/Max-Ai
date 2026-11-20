import 'package:flutter/material.dart';

class RainbowEdgeGlow extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const RainbowEdgeGlow({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<RainbowEdgeGlow> createState() => _RainbowEdgeGlowState();
}

class _RainbowEdgeGlowState extends State<RainbowEdgeGlow> with SingleTickerProviderStateMixin {
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
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * 3.14159;
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 2.5,
              color: Colors.transparent,
            ),
          ),
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              width: 2.2,
              color: Colors.transparent,
            ),
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: 0.0,
              endAngle: 3.14159 * 2,
              transform: GradientRotation(angle),
              colors: const [
                Color(0x9900E5FF), // Cyan
                Color(0x99FF2A85), // Pink
                Color(0x99A855F7), // Purple
                Color(0x993B82F6), // Blue
                Color(0x9910B981), // Emerald
                Color(0x99F59E0B), // Amber
                Color(0x9900E5FF), // Back to Cyan
              ],
            ),
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
