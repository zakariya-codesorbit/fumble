import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/password_validator.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Live password rules checklist — shown once the user starts typing.
class PasswordRequirementsHint extends StatelessWidget {
  const PasswordRequirementsHint({
    super.key,
    required this.password,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final rules = <({String label, bool met})>[
      (
        label: AppConstant.passwordRuleMinLength,
        met: PasswordValidator.hasMinLength(password),
      ),
      (
        label: AppConstant.passwordRuleLetterCase,
        met: PasswordValidator.hasLetterCase(password),
      ),
      (
        label: AppConstant.passwordRuleNumber,
        met: PasswordValidator.hasNumber(password),
      ),
      (
        label: AppConstant.passwordRuleSymbol,
        met: PasswordValidator.hasSymbol(password),
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final rule in rules) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  rule.met ? Icons.check_circle : Icons.circle_outlined,
                  size: 14,
                  color: rule.met ? AppColors.success : AppColors.softGrayDim,
                ),
                8.width,
                Expanded(
                  child: rule.label.toText(
                    fontSize: 12,
                    fontWeight: AppStyle.w400,
                    color: rule.met ? AppColors.success : AppColors.softGray,
                    maxLine: 2,
                  ),
                ),
              ],
            ),
            6.height,
          ],
        ],
      ),
    );
  }
}
