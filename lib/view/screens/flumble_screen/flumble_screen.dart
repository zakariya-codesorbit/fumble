import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/flumble_screen/components/fumble_button.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/dialogs/app_bottom_sheet.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';

class FlumbleScreen extends ConsumerWidget {
  const FlumbleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final buttonSize = (constraints.maxHeight * 0.36)
                  .clamp(176.0, AppStyle.fumbleButtonSize)
                  .toDouble();
              final topGap = constraints.maxHeight < 640 ? 24.0 : 48.0;
              final code = ref
                  .watch(currentUserProfileProvider)
                  .asData
                  ?.value
                  ?.flumbleCode;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: topGap),
                        AppConstant.readyTo.toText(
                          fontSize: 42,
                          fontWeight: AppStyle.w400,
                          lineHeight: 1.2,
                        ),
                        AppConstant.fumbleQuestion.toText(
                          color: AppColors.gold,
                          fontSize: 42,
                          fontWeight: AppStyle.w400,
                          lineHeight: 1.2,
                        ),
                        16.height,
                        AppConstant.tapTheButton.toText(
                          fontSize: 18,
                          color: AppColors.softGray,
                        ),
                        2.height,
                        AppConstant.readyToConnect.toText(
                          fontSize: 18,
                          color: AppColors.softGray,
                        ),
                        const Spacer(),
                        Center(
                          child: FumbleButton(
                            size: buttonSize,
                            onPressed: () => _openExchange(context, ref, code),
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ).paddingSymmetric(horizontal: 28.w);
            },
          ),
        ),
      ),
    );
  }
}

void _openExchange(BuildContext context, WidgetRef ref, String? code) {
  final actions = ref.read(fumbleNotifierProvider.notifier);
  showAppBottomSheet<void>(
    context: context,
    title: AppConstant.exchangeTitle,
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ExchangeOption(
            icon: AppIcons.shareFumble,
            label: AppConstant.shareMyFumble,
            onTap: () {
              Navigator.pop(sheetContext);
              if (code == null || code.isEmpty) {
                showAppToast(AppConstant.completeProfile, isError: true);
                return;
              }
              actions.openShare();
            },
          ),
          Divider(height: 1, thickness: 1, color: AppColors.border),
          _ExchangeOption(
            icon: AppIcons.scan,
            label: AppConstant.connectFumble,
            onTap: () {
              Navigator.pop(sheetContext);
              actions.startFumble();
            },
          ),
        ],
      );
    },
  );
}

class _ExchangeOption extends StatelessWidget {
  const _ExchangeOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 22),
            14.width,
            Expanded(
              child: label.toText(
                fontSize: 16,
                fontWeight: AppStyle.w600,
                color: AppColors.white,
              ),
            ),
            const Icon(
              AppIcons.chevronRight,
              color: AppColors.softGray,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
