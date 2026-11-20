import 'package:flutter/material.dart';

import 'package:fumble/core/navigation/navigator_keys.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

void showToast({required String message, bool isError = false}) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  final text = message.trim();
  if (text.isEmpty) return;

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.clear,
      elevation: 0,
      // Keep the toast compact so it always fits above bottomNavigationBar.
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: EdgeInsets.zero,
      content: Align(
        alignment: Alignment.center,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 96),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
            ),
            child: text.toText(
              textAlign: TextAlign.center,
              fontSize: 14,
              fontWeight: AppStyle.w400,
              color: isError ? AppColors.error : AppColors.white,
              maxLine: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    ),
  );
}

void showAppToast(String message, {bool isError = false}) =>
    showToast(message: message, isError: isError);
