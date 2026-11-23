import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/password_validator.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Live password rules as chips — shown once the user starts typing.
class PasswordRequirementsHint extends StatelessWidget {
  const PasswordRequirementsHint({super.key, required this.password});

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RequirementChip(rule: rules[0]),
              _RequirementChip(rule: rules[1]),
            ],
          ),
          8.height,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RequirementChip(rule: rules[2]),
              _RequirementChip(rule: rules[3]),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequirementChip extends StatelessWidget {
  const _RequirementChip({required this.rule});

  final ({String label, bool met}) rule;

  @override
  Widget build(BuildContext context) {
    final fg = rule.met ? AppColors.success : AppColors.softGray;
    final bg = rule.met
        ? AppColors.success.withValues(alpha: 0.12)
        : AppColors.surfaceElevated;
    final border = rule.met
        ? AppColors.success.withValues(alpha: 0.45)
        : AppColors.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            rule.met ? Icons.check_rounded : Icons.close,
            size: 14,
            color: fg,
          ),
          6.width,
          rule.label.toText(
            fontSize: 11,
            fontWeight: AppStyle.w500,
            color: fg,
            maxLine: 1,
          ),
        ],
      ),
    );
  }
}
