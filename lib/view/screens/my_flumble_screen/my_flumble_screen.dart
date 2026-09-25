import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/models/user_profile.dart';
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
import 'package:fumble/view/widgets/buttons/primary_button.dart';
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
            return _ProfileBody(profile: profile);
          },
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerStatefulWidget {
  const _ProfileBody({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<_ProfileBody> {
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _phone;
  late final TextEditingController _about;
  late final TextEditingController _location;
  String? _active;
  bool _readyToClose = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _name = TextEditingController(text: profile.name);
    _bio = TextEditingController(text: profile.bio ?? '');
    _phone = TextEditingController(text: profile.phone ?? '');
    _about = TextEditingController(text: profile.aboutMe ?? '');
    _location = TextEditingController(text: profile.location ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _phone.dispose();
    _about.dispose();
    _location.dispose();
    super.dispose();
  }

  bool get _textChanged {
    final profile = widget.profile;
    return _name.text.trim() != profile.name.trim() ||
        _bio.text.trim() != (profile.bio ?? '').trim() ||
        _phone.text.trim() != (profile.phone ?? '').trim() ||
        _about.text.trim() != (profile.aboutMe ?? '').trim() ||
        _location.text.trim() != (profile.location ?? '').trim();
  }

  void _openField(String key) {
    setState(() {
      _active = key;
      _readyToClose = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _active != key) return;
      setState(() => _readyToClose = true);
    });
  }

  void _closeIfStill(String key) {
    if (!_readyToClose || _active != key) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _active != key) return;
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _active = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final edit = ref.watch(profileNotifierProvider);
    final actions = ref.read(profileNotifierProvider.notifier);
    final photoChanged =
        edit.localPhoto != null || edit.avatarSvg != null || edit.removePhoto;
    final showSave = _textChanged || photoChanged;
    final memberSince = profile.createdAt != null
        ? DateFormat('MMMM yyyy').format(profile.createdAt!)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          8.height,
          ProfileHeader(
            name: profile.name,
            photoUrl: edit.displayPhotoUrl(profile),
            localFile: edit.localPhoto,
            svg: edit.avatarSvg,
            heading: AppConstant.firstNameFlumble(profile.firstName),
            editingName: _active == 'name',
            nameController: _name,
            onNameTap: () => _openField('name'),
            onNameChanged: (_) => setState(() {}),
            onNameTapOutside: () => _closeIfStill('name'),
            onPhotoTap: () => actions.showPhotoSheet(context),
          ),
          20.height,
          _field(
            keyName: 'bio',
            title: AppConstant.bioLabel,
            controller: _bio,
            placeholder: AppConstant.addBio,
            maxLine: 3,
          ),
          12.height,
          _field(
            keyName: 'phone',
            title: AppConstant.phoneLabel,
            controller: _phone,
            placeholder: AppConstant.addPhone,
            keyboardType: TextInputType.phone,
          ),
          12.height,
          _field(
            keyName: 'about',
            title: AppConstant.aboutMe,
            controller: _about,
            placeholder: AppConstant.addAboutMe,
            maxLine: 4,
          ),
          12.height,
          LocationCard(
            location: _location.text.trim().isNotEmpty
                ? _location.text.trim()
                : AppConstant.addLocation,
            placeholder: _location.text.trim().isEmpty,
            onTap: _active == 'location' ? null : () => _openField('location'),
            editor: _active == 'location'
                ? _inlineField(
                    fieldKey: 'location',
                    controller: _location,
                    hint: AppConstant.addLocation,
                  )
                : null,
          ),
          if (showSave) ...[
            16.height,
            PrimaryButton(
              buttonName: AppConstant.save,
              isLoading: edit.isSaving,
              onPressed: () => actions.save(
                name: _name.text,
                bio: _bio.text,
                phone: _phone.text,
                aboutMe: _about.text,
                location: _location.text,
              ),
            ),
          ],
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
  }

  Widget _field({
    required String keyName,
    required String title,
    required TextEditingController controller,
    required String placeholder,
    int maxLine = 1,
    TextInputType? keyboardType,
  }) {
    final text = controller.text.trim();
    final editing = _active == keyName;
    return ProfileInfoCard(
      title: title,
      body: text.isNotEmpty ? text : placeholder,
      placeholder: text.isEmpty,
      onTap: editing ? null : () => _openField(keyName),
      editor: editing
          ? _inlineField(
              fieldKey: keyName,
              controller: controller,
              hint: placeholder,
              maxLine: maxLine,
              keyboardType: keyboardType,
            )
          : null,
    );
  }

  Widget _inlineField({
    required String fieldKey,
    required TextEditingController controller,
    required String hint,
    int maxLine = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      autofocus: true,
      maxLines: maxLine,
      keyboardType: keyboardType,
      cursorColor: AppColors.gold,
      style: TextStyle(
        fontSize: 16,
        color: AppColors.secondaryText,
        fontFamilyFallback: AppStyle.fontFamilyFallback,
      ),
      onChanged: (_) => setState(() {}),
      onTapOutside: (_) => _closeIfStill(fieldKey),
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        hintText: hint,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}
