import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/inputs/custom_text_field.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _phone = TextEditingController();
  final _aboutMe = TextEditingController();
  final _location = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(profileNotifierProvider.notifier).resetEdit();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _phone.dispose();
    _aboutMe.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final edit = ref.watch(profileNotifierProvider);
    final profileActions = ref.read(profileNotifierProvider.notifier);

    if (profile != null && !_initialized) {
      _name.text = profile.name;
      _bio.text = profile.bio ?? '';
      _phone.text = profile.phone ?? '';
      _aboutMe.text = profile.aboutMe ?? '';
      _location.text = profile.location ?? '';
      _initialized = true;
    }

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: const AppAppBar(title: AppConstant.editProfile, showBack: true),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            children: [
              24.height,
              Center(
                child: ProfileAvatar(
                  photoUrl: edit.displayPhotoUrl(profile),
                  localFile: edit.localPhoto,
                  name: profile?.name ?? _name.text,
                  size: 110,
                  onTap: () => profileActions.showPhotoSheet(context),
                ),
              ),
              12.height,
              AppConstant.changePhoto
                  .toText(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: AppStyle.w500,
                    textAlign: TextAlign.center,
                  )
                  .onPress(() => profileActions.showPhotoSheet(context)),
              28.height,
              CustomTextField(
                controller: _name,
                label: AppConstant.nameLabel,
                hintText: AppConstant.nameHint,
              ),
              16.height,
              CustomTextField(
                controller: _bio,
                label: AppConstant.bioLabel,
                hintText: AppConstant.bioHint,
              ),
              16.height,
              CustomTextField(
                controller: _phone,
                label: AppConstant.phoneLabel,
                hintText: AppConstant.phoneHint,
                keyboardType: TextInputType.phone,
              ),
              16.height,
              CustomTextField(
                controller: _aboutMe,
                label: AppConstant.aboutMeLabel,
                hintText: AppConstant.aboutMeHint,
              ),
              16.height,
              CustomTextField(
                controller: _location,
                label: AppConstant.locationLabel,
                hintText: AppConstant.locationHint,
              ),
              32.height,
              PrimaryButton(
                buttonName: AppConstant.save,
                isLoading: edit.isSaving,
                onPressed: () => profileActions.save(
                  name: _name.text,
                  bio: _bio.text,
                  phone: _phone.text,
                  aboutMe: _aboutMe.text,
                  location: _location.text,
                ),
              ),
              24.height,
            ],
          ),
        ),
      ),
    );
  }
}
