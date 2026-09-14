import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size, this.strokeWidth = 2.5});

  final double? size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final extent = size ?? 36.h;
    return Center(
      child: SizedBox(
        width: extent,
        height: extent,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color: AppColors.gold,
        ),
      ),
    );
  }
}
