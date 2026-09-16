import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';

/// Premium Flumble QR: real payload, organic modules, scannable dark-on-light.
class FlumbleQrView extends StatelessWidget {
  const FlumbleQrView({
    super.key,
    required this.data,
    this.size = 240,
  });

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: FlumbleQrPainter(data: data),
    );
  }
}

class FlumbleQrPainter extends CustomPainter {
  FlumbleQrPainter({required this.data}) : _qrImage = _encode(data);

  final String data;
  final QrImage _qrImage;

  static QrImage _encode(String data) {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );
    return QrImage(qrCode);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final count = _qrImage.moduleCount;
    const quietModules = 3.0;
    final module = size.shortestSide / (count + quietModules * 2);
    final origin = Offset(
      (size.width - count * module) / 2,
      (size.height - count * module) / 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.shortestSide * AppStyle.flumbleQrRadiusFactor),
      ),
      Paint()..color = AppColors.qrGround,
    );

    final paint = Paint()
      ..color = AppColors.qrModule
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _drawFinders(canvas, origin, module, count, paint);

    for (var y = 0; y < count; y++) {
      for (var x = 0; x < count; x++) {
        if (_inFinder(x, y, count)) continue;
        if (!_qrImage.isDark(y, x)) continue;
        _drawModule(canvas, origin, module, x, y, count, paint);
      }
    }
  }

  bool _inFinder(int x, int y, int count) {
    bool inside(int ox, int oy) =>
        x >= ox && x < ox + 7 && y >= oy && y < oy + 7;
    return inside(0, 0) || inside(count - 7, 0) || inside(0, count - 7);
  }

  bool _dark(int x, int y, int count) {
    if (x < 0 || y < 0 || x >= count || y >= count) return false;
    if (_inFinder(x, y, count)) return false;
    return _qrImage.isDark(y, x);
  }

  void _drawModule(
    Canvas canvas,
    Offset origin,
    double module,
    int x,
    int y,
    int count,
    Paint paint,
  ) {
    final inset = module * 0.05;
    final rect = Rect.fromLTWH(
      origin.dx + x * module + inset,
      origin.dy + y * module + inset,
      module - inset * 2,
      module - inset * 2,
    );
    final radius = rect.shortestSide / 2;

    final hasL = _dark(x - 1, y, count);
    final hasR = _dark(x + 1, y, count);
    final hasT = _dark(x, y - 1, count);
    final hasB = _dark(x, y + 1, count);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular((!hasL && !hasT) ? radius : 0),
        topRight: Radius.circular((!hasR && !hasT) ? radius : 0),
        bottomLeft: Radius.circular((!hasL && !hasB) ? radius : 0),
        bottomRight: Radius.circular((!hasR && !hasB) ? radius : 0),
      ),
      paint,
    );
  }

  void _drawFinders(
    Canvas canvas,
    Offset origin,
    double module,
    int count,
    Paint paint,
  ) {
    _drawFinder(canvas, origin.dx, origin.dy, module, paint);
    _drawFinder(
      canvas,
      origin.dx + (count - 7) * module,
      origin.dy,
      module,
      paint,
    );
    _drawFinder(
      canvas,
      origin.dx,
      origin.dy + (count - 7) * module,
      module,
      paint,
    );
  }

  void _drawFinder(
    Canvas canvas,
    double left,
    double top,
    double module,
    Paint paint,
  ) {
    final size = module * 7;
    final ring = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, size, size),
          Radius.circular(module * 1.15),
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left + module,
            top + module,
            size - module * 2,
            size - module * 2,
          ),
          Radius.circular(module * 0.75),
        ),
      );
    canvas.drawPath(ring, paint);

    canvas.drawCircle(
      Offset(left + size / 2, top + size / 2),
      module * 1.5,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant FlumbleQrPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
