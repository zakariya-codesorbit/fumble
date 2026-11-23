import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/core/navigation/navigator_keys.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/my_fumble_edit_card.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/my_fumble_identity_card.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/profile_actions.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/app_error_state.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/inputs/phone_country_field.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';

class MyFumbleScreen extends ConsumerWidget {
  const MyFumbleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.brand,
          brandTitle: true,
          leading: IconButton(
            icon: const Icon(AppIcons.settings, color: AppColors.warmGray),
            onPressed: ProfileActions.openSettings,
          ),
        ),
        body: profileAsync.when(
          loading: () => const AppLoader(),
          error: (e, _) => AppErrorState(
            onRetry: () => ProfileActions.retryLoad(ref),
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

class _ProfileBodyState extends ConsumerState<_ProfileBody> with RouteAware {
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _phone;
  late final TextEditingController _whatsApp;
  final _phoneFieldKey = GlobalKey<PhoneCountryFieldState>();
  final _whatsAppFieldKey = GlobalKey<PhoneCountryFieldState>();
  late String _phoneDialCode;
  late String _phoneCountryCode;
  late String _whatsAppDialCode;
  late String _whatsAppCountryCode;

  @override
  void initState() {
    super.initState();
    _bindControllers(widget.profile);
  }

  @override
  void didUpdateWidget(covariant _ProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.phone != widget.profile.phone) {
      _syncPhoneFromProfile(widget.profile);
    }
    if (oldWidget.profile.whatsApp != widget.profile.whatsApp) {
      _syncWhatsAppFromProfile(widget.profile);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _name.dispose();
    _bio.dispose();
    _phone.dispose();
    _whatsApp.dispose();
    super.dispose();
  }

  @override
  void didPushNext() => _discardDraft();

  @override
  void didPopNext() => _discardDraft();

  void _bindControllers(UserProfile profile) {
    _name = TextEditingController(text: profile.name);
    _bio = TextEditingController(text: profile.bio ?? '');
    _whatsApp = TextEditingController();
    _phone = TextEditingController();
    _syncPhoneFromProfile(profile);
    _syncWhatsAppFromProfile(profile);
  }

  void _syncPhoneFromProfile(UserProfile profile) {
    final parsed = PhoneCountryField.parseStored(profile.phone);
    _phoneDialCode = parsed.dialCode;
    _phoneCountryCode = parsed.countryCode;
    _phone.text = parsed.national;
    _phoneFieldKey.currentState?.applyCountry(
      countryCode: parsed.countryCode,
      dialCode: parsed.dialCode,
    );
  }

  void _syncWhatsAppFromProfile(UserProfile profile) {
    final parsed = PhoneCountryField.parseStored(profile.whatsApp);
    _whatsAppDialCode = parsed.dialCode;
    _whatsAppCountryCode = parsed.countryCode;
    _whatsApp.text = parsed.national;
    _whatsAppFieldKey.currentState?.applyCountry(
      countryCode: parsed.countryCode,
      dialCode: parsed.dialCode,
    );
  }

  String _fullPhone() {
    final national = _phone.text.trim();
    if (national.isEmpty) return '';
    return _phoneFieldKey.currentState?.fullNumber ??
        PhoneCountryField.formatFull(
          dialCode: _phoneDialCode,
          national: national,
        );
  }

  String _fullWhatsApp() {
    final national = _whatsApp.text.trim();
    if (national.isEmpty) return '';
    return _whatsAppFieldKey.currentState?.fullNumber ??
        PhoneCountryField.formatFull(
          dialCode: _whatsAppDialCode,
          national: national,
        );
  }

  void _applyProfile(UserProfile profile) {
    _name.text = profile.name;
    _bio.text = profile.bio ?? '';
    _syncPhoneFromProfile(profile);
    _syncWhatsAppFromProfile(profile);
  }

  void _discardDraft() {
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    _applyProfile(widget.profile);
    ProfileActions.resetEdit(ref);
    setState(() {});
  }

  bool get _textChanged {
    final profile = widget.profile;
    final savedPhone = (profile.phone ?? '').trim();
    final savedWhatsApp = (profile.whatsApp ?? '').trim();
    return _name.text.trim() != profile.name.trim() ||
        _bio.text.trim() != (profile.bio ?? '').trim() ||
        _fullWhatsApp() != savedWhatsApp ||
        _fullPhone() != savedPhone;
  }

  Future<void> _save() async {
    final profile = widget.profile;
    final ok = await ProfileActions.save(
      ref: ref,
      profile: profile,
      name: _name.text,
      bio: _bio.text,
      aboutMe: profile.aboutMe ?? '',
      location: profile.location ?? '',
      phone: _fullPhone(),
      nationalPhone: _phone.text,
      whatsApp: _fullWhatsApp(),
      nationalWhatsApp: _whatsApp.text,
    );
    if (!mounted || !ok) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(bottomNavProvider, (previous, next) {
      final wasMine = previous?.index == AppNavIndex.myfumble;
      final isMine = next.index == AppNavIndex.myfumble;
      if (wasMine != isMine) _discardDraft();
    });

    final profile = widget.profile;
    final edit = ref.watch(profileNotifierProvider);
    final photoChanged =
        edit.localPhoto != null || edit.avatarAsset != null || edit.removePhoto;
    final canSave = _textChanged || photoChanged;
    final memberSince = profile.createdAt != null
        ? DateFormat('MMMM yyyy').format(profile.createdAt!)
        : null;
    final displayPhone =
        _fullPhone().isNotEmpty ? _fullPhone() : profile.phone;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Center(
            child: AppConstant.yourIdentity.toText(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: AppStyle.w600,
              letterSpacing: 1.4,
              textAlign: TextAlign.center,
            ),
          ),
          6.height,
          Center(
            child: AppConstant.myFumbleTitle.toText(
              fontSize: 28,
              fontWeight: AppStyle.w700,
              color: AppColors.white,
              textAlign: TextAlign.center,
            ),
          ),
          20.height,
          MyFumbleIdentityCard(
            name: _name.text.trim().isEmpty ? profile.name : _name.text.trim(),
            bio: _bio.text,
            phone: displayPhone,
            email: profile.email,
            photoUrl: edit.displayPhotoUrl(profile),
            localFile: edit.localPhoto,
            avatarAsset: edit.avatarAsset,
            onPhotoTap: () => ProfileActions.showPhotoSheet(
              context: context,
              ref: ref,
            ),
          ),
          20.height,
          MyFumbleEditCard(
            nameController: _name,
            phoneController: _phone,
            phoneFieldKey: _phoneFieldKey,
            phoneDialCode: _phoneDialCode,
            phoneCountryCode: _phoneCountryCode,
            whatsAppController: _whatsApp,
            whatsAppFieldKey: _whatsAppFieldKey,
            whatsAppDialCode: _whatsAppDialCode,
            whatsAppCountryCode: _whatsAppCountryCode,
            bioController: _bio,
            onPhoneChanged: (_) => setState(() {}),
            onPhoneCountryChanged: () {
              final state = _phoneFieldKey.currentState;
              if (state != null) {
                _phoneDialCode = state.dialCode;
              }
              setState(() {});
            },
            onWhatsAppChanged: (_) => setState(() {}),
            onWhatsAppCountryChanged: () {
              final state = _whatsAppFieldKey.currentState;
              if (state != null) {
                _whatsAppDialCode = state.dialCode;
              }
              setState(() {});
            },
            onChanged: () => setState(() {}),
            onChoosePhoto: () => ProfileActions.showPhotoSheet(
              context: context,
              ref: ref,
            ),
            onSave: canSave && !edit.isSaving ? _save : null,
            isSaving: edit.isSaving,
            localPhoto: edit.localPhoto,
            avatarAsset: edit.avatarAsset,
            hasExistingPhoto: profile.hasPhoto && !edit.removePhoto,
          ),
          if (memberSince != null) ...[
            20.height,
            Center(
              child: AppConstant.memberSinceLabel(memberSince).toText(
                fontSize: 12,
                fontWeight: AppStyle.w500,
                color: AppColors.tertiaryText,
                textAlign: TextAlign.center,
              ),
            ),
          ],
          ],
        ),
      ),
    );
  }
}
