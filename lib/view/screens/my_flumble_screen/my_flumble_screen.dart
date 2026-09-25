import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/my_flumble_screen/components/profile_header.dart';
import 'package:fumble/view/screens/my_flumble_screen/components/profile_info_cards.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/app_error_state.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';

import 'components/location_card.dart';

class MyFlumbleScreen extends ConsumerWidget {
  const MyFlumbleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.brand,
          brandTitle: true,
          leading: IconButton(
            icon: const Icon(AppIcons.settings, color: AppColors.white),
            onPressed: () => push(AppRoutes.settings),
          ),
        ),
        body: profileAsync.when(
          loading: () => const AppLoader(),
          error: (e, _) => AppErrorState(
            onRetry: () => ref.invalidate(currentUserProfileProvider),
          ),
          data: (profile) {
            if (profile == null) {
              return Center(
                child: AppConstant.completeProfile.toText(
                  fontSize: 14,
                  color: AppColors.softGray,
                ),
              );
            }

            final memberSince = profile.createdAt != null
                ? DateFormat('MMMM yyyy').format(profile.createdAt!)
                : null;
            final phone = profile.phone?.trim();
            final hasPhone = phone != null && phone.isNotEmpty;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  8.height,
                  ProfileHeader(
                    name: profile.name,
                    photoUrl: profile.photoUrl,
                    heading: AppConstant.firstNameFlumble(profile.firstName),
                    bio: (profile.bio?.isNotEmpty == true)
                        ? profile.bio!
                        : AppConstant.addBio,
                    hasBio: profile.bio?.isNotEmpty == true,
                    phone: phone ?? '',
                    hasPhone: hasPhone,
                    onEdit: () => push(AppRoutes.editProfile),
                  ),
                  20.height,
                  ProfileInfoCard(
                    title: AppConstant.aboutMe,
                    body: (profile.aboutMe?.isNotEmpty == true)
                        ? profile.aboutMe!
                        : AppConstant.addAboutMe,
                    placeholder: profile.aboutMe?.isNotEmpty != true,
                    onEdit: () => push(AppRoutes.editProfile),
                  ),
                  12.height,
                  LocationCard(
                    location: (profile.location?.isNotEmpty == true)
                        ? profile.location!
                        : AppConstant.addLocation,
                    placeholder: profile.location?.isNotEmpty != true,
                    onEdit: () => push(AppRoutes.editProfile),
                  ),
                  if (memberSince != null) ...[
                    28.height,
                    AppConstant.memberSinceLabel(memberSince).toText(
                      fontSize: 12,
                      fontWeight: AppStyle.w500,
                      color: AppColors.softGray,
                    ),
                  ],
                  40.height,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
