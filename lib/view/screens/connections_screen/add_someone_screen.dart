import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/repositories/half_fumble_repository.dart';
import 'package:fumble/services/location/fumble_location_service.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/my_fumble_group_card.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/dialogs/photo_permission_popup.dart';
import 'package:fumble/view/widgets/dialogs/photo_source_sheet.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import 'package:fumble/view/widgets/inputs/phone_country_field.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';
import 'package:fumble/services/storage/profile_photo_service.dart';

class AddSomeoneScreen extends ConsumerStatefulWidget {
  const AddSomeoneScreen({super.key});

  @override
  ConsumerState<AddSomeoneScreen> createState() => _AddSomeoneScreenState();
}

class _AddSomeoneScreenState extends ConsumerState<AddSomeoneScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _whatsApp = TextEditingController();
  final _note = TextEditingController();
  final _phoneKey = GlobalKey<PhoneCountryFieldState>();
  final _whatsAppKey = GlobalKey<PhoneCountryFieldState>();

  late String _phoneDial;
  late String _phoneCountry;
  late String _waDial;
  late String _waCountry;

  File? _localPhoto;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final device = PhoneCountryField.fromDeviceLocale();
    _phoneDial = device.dialCode;
    _phoneCountry = device.countryCode;
    _waDial = device.dialCode;
    _waCountry = device.countryCode;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _whatsApp.dispose();
    _note.dispose();
    super.dispose();
  }

  String _fullPhone(GlobalKey<PhoneCountryFieldState> key, String dial) {
    final national = key == _phoneKey ? _phone.text.trim() : _whatsApp.text.trim();
    if (national.isEmpty) return '';
    return key.currentState?.fullNumber ??
        PhoneCountryField.formatFull(dialCode: dial, national: national);
  }

  Future<void> _pickPhoto() async {
    final choice = await showPhotoSourceSheet(
      context,
      showRemove: _localPhoto != null,
    );
    if (choice == null || !mounted) return;

    if (choice == PhotoSourceChoice.remove) {
      setState(() => _localPhoto = null);
      return;
    }
    if (choice == PhotoSourceChoice.avatar) return;

    final fromCamera = choice == PhotoSourceChoice.camera;
    if (!await ensurePhotoSourcePermission(context, camera: fromCamera)) {
      return;
    }
    if (!mounted) return;

    final photos = ref.read(profilePhotoServiceProvider);
    try {
      final file = fromCamera
          ? await photos.pickFromCamera()
          : await photos.pickFromGallery();
      if (!mounted || file == null) return;
      setState(() => _localPhoto = file);
    } catch (e) {
      if (!mounted) return;
      if (isPhotoPermissionError(e)) {
        await showPhotoPermissionPopup(context, camera: fromCamera);
        return;
      }
      if (e is PhotoTooLargeException) {
        showAppToast(AppConstant.photoTooLarge, isError: true);
        return;
      }
      debugPrint('[AddSomeone] photo pick failed: $e');
      showAppToast(AppConstant.photoUploadFailed, isError: true);
    }
  }

  Future<String?> _currentMeetingLocation() async {
    if (!mounted) return null;
    final coords = await FumbleLocationService.capture(context);
    if (coords == null) return null;
    return FumbleLocationService.placeLabel(coords);
  }

  Future<void> _submit() async {
    if (_saving) return;
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile == null) {
      showAppToast(AppConstant.authPleaseLogIn, isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final meetingLocation = await _currentMeetingLocation();
      final result = await ref.read(halfFumbleRepositoryProvider).createAndInvite(
            inviter: profile,
            name: _name.text,
            email: _email.text,
            phone: _fullPhone(_phoneKey, _phoneDial),
            whatsApp: _fullPhone(_whatsAppKey, _waDial),
            meetingLocation: meetingLocation,
            meetingDate: DateTime.now(),
            personalNote: _note.text,
            localPhoto: _localPhoto,
          );

      await SharePlus.instance.share(
        ShareParams(
          text: AppConstant.halfFumbleShareMessage(
            invitedEmail: result.invitedEmail,
            storeUrl: result.storeUrl,
            appLink: result.appLink,
          ),
          subject: AppConstant.addSomeone,
        ),
      );

      if (!mounted) return;
      showAppToast(AppConstant.halfFumbleInviteShared);
      pop();
    } on HalfFumbleException catch (e) {
      showAppToast(e.message, isError: true);
    } catch (e) {
      debugPrint('[AddSomeone] send invite failed: $e');
      showAppToast(AppConstant.somethingWrong, isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.addSomeone,
          showBack: true,
          onBack: _saving ? null : pop,
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: MyFumbleGroupCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ProfileAvatar(
                      localFile: _localPhoto,
                      name: _name.text,
                      size: 100,
                      onTap: _saving ? null : _pickPhoto,
                    ),
                  ),
                  8.height,
                  Center(
                    child: AppConstant.profilePhotoLabel.toText(
                      fontSize: 12,
                      color: AppColors.softGray,
                    ),
                  ),
                  20.height,
                  _field(
                    AppConstant.fullNameLabel,
                    _EditBox(
                      controller: _name,
                      hint: AppConstant.nameHint,
                      enabled: !_saving,
                    ),
                  ),
                  14.height,
                  _field(
                    AppConstant.emailAddressLabel,
                    _EditBox(
                      controller: _email,
                      hint: AppConstant.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_saving,
                    ),
                  ),
                  14.height,
                  _field(
                    AppConstant.phoneNumberLabel,
                    PhoneCountryField(
                      key: _phoneKey,
                      controller: _phone,
                      initialDialCode: _phoneDial,
                      initialCountryCode: _phoneCountry,
                      showLabel: false,
                      onCountryChanged: () {
                        _phoneDial = _phoneKey.currentState?.dialCode ?? _phoneDial;
                      },
                    ),
                  ),
                  14.height,
                  _field(
                    AppConstant.whatsAppNumberLabel,
                    PhoneCountryField(
                      key: _whatsAppKey,
                      controller: _whatsApp,
                      initialDialCode: _waDial,
                      initialCountryCode: _waCountry,
                      showLabel: false,
                      onCountryChanged: () {
                        _waDial = _whatsAppKey.currentState?.dialCode ?? _waDial;
                      },
                    ),
                  ),
                  14.height,
                  _field(
                    AppConstant.personalNoteLabel,
                    _EditBox(
                      controller: _note,
                      hint: AppConstant.optionalHint,
                      maxLines: 4,
                      enabled: !_saving,
                    ),
                  ),
                  24.height,
                  PrimaryButton(
                    buttonName: AppConstant.sendInvitation,
                    isLoading: _saving,
                    radius: AppStyle.radiusMd,
                    onPressed: _saving ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.toText(
          fontSize: 13,
          fontWeight: AppStyle.w500,
          color: AppColors.softGray,
        ),
        8.height,
        child,
      ],
    );
  }
}

class _EditBox extends StatelessWidget {
  const _EditBox({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: keyboardType,
      cursorColor: AppColors.gold,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: TextStyle(
        fontSize: 16,
        color: AppColors.white,
        fontFamily: AppStyle.fontFamily,
        fontFamilyFallback: AppStyle.fontFamilyFallback,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.softGrayDim,
          fontFamily: AppStyle.fontFamily,
          fontFamilyFallback: AppStyle.fontFamilyFallback,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
