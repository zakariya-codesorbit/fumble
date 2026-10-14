import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/connection.dart';
import 'package:fumble/services/network/connection_manager.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/pill_button.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/profile_info_cards.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/app_error_state.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

class ConnectionDetailScreen extends ConsumerStatefulWidget {
  const ConnectionDetailScreen({super.key, required this.peerUid});

  final String peerUid;

  @override
  ConsumerState<ConnectionDetailScreen> createState() =>
      _ConnectionDetailScreenState();
}

class _ConnectionDetailScreenState
    extends ConsumerState<ConnectionDetailScreen> {
  final _note = TextEditingController();
  StreamSubscription<bool>? _connectivitySub;
  var _initializedNote = false;
  var _saving = false;
  String? _aboutMe;
  String? _locationOverride;

  @override
  void initState() {
    super.initState();
    _note.addListener(_onNoteEdited);
    _connectivitySub = ConnectionManager().connectionStream.listen((online) {
      if (online) unawaited(_loadPublicExtras());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadPublicExtras());
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _note.removeListener(_onNoteEdited);
    _note.dispose();
    super.dispose();
  }

  void _onNoteEdited() {
    // Dirty state is computed against the live connection in build.
    setState(() {});
  }

  Future<void> _loadPublicExtras() async {
    if (!ConnectionManager().isConnected) return;
    final uid = widget.peerUid.trim();
    if (uid.isEmpty) return;
    try {
      final card =
          await ref.read(fumbleCodeRepositoryProvider).loadPublicProfile(uid);
      if (!mounted || card == null) return;
      setState(() {
        _aboutMe = card.aboutMe?.trim();
        final loc = card.location?.trim();
        if (loc != null && loc.isNotEmpty) _locationOverride = loc;
      });
    } catch (_) {
      // Keep local connection fields.
    }
  }

  void _ensureNoteSeeded(Connection connection) {
    if (_initializedNote) return;
    _note.text = connection.note?.trim() ?? '';
    _initializedNote = true;
  }

  Future<void> _call(String? phone) async {
    final value = phone?.trim();
    if (value == null || value.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: value);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _text(String? phone) async {
    final value = phone?.trim();
    if (value == null || value.isEmpty) return;
    final uri = Uri(scheme: 'sms', path: value);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _saveNote(Connection connection) async {
    if (_saving) return;
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) {
      showAppToast(AppConstant.authPleaseLogIn, isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(connectionRepositoryProvider).updateConnectionNote(
            ownerUid: uid,
            peerUid: connection.peerUid,
            note: _note.text,
          );
      if (!mounted) return;
      setState(() => _saving = false);
      pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppToast(AppConstant.somethingWrong, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionsAsync = ref.watch(connectionsProvider);

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.brand,
          brandTitle: true,
          showBack: true,
          onBack: _saving ? null : pop,
        ),
        body: connectionsAsync.when(
          loading: () => const AppLoader(),
          error: (e, _) => AppErrorState(
            onRetry: () => ref.invalidate(connectionsProvider),
          ),
          data: (connections) {
            Connection? match;
            for (final c in connections) {
              if (c.peerUid == widget.peerUid) {
                match = c;
                break;
              }
            }
            if (match == null) {
              return Center(
                child: AppConstant.connectionsEmptyTitle.toText(
                  fontSize: 14,
                  color: AppColors.softGray,
                ),
              );
            }
            final connection = match;

            _ensureNoteSeeded(connection);
            final dirty =
                _note.text.trim() != (connection.note?.trim() ?? '');

            return _DetailBody(
              connection: connection,
              noteController: _note,
              aboutMe: _aboutMe,
              locationText:
                  (_locationOverride ?? connection.location)?.trim() ?? '',
              dirty: dirty,
              saving: _saving,
              onCall: () => _call(connection.visiblePhone),
              onText: () => _text(connection.visiblePhone),
              onDone: () => _saveNote(connection),
            );
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.connection,
    required this.noteController,
    required this.aboutMe,
    required this.locationText,
    required this.dirty,
    required this.saving,
    required this.onCall,
    required this.onText,
    required this.onDone,
  });

  final Connection connection;
  final TextEditingController noteController;
  final String? aboutMe;
  final String locationText;
  final bool dirty;
  final bool saving;
  final VoidCallback onCall;
  final VoidCallback onText;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final phoneText = connection.visiblePhone ?? '';
    final emailText = connection.visibleEmail;
    final bioText = connection.bio?.trim() ?? '';
    final aboutText = aboutMe?.trim() ?? '';
    final displayName = connection.firstName.isNotEmpty
        ? connection.firstName
        : connection.name;
    final fumbledLabel =
        '${AppConstant.fumbledOn} ${DateFormat('MMMM d, yyyy').format(connection.fumbledAt)}';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                16.height,
                AppConstant.youFumbled(displayName).toText(
                  color: AppColors.gold,
                  fontSize: 16,
                  fontWeight: AppStyle.w600,
                  letterSpacing: 1.2,
                  textAlign: TextAlign.center,
                ),
                16.height,
                ProfileAvatar(
                  photoUrl: connection.photoUrl,
                  name: connection.name,
                  size: 120,
                ),
                16.height,
                connection.name.toText(
                  fontSize: 28,
                  fontWeight: AppStyle.w700,
                  textAlign: TextAlign.center,
                ),
                if (bioText.isNotEmpty) ...[
                  6.height,
                  bioText.toText(
                    fontSize: 14,
                    fontWeight: AppStyle.w500,
                    color: AppColors.tertiaryText,
                    textAlign: TextAlign.center,
                    maxLine: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                18.height,
                (phoneText.isNotEmpty ? phoneText : 'No phone number').toText(
                  fontSize: 16,
                  fontWeight:
                      phoneText.isNotEmpty ? AppStyle.w600 : AppStyle.w500,
                  color: phoneText.isNotEmpty
                      ? AppColors.white
                      : AppColors.softGrayDim,
                  textAlign: TextAlign.center,
                ),
                10.height,
                (emailText.isNotEmpty ? emailText : 'No email').toText(
                  fontSize: 16,
                  fontWeight:
                      emailText.isNotEmpty ? AppStyle.w600 : AppStyle.w500,
                  color: emailText.isNotEmpty
                      ? AppColors.white
                      : AppColors.softGrayDim,
                  textAlign: TextAlign.center,
                ),
                20.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PillButton(
                      label: AppConstant.call,
                      icon: AppIcons.phone,
                      filled: true,
                      onTap: onCall,
                    ),
                    12.width,
                    PillButton(
                      label: AppConstant.text,
                      icon: AppIcons.chat,
                      filled: false,
                      onTap: onText,
                    ),
                  ],
                ),
                24.height,
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
                24.height,
                ProfileInfoCard(
                  title: AppConstant.aboutMeLabel,
                  body: aboutText.isNotEmpty
                      ? aboutText
                      : AppConstant.addAboutMe,
                  placeholder: aboutText.isEmpty,
                ),
                12.height,
                ProfileLocationCard(
                  body: locationText.isNotEmpty
                      ? locationText
                      : AppConstant.addLocation,
                  placeholder: locationText.isEmpty,
                ),
                12.height,
                ProfileInfoCard(
                  title: AppConstant.noteLabel,
                  body: AppConstant.addNote,
                  placeholder: true,
                  editor: TextField(
                    controller: noteController,
                    enabled: !saving,
                    maxLines: 4,
                    cursorColor: AppColors.gold,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.secondaryText,
                      fontFamily: AppStyle.fontFamily,
                      fontFamilyFallback: AppStyle.fontFamilyFallback,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: false,
                      hintText: AppConstant.addNote,
                      hintStyle: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.softGrayDim,
                        fontFamily: AppStyle.fontFamily,
                        fontFamilyFallback: AppStyle.fontFamilyFallback,
                      ),
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                20.height,
                fumbledLabel.toText(
                  fontSize: 12,
                  fontWeight: AppStyle.w500,
                  color: AppColors.tertiaryText,
                  textAlign: TextAlign.center,
                ),
                40.height,
              ],
            ),
          ),
        ),
        if (dirty)
          Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 24.h),
            child: PrimaryButton(
              buttonName: AppConstant.done,
              onPressed: saving ? null : onDone,
            ),
          ),
      ],
    );
  }
}
