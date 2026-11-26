import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/style.dart';

/// Circular AI coins badge — muted `$` behind script numerals.
class AiCoinsBadge extends StatelessWidget {
  const AiCoinsBadge({
    super.key,
    required this.count,
    this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  /// Border / dollar tone from the design reference.
  static const Color _ring = Color(0xFF7A5C2E);

  /// Cream numerals over the dollar.
  static const Color _numeral = Color(0xFFF5E8C7);

  @override
  Widget build(BuildContext context) {
    final label = count > 999 ? '999+' : '$count';
    final numeralSize = label.length >= 4
        ? 16.0
        : label.length == 3
            ? 20.0
            : 22.0;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: AppColors.clear,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
              border: Border.all(color: _ring, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Large `$` sits behind the count.
                Text(
                  r'$',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppStyle.fontFamilyScript,
                    fontFamilyFallback: AppStyle.fontFamilyFallback,
                    color: _ring.withValues(alpha: 0.9),
                    fontSize: 34,
                    height: 1,
                    fontWeight: AppStyle.w400,
                  ),
                ),
                // Script count on top of the dollar.
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppStyle.fontFamilyScript,
                      fontFamilyFallback: AppStyle.fontFamilyFallback,
                      color: _numeral,
                      fontSize: numeralSize,
                      height: 1,
                      fontWeight: AppStyle.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
