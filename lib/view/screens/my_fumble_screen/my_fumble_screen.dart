import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/navigator_keys.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/profile_header.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/feedback/app_error_state.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
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

class _ProfileBodyState extends ConsumerState<_ProfileBody> with RouteAware {
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late bool _sharePhone;
  late bool _shareEmail;
  String? _active;
  bool _readyToClose = false;

  @override
  void initState() {
    super.initState();
    _bindControllers(widget.profile);
  }

  @override
  void didUpdateWidget(covariant _ProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.sharePhone != widget.profile.sharePhone ||
        oldWidget.profile.shareEmail != widget.profile.shareEmail) {
      _sharePhone = widget.profile.sharePhone;
      _shareEmail = widget.profile.shareEmail;
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
    super.dispose();
  }

  @override
  void didPushNext() => _discardDraft();

  @override
  void didPopNext() => _discardDraft();

  void _bindControllers(UserProfile profile) {
    _name = TextEditingController(text: profile.name);
    _bio = TextEditingController(text: profile.bio ?? '');
    _sharePhone = profile.sharePhone;
    _shareEmail = profile.shareEmail;
  }

  void _applyProfile(UserProfile profile) {
    _name.text = profile.name;
    _bio.text = profile.bio ?? '';
    _sharePhone = profile.sharePhone;
    _shareEmail = profile.shareEmail;
  }

  void _discardDraft() {
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    _applyProfile(widget.profile);
    ref.read(profileNotifierProvider.notifier).resetEdit();
    setState(() {
      _active = null;
      _readyToClose = false;
    });
  }

  bool get _textChanged {
    final profile = widget.profile;
    return _name.text.trim() != profile.name.trim() ||
        _bio.text.trim() != (profile.bio ?? '').trim() ||
        _sharePhone != profile.sharePhone ||
        _shareEmail != profile.shareEmail;
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
    ref.listen(bottomNavProvider, (previous, next) {
      final wasMine = previous?.index == AppNavIndex.myfumble;
      final isMine = next.index == AppNavIndex.myfumble;
      if (wasMine != isMine) _discardDraft();
    });

    final profile = widget.profile;
    final edit = ref.watch(profileNotifierProvider);
    final actions = ref.read(profileNotifierProvider.notifier);
    final photoChanged =
        edit.localPhoto != null || edit.avatarSvg != null || edit.removePhoto;
    final showSave = _textChanged || photoChanged;
    final memberSince = profile.createdAt != null
        ? DateFormat('MMMM yyyy').format(profile.createdAt!)
        : null;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                ProfileHeader(
                  name: profile.name,
                  photoUrl: edit.displayPhotoUrl(profile),
                  localFile: edit.localPhoto,
                  svg: edit.avatarSvg,
                  bio: _bio.text,
                  phone: profile.phone,
                  email: profile.email,
                  sharePhone: _sharePhone,
                  shareEmail: _shareEmail,
                  editingName: _active == 'name',
                  editingBio: _active == 'bio',
                  nameController: _name,
                  bioController: _bio,
                  onNameTap: () => _openField('name'),
                  onNameChanged: (_) => setState(() {}),
                  onNameTapOutside: () => _closeIfStill('name'),
                  onBioTap: () => _openField('bio'),
                  onBioChanged: (_) => setState(() {}),
                  onBioTapOutside: () => _closeIfStill('bio'),
                  onPhotoTap: () => actions.showPhotoSheet(context),
                  onSharePhoneChanged: (value) =>
                      setState(() => _sharePhone = value),
                  onShareEmailChanged: (value) =>
                      setState(() => _shareEmail = value),
                ),
                if (showSave) ...[
                  16.height,
                  PrimaryButton(
                    buttonName: AppConstant.save,
                    isLoading: edit.isSaving,
                    onPressed: () => actions.save(
                      name: _name.text,
                      bio: _bio.text,
                      phone: profile.phone ?? '',
                      sharePhone: _sharePhone,
                      shareEmail: _shareEmail,
                    ),
                  ),
                ],
                24.height,
              ],
            ),
          ),
        ),
        if (memberSince != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: AppConstant.memberSinceLabel(memberSince).toText(
              fontSize: 12,
              fontWeight: AppStyle.w500,
              color: AppColors.tertiaryText,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
