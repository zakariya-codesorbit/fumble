import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/services/fumble/flumble_qr.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/flumble_screen/components/fumble_button.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';

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
              final code =
                  ref.watch(currentUserProfileProvider).asData?.value?.flumbleCode;
              final qrData = (code == null || code.isEmpty)
                  ? null
                  : FlumbleQr.build(code);

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
                            qrData: qrData,
                            onPressed: () => ref
                                .read(fumbleNotifierProvider.notifier)
                                .startFumble(),
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
