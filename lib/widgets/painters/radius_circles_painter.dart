
import 'dart:math';
import 'package:flutter/material.dart';

class RadiusCirclesPainter extends CustomPainter {
  final List<double> radiusLevels;
  final Color color;

  RadiusCirclesPainter({
    this.radiusLevels = const [0.2, 0.4, 0.6], // Percentage of screen width
    this.color = Colors.orange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);

    // Create dotted path
    final Path dashPath = Path();
    const double dashWidth = 8;
    const double dashSpace = 8;

    for (double radius in radiusLevels) {
      final double circleRadius = size.width * radius;
      final double circumference = 2 * pi * circleRadius;
      final int dashCount = (circumference / (dashWidth + dashSpace)).round();
      final double angle = 2 * pi / dashCount;

      for (int i = 0; i < dashCount; i++) {
        final double startAngle = i * angle;
        final double endAngle = startAngle + (angle * dashWidth / (dashWidth + dashSpace));

        final Path arc = Path()
          ..addArc(
            Rect.fromCircle(center: center, radius: circleRadius),
            startAngle,
            endAngle - startAngle,
          );

        dashPath.addPath(arc, Offset.zero);
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}