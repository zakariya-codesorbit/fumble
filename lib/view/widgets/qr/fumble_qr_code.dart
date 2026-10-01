import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';

/// Branded Fumble QR. [data] is the existing payload, unchanged.
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
          fontSize: 28,
          fontWeight: AppStyle.w600,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: px * 0.72);
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
    final ring = math.max(1.2, widget.size * 0.012);
    final codeSize = (widget.size - ring * 2) / math.sqrt2;
    final modules = QrCode.fromData(
      data: widget.data,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    ).moduleCount;
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _FilledPlatePainter(
                codeSize: codeSize,
                modules: modules,
                ring: ring,
              ),
            ),
          ),
          SizedBox.square(
            dimension: codeSize,
            child: PrettyQrView.data(
              data: widget.data,
              errorCorrectLevel: QrErrorCorrectLevel.H,
              decoration: PrettyQrDecoration(
                background: AppColors.gold,
                shape: const PrettyQrSmoothSymbol(
                  color: AppColors.background,
                  roundFactor: 0,
                ),
                quietZone: PrettyQrQuietZone.zero,
                image: _mark == null
                    ? null
                    : PrettyQrDecorationImage(
                        image: _mark!,
                        scale: 0.18,
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

/// Gold circle, blocks around the real code, and the outer ring.
class _FilledPlatePainter extends CustomPainter {
  _FilledPlatePainter({
    required this.codeSize,
    required this.modules,
    required this.ring,
  });

  final double codeSize;
  final int modules;
  final double ring;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final module = codeSize / modules;
    final origin = center - Offset(codeSize / 2, codeSize / 2);
    final limit = radius - ring;

    canvas.drawCircle(center, radius, Paint()..color = AppColors.gold);

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: limit)),
    );
    final ink = Paint()..color = AppColors.background;
    final half = codeSize / 2;
    final span = (limit / module).ceil() + 2;
    for (var row = -span; row < modules + span; row++) {
      for (var col = -span; col < modules + span; col++) {
        final rect = Rect.fromLTWH(
          origin.dx + col * module,
          origin.dy + row * module,
          module + 0.01,
          module + 0.01,
        );
        final point = rect.center;
        if ((point - center).distance > limit) continue;
        if ((point.dx - center.dx).abs() <= half &&
            (point.dy - center.dy).abs() <= half) {
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

  /// Same square size as the real code, with an irregular on/off pattern.
  bool _module(int row, int col) {
    final n = (row * 47) ^ (col * 19) ^ (row * col * 3);
    return n.abs() % 5 < 3;
  }

  @override
  bool shouldRepaint(_FilledPlatePainter oldDelegate) {
    return oldDelegate.codeSize != codeSize ||
        oldDelegate.modules != modules ||
        oldDelegate.ring != ring;
  }
}
