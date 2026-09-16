import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/auth_screen/components/top_view.dart';
import 'package:fumble/view/screens/flumble_screen/components/preview_detail_row.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/buttons/secondary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

class FumblePreviewScreen extends ConsumerWidget {
  const FumblePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fumble = ref.watch(fumbleNotifierProvider);
    final fumbleActions = ref.read(fumbleNotifierProvider.notifier);
    final preview = fumble.preview;

    if (preview == null) {
      return BaseScreenWidget(
        builder: (context) => ScaffoldContent(
          body: Center(
            child: PrimaryButton(
              buttonName: AppConstant.done,
              onPressed: fumbleActions.cancel,
            ),
          ),
        ),
      );
    }

    final displayName =
        preview.firstName.isNotEmpty ? preview.firstName : preview.name;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TopView(
                        title: AppConstant.connectWith(displayName),
                        subtitle: AppConstant.previewSubtitleFor(preview.name),
                        showBack: true,
                        onBack: fumbleActions.cancel,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            ProfileAvatar(
                              photoUrl: preview.photoUrl,
                              name: preview.name,
                              size: 96,
                            ),
                            12.height,
                            preview.name.toText(
                              fontSize: 20,
                              fontWeight: AppStyle.w600,
                              textAlign: TextAlign.center,
                            ),
                            if (preview.hasBio) ...[
                              6.height,
                              preview.bio!.toText(
                                fontSize: 14,
                                color: AppColors.softGray,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                      28.height,
                      if (preview.hasPhone) ...[
                        PreviewDetailRow(
                          label: AppConstant.phoneLabel,
                          value: preview.phone!,
                          icon: AppIcons.phone,
                        ),
                        20.height,
                      ],
                      if (preview.hasEmail) ...[
                        PreviewDetailRow(
                          label: AppConstant.emailLabel,
                          value: preview.email!,
                          icon: AppIcons.email,
                        ),
                        20.height,
                      ],
                      if (preview.hasLocation) ...[
                        PreviewDetailRow(
                          label: AppConstant.locationLabel,
                          value: preview.location!,
                          icon: AppIcons.location,
                        ),
                        20.height,
                      ],
                      if (preview.hasAboutMe) ...[
                        PreviewDetailRow(
                          label: AppConstant.aboutMeLabel,
                          value: preview.aboutMe!,
                        ),
                        20.height,
                      ],
                    ],
                  ).paddingSymmetric(horizontal: 28.w),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(28.w, 8, 28.w, 24.h),
                child: Column(
                  children: [
                    PrimaryButton(
                      buttonName: AppConstant.confirmFumble,
                      onPressed: fumbleActions.confirm,
                    ),
                    12.height,
                    SecondaryButton(
                      buttonName: AppConstant.cancel,
                      onPressed: fumbleActions.cancel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
