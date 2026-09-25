import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';

/// Branded Fumble QR. [data] is the existing payload, unchanged.
class FlumbleQrCode extends StatefulWidget {
  const FlumbleQrCode({
    super.key,
    required this.data,
    this.size = AppStyle.flumbleQrSize,
  });

  final String data;
  final double size;

  @override
  State<FlumbleQrCode> createState() => _FlumbleQrCodeState();
}

class _FlumbleQrCodeState extends State<FlumbleQrCode> {
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
        ..color = AppColors.qrModule
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    final painter = TextPainter(
      text: TextSpan(
        text: AppConstant.fumbleCta.split('').join(' '),
        style: const TextStyle(
          color: AppColors.qrModule,
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
    return SizedBox.square(
      dimension: widget.size,
      child: PrettyQrView.data(
        data: widget.data,
        errorCorrectLevel: QrErrorCorrectLevel.H,
        decoration: PrettyQrDecoration(
          background: AppColors.gold,
          shape: const PrettyQrDotsSymbol(color: AppColors.qrModule),
          quietZone: const PrettyQrQuietZone.modules(4),
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
    );
  }
}
