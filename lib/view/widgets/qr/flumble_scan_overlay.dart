import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';

/// Rounded-square scan window matching the Flumble QR plate.
class FlumbleScanOverlay extends StatelessWidget {
  const FlumbleScanOverlay({
    super.key,
    this.cutoutSize = AppStyle.flumbleScanCutout,
  });

  final double cutoutSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FlumbleScanOverlayPainter(cutoutSize: cutoutSize),
      child: const SizedBox.expand(),
    );
  }
}

class _FlumbleScanOverlayPainter extends CustomPainter {
  _FlumbleScanOverlayPainter({required this.cutoutSize});

  final double cutoutSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 18);
    final cutout = Rect.fromCenter(
      center: center,
      width: cutoutSize,
      height: cutoutSize,
    );
    final radius = Radius.circular(
      cutoutSize * AppStyle.flumbleQrRadiusFactor,
    );
    final cutoutRRect = RRect.fromRectAndRadius(cutout, radius);

    final overlay = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(cutoutRRect);
    canvas.drawPath(
      overlay,
      Paint()..color = AppColors.background.withValues(alpha: 0.72),
    );

    final border = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.gold, AppColors.goldDeep, AppColors.gold],
      ).createShader(cutout)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(cutoutRRect, border);

    canvas.drawRRect(
      cutoutRRect.deflate(6),
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    const finder = 30.0;
    _drawFinder(canvas, Offset(cutout.left, cutout.top), finder);
    _drawFinder(canvas, Offset(cutout.right - finder, cutout.top), finder);
    _drawFinder(canvas, Offset(cutout.left, cutout.bottom - finder), finder);
  }

  void _drawFinder(Canvas canvas, Offset origin, double size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final ringWidth = size * 0.145;
    final ring = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(origin.dx, origin.dy, size, size),
          Radius.circular(size * 0.28),
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            origin.dx + ringWidth,
            origin.dy + ringWidth,
            size - ringWidth * 2,
            size - ringWidth * 2,
          ),
          Radius.circular(size * 0.18),
        ),
      );
    canvas.drawPath(ring, paint);
    canvas.drawCircle(
      origin + Offset(size / 2, size / 2),
      size * 0.2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FlumbleScanOverlayPainter oldDelegate) {
    return oldDelegate.cutoutSize != cutoutSize;
  }
}
