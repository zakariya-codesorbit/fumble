import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({
    super.key,
    this.title,
    this.subtitle,
    this.topSpacing,
  });

  final String? title;
  final String? subtitle;
  final int? topSpacing;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (topSpacing != null) topSpacing!.height,
            CustomPaint(
              painter: _DashedRRectPainter(
                color: AppColors.primaryMuted.withValues(alpha: 0.45),
                radius: 20,
                strokeWidth: 1.2,
                dashLength: 6,
                gapLength: 4,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 36.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    (title ?? AppConstant.dataNotFound).toText(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: AppStyle.w700,
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null) ...[
                      10.height,
                      subtitle!.toText(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: AppStyle.w400,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}
