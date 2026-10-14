import 'package:flutter/material.dart';
import 'package:fumble/core/theme/colors.dart';

/// Dimmed mask with a circular gold cutout matching the share QR.
class CircularScanOverlayPainter extends CustomPainter {
  CircularScanOverlayPainter({required this.cutoutSize, required this.pulse});

  final double cutoutSize;
  final bool pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = cutoutSize / 2;

    final hole = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(
      hole,
      Paint()..color = AppColors.background.withValues(alpha: 0.72),
    );

    canvas.drawCircle(
      center,
      radius + 10,
      Paint()
        ..color = AppColors.gold.withValues(alpha: pulse ? 0.18 : 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.gold.withValues(alpha: pulse ? 0.95 : 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = pulse ? 3.5 : 2.8,
    );

    canvas.drawCircle(
      center,
      radius - 10,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CircularScanOverlayPainter oldDelegate) {
    return oldDelegate.cutoutSize != cutoutSize || oldDelegate.pulse != pulse;
  }
}
