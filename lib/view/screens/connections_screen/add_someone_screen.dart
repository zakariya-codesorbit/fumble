import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/repositories/half_fumble_repository.dart';
import 'package:fumble/services/half_fumble/half_fumble_invite_share.dart';
import 'package:fumble/services/location/fumble_location_service.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/my_fumble_group_card.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/dialogs/loading_dialog.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import 'package:fumble/view/widgets/inputs/phone_country_field.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';

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

  var _saving = false;

  @override
  void initState() {
    super.initState();
    final device = PhoneCountryField.fromDeviceLocale();
    _phoneDial = device.dialCode;
    _phoneCountry = device.countryCode;
    _waDial = device.dialCode;
    _waCountry = device.countryCode;
    _name.addListener(_onRequiredChanged);
    _email.addListener(_onRequiredChanged);
  }

  void _onRequiredChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _name.removeListener(_onRequiredChanged);
    _email.removeListener(_onRequiredChanged);
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _whatsApp.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _name.text.trim().isNotEmpty && _email.text.trim().isNotEmpty;
  }

  String _fullPhone(GlobalKey<PhoneCountryFieldState> key, String dial) {
    final national =
        key == _phoneKey ? _phone.text.trim() : _whatsApp.text.trim();
    if (national.isEmpty) return '';
    return key.currentState?.fullNumber ??
        PhoneCountryField.formatFull(dialCode: dial, national: national);
  }

  Future<String?> _currentMeetingLocation() async {
    if (!mounted) return null;
    final coords = await FumbleLocationService.capture(context);
    if (coords == null) return null;
    return FumbleLocationService.placeLabel(coords);
  }

  static bool _isValidInviteEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool _validateBeforeSubmit() {
    final name = _name.text.trim();
    final email = _email.text.trim();

    if (name.isEmpty) {
      showAppToast(AppConstant.inviteeNameRequired, isError: true);
      return false;
    }
    if (email.isEmpty) {
      showAppToast(AppConstant.inviteeEmailRequired, isError: true);
      return false;
    }
    if (!_isValidInviteEmail(email)) {
      showAppToast(AppConstant.inviteeEmailInvalid, isError: true);
      return false;
    }

    final phoneNational = _phone.text.trim();
    if (phoneNational.isNotEmpty &&
        !PhoneCountryField.isValidNational(phoneNational)) {
      showAppToast(AppConstant.phoneInvalid, isError: true);
      return false;
    }

    final waNational = _whatsApp.text.trim();
    if (waNational.isNotEmpty &&
        !PhoneCountryField.isValidNational(waNational)) {
      showAppToast(AppConstant.phoneInvalid, isError: true);
      return false;
    }

    return true;
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!_validateBeforeSubmit()) return;

    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile == null) {
      showAppToast(AppConstant.authPleaseLogIn, isError: true);
      return;
    }

    final phone = _fullPhone(_phoneKey, _phoneDial);
    final whatsApp = _fullPhone(_whatsAppKey, _waDial);

    setState(() => _saving = true);
    showLoadingDialog(message: AppConstant.loading);
    var dialogOpen = true;
    try {
      final meetingLocation = await _currentMeetingLocation();
      final result =
          await ref.read(halfFumbleRepositoryProvider).createAndInvite(
                inviter: profile,
                name: _name.text,
                email: _email.text,
                phone: phone,
                whatsApp: whatsApp,
                meetingLocation: meetingLocation,
                meetingDate: DateTime.now(),
                personalNote: _note.text,
              );

      // Dismiss before share UI so we don't pop this screen later.
      hideLoadingDialog();
      dialogOpen = false;

      if (!mounted) return;
      await HalfFumbleInviteShare.present(
        context: context,
        invitedEmail: result.invitedEmail,
        storeUrl: result.storeUrl,
        appLink: result.appLink,
        phone: phone,
        whatsApp: whatsApp,
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
      if (dialogOpen) hideLoadingDialog();
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canFumble = _canSubmit && !_saving;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppConstant.addSomeoneSubtitle.toText(
                  fontSize: 14,
                  fontWeight: AppStyle.w500,
                  color: AppColors.textPrimary,
                  maxLine: 4,
                  lineHeight: 1.4,
                ),
                16.height,
                MyFumbleGroupCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            _phoneDial =
                                _phoneKey.currentState?.dialCode ?? _phoneDial;
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
                            _waDial =
                                _whatsAppKey.currentState?.dialCode ?? _waDial;
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
                        buttonName: AppConstant.halfFumbleCta,
                        radius: AppStyle.radiusMd,
                        onPressed: canFumble ? _submit : null,
                      ),
                    ],
                  ),
                ),
              ],
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
          color: AppColors.textSecondary,
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
      cursorColor: AppColors.primary,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
        fontFamily: AppStyle.fontFamily,
        fontFamilyFallback: AppStyle.fontFamilyFallback,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textDisabled,
          fontFamily: AppStyle.fontFamily,
          fontFamilyFallback: AppStyle.fontFamilyFallback,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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
