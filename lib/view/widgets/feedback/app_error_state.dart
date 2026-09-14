import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/buttons/text_button_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (message ?? AppConstant.somethingWrong).toText(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: AppStyle.w400,
          ),
          12.height,
          TextButtonWidget(
            buttonName: AppConstant.retry,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
