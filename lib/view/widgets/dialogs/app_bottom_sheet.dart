import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';

/// Rounded surface shell for modal bottom sheets (spacing + keyboard / safe inset).
///
/// Always shows a [title] row and a close action. Put main content in [child].
///
/// Prefer [showAppBottomSheet]: pass [title] and body via [builder].
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 24,
    this.titleBottomGap = 8,
    this.titleAccessoryActions,
  });

  final String title;
  final Widget child;
  final List<Widget>? titleAccessoryActions;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;
  final int titleBottomGap;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final resolvedPadding = padding ??
        EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 14.h,
          bottom: mq.padding.bottom + mq.viewInsets.bottom + 14.h,
        );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      ),
      padding: resolvedPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          5.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: title.toText(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  maxLine: 2,
                ),
              ),
              if (titleAccessoryActions != null) ...titleAccessoryActions!,
              Icon(
                Icons.close_rounded,
                size: 22.h,
                color: AppColors.secondaryText,
              ).onPress(() => Navigator.maybePop(context)),
            ],
          ),
          SizedBox(height: titleBottomGap.h),
          child,
        ],
      ),
    );
  }
}

/// Opens [AppBottomSheet] with modal options; [builder] returns only the body below the title row.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? barrierColor,
  double? borderRadius,
  Color? backgroundColor,
  EdgeInsetsGeometry? padding,
  int titleBottomGap = 15,
  List<Widget>? titleAccessoryActions,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.clear,
    barrierColor: barrierColor ?? AppColors.background.withValues(alpha: 0.72),
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    elevation: 0,
    builder: (sheetContext) => AppBottomSheet(
      title: title,
      borderRadius: borderRadius ?? 24,
      backgroundColor: backgroundColor,
      padding: padding,
      titleBottomGap: titleBottomGap,
      titleAccessoryActions: titleAccessoryActions,
      child: builder(sheetContext).paddingOnly(bottom: 20.h),
    ),
  );
}
