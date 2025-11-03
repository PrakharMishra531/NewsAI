// lib/widgets/animated_gradient_border.dart

import 'package:flutter/cupertino.dart';

class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final List<Color> gradientColors;
  final Duration animationDuration;
  final double borderRadius;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 3.0,
    this.gradientColors = const [
      CupertinoColors.activeBlue,
      CupertinoColors.systemIndigo,
      CupertinoColors.systemPurple,
      CupertinoColors.systemPink,
    ],
    this.animationDuration = const Duration(seconds: 4),
    this.borderRadius = 8.0,
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(); // Make the animation loop indefinitely
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // We use a CustomPaint widget to draw our custom border
        return CustomPaint(
          painter: _GradientBorderPainter(
            animationValue: _controller.value,
            borderWidth: widget.borderWidth,
            gradientColors: widget.gradientColors,
            borderRadius: widget.borderRadius,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth), // Make space for the border
            child: widget.child,
          ),
        );
      },
    );
  }
}

// This is the actual painter that draws the gradient border
class _GradientBorderPainter extends CustomPainter {
  final double animationValue;
  final double borderWidth;
  final List<Color> gradientColors;
  final double borderRadius;

  _GradientBorderPainter({
    required this.animationValue,
    required this.borderWidth,
    required this.gradientColors,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    // Create the rotating gradient
    final gradient = SweepGradient(
      colors: gradientColors,
      startAngle: 0.0,
      endAngle: 2 * 3.14159, // Full circle
      transform: GradientRotation(2 * 3.14159 * animationValue), // Rotate based on animation
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect) // Apply the gradient
      ..style = PaintingStyle.stroke // Draw only the border
      ..strokeWidth = borderWidth; // Set border thickness

    canvas.drawRRect(rRect, paint); // Draw the rounded rectangle border
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    // Only repaint if the animation value changes
    return oldDelegate.animationValue != animationValue;
  }
}