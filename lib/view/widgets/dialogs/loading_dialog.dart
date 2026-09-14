import 'package:flutter/material.dart';

import 'package:fumble/core/navigation/navigator_keys.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';

Future<void> showLoadingDialog({String? message}) {
  final nav = navigatorKey.currentState;
  if (nav == null) return Future<void>.value();

  return showDialog<void>(
    context: nav.context,
    barrierDismissible: false,
    barrierColor: AppColors.background.withValues(alpha: 0.72),
    builder: (_) {
      return PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: AppColors.clear,
            child: Container(
              width: 120.w,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLoader(strokeWidth: 2.5),
                  if (message != null && message.isNotEmpty) ...[
                    16.height,
                    message.toText(
                      textAlign: TextAlign.center,
                      fontSize: 12,
                      fontWeight: AppStyle.w500,
                      color: AppColors.softGray,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void hideLoadingDialog() {
  final nav = navigatorKey.currentState;
  if (nav == null || !nav.canPop()) return;
  nav.pop();
}
