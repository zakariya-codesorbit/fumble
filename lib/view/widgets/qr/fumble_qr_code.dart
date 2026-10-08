import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';

/// Branded Fumble QR. [data] is the existing payload, unchanged.
///
/// Tuned for fast phone-to-phone scans: solid quiet zone, sharp modules,
/// and finder patterns kept clear of the circular plate edge.
class FumbleQrCode extends StatefulWidget {
  const FumbleQrCode({
    super.key,
    required this.data,
    this.size = AppStyle.fumbleQrSize,
  });

  final String data;
  final double size;

  @override
  State<FumbleQrCode> createState() => _FumbleQrCodeState();
}

class _FumbleQrCodeState extends State<FumbleQrCode> {
  MemoryImage? _mark;

  /// Q recovers ~25% — enough for the small center mark, fewer modules than H.
  static const _ecc = QrErrorCorrectLevel.Q;

  /// Quiet modules around the matrix (kept thin for a tighter plate look).
  static const double _quietModules = 0;

  @override
  void initState() {
    super.initState();
    _loadMark();
  }

  Future<void> _loadMark() async {
    final bytes = await _paintMark();
    if (!mounted) return;
    setState(() => _mark = MemoryImage(bytes));
  }

  Future<Uint8List> _paintMark() async {
    const px = 256.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(px / 2, px / 2);
    final radius = px / 2 - 8;

    canvas.drawCircle(center, radius, Paint()..color = AppColors.gold);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.background
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    final painter = TextPainter(
      text: TextSpan(
        text: AppConstant.fumbleCta.split('').join(' '),
        style: const TextStyle(
          color: AppColors.background,
          fontSize: 34,
          fontWeight: AppStyle.w700,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: px * 0.86);
    painter.paint(
      canvas,
      Offset((px - painter.width) / 2, (px - painter.height) / 2),
    );

    final image = await recorder.endRecording().toImage(px.toInt(), px.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final ring = math.max(4.0, widget.size * 0.045);
    final modules = QrCode.fromData(
      data: widget.data,
      errorCorrectLevel: _ecc,
    ).moduleCount;

    // Inscribe the QR (matrix + quiet zone) inside the circle.
    final inner = widget.size - ring * 2;
    final codeSize = (inner / math.sqrt2) * 0.98;
    final modulePx = codeSize / (modules + _quietModules * 2);
    final quietPx = modulePx * _quietModules;

    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _FilledPlatePainter(
                codeSize: codeSize,
                quietPx: quietPx,
                modules: modules,
                ring: ring,
              ),
            ),
          ),
          SizedBox.square(
            dimension: codeSize,
            child: PrettyQrView.data(
              data: widget.data,
              errorCorrectLevel: _ecc,
              decoration: PrettyQrDecoration(
                background: AppColors.gold,
                shape: const PrettyQrSmoothSymbol(
                  color: AppColors.background,
                  roundFactor: 0,
                ),
                quietZone: const PrettyQrQuietZone.modules(_quietModules),
                image: _mark == null
                    ? null
                    : PrettyQrDecorationImage(
                        image: _mark!,
                        // Keep the mark small so modules stay easy to resolve.
                        scale: 0.4,
                        position: PrettyQrDecorationImagePosition.embedded,
                        clipper: const PrettyQrCircleClipper(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gold circle, decorative modules outside the quiet zone, outer ring.
class _FilledPlatePainter extends CustomPainter {
  _FilledPlatePainter({
    required this.codeSize,
    required this.quietPx,
    required this.modules,
    required this.ring,
  });

  final double codeSize;
  final double quietPx;
  final int modules;
  final double ring;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final module = (codeSize - quietPx * 2) / modules;
    final origin = center - Offset(codeSize / 2, codeSize / 2);
    final limit = radius - ring;

    canvas.drawCircle(center, radius, Paint()..color = AppColors.gold);

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: limit)),
    );
    final ink = Paint()..color = AppColors.background;
    // Clear band stops at the matrix edge so filler sits closer to the code.
    final clearHalf = codeSize / 2 - quietPx;
    final span = (limit / module).ceil() + 2;
    for (var row = -span; row < modules + span; row++) {
      for (var col = -span; col < modules + span; col++) {
        final rect = Rect.fromLTWH(
          origin.dx + quietPx + col * module,
          origin.dy + quietPx + row * module,
          module - 0.01,
          module - 0.01,
        );
        final point = rect.center;
        if ((point - center).distance > limit) continue;
        if ((point.dx - center.dx).abs() <= clearHalf &&
            (point.dy - center.dy).abs() <= clearHalf) {
          continue;
        }
        if (!_module(row, col)) continue;
        canvas.drawRect(rect, ink);
      }
    }
    canvas.restore();

    canvas.drawCircle(
      center,
      radius - ring / 2,
      Paint()
        ..color = AppColors.background
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring,
    );
  }

  bool _module(int row, int col) {
    final n = (row * 47) ^ (col * 19) ^ (row * col * 3);
    return n.abs() % 5 < 3;
  }

  @override
  bool shouldRepaint(_FilledPlatePainter oldDelegate) {
    return oldDelegate.codeSize != codeSize ||
        oldDelegate.quietPx != quietPx ||
        oldDelegate.modules != modules ||
        oldDelegate.ring != ring;
  }
}
