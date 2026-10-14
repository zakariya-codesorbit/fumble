import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Outlined gold "Record Memory" control on the fumble preview.
class FumblePreviewRecordMemory extends StatelessWidget {
  const FumblePreviewRecordMemory({
    super.key,
    this.onTap,
    this.isListening = false,
  });

  final VoidCallback? onTap;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    final label = isListening
        ? AppConstant.listeningMemory
        : AppConstant.recordMemory;
    final accent = isListening ? AppColors.error : AppColors.gold;

    return Material(
      color: AppColors.clear,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent, width: isListening ? 1.4 : 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isListening ? Icons.mic_rounded : AppIcons.mic,
                size: 22,
                color: accent,
              ),
              10.width,
              label.toText(
                color: accent,
                fontSize: 16,
                fontWeight: AppStyle.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
