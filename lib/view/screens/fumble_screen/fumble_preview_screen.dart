import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/fumble_preview.dart';
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
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

class FumblePreviewScreen extends ConsumerStatefulWidget {
  const FumblePreviewScreen({super.key});

  @override
  ConsumerState<FumblePreviewScreen> createState() =>
      _FumblePreviewScreenState();
}

class _FumblePreviewScreenState extends ConsumerState<FumblePreviewScreen> {
  final _note = TextEditingController();
  StreamSubscription<bool>? _connectivitySub;
  var _online = ConnectionManager().isConnected;
  var _hasNote = false;

  @override
  void initState() {
    super.initState();
    _note.addListener(_onNoteChanged);
    _connectivitySub = ConnectionManager().connectionStream.listen((online) {
      if (!mounted || _online == online) return;
      setState(() => _online = online);
    });
  }

  void _onNoteChanged() {
    final hasNote = _note.text.trim().isNotEmpty;
    if (hasNote == _hasNote) return;
    setState(() => _hasNote = hasNote);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _note.removeListener(_onNoteChanged);
    _note.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final fumble = ref.watch(fumbleNotifierProvider);
    final actions = ref.read(fumbleNotifierProvider.notifier);
    final preview = fumble.preview;

    if (preview == null) {
      return BaseScreenWidget(
        builder: (context) => ScaffoldContent(
          body: Center(
            child: PrimaryButton(
              buttonName: AppConstant.done,
              onPressed: actions.cancel,
            ),
          ),
        ),
      );
    }

    final phoneText = preview.phone?.trim() ?? '';
    final emailText = preview.email?.trim() ?? '';
    final bioText = _online ? (preview.bio?.trim() ?? '') : '';
    final aboutText = _online ? (preview.aboutMe?.trim() ?? '') : '';
    final locationText = _online ? (preview.location?.trim() ?? '') : '';
    final memberSince = _online && preview.createdAt != null
        ? DateFormat('MMMM yyyy').format(preview.createdAt!)
        : null;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.brand,
          brandTitle: true,
          showBack: true,
          onBack: actions.cancel,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _PreviewHeader(
                      preview: preview,
                      online: _online,
                      bioText: bioText,
                      phoneText: phoneText,
                      emailText: emailText,
                      onCall: () => _call(preview.phone),
                      onText: () => _text(preview.phone),
                    ),
                    if (_online) ...[
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
                    ] else ...[
                      24.height,
                    ],
                    ProfileInfoCard(
                      title: AppConstant.noteLabel,
                      body: AppConstant.addNote,
                      placeholder: true,
                      editor: TextField(
                        controller: _note,
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
                    if (memberSince != null) ...[
                      20.height,
                      AppConstant.memberSinceLabel(memberSince).toText(
                        fontSize: 12,
                        fontWeight: AppStyle.w500,
                        color: AppColors.tertiaryText,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    40.height,
                  ],
                ),
              ),
            ),
            if (_hasNote)
              Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 24.h),
                child: PrimaryButton(
                  buttonName: AppConstant.done,
                  isLoading: fumble.isConfirming,
                  onPressed: () => actions.confirm(note: _note.text),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.preview,
    required this.online,
    required this.bioText,
    required this.phoneText,
    required this.emailText,
    required this.onCall,
    required this.onText,
  });

  final FumblePreview preview;
  final bool online;
  final String bioText;
  final String phoneText;
  final String emailText;
  final VoidCallback onCall;
  final VoidCallback onText;

  @override
  Widget build(BuildContext context) {
    final displayName = preview.firstName.isNotEmpty
        ? preview.firstName
        : preview.name;

    return Column(
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
          photoUrl: online ? preview.photoUrl : null,
          name: preview.name,
          size: 120,
        ),
        16.height,
        preview.name.toText(
          fontSize: 28,
          fontWeight: AppStyle.w700,
          textAlign: TextAlign.center,
        ),
        if (online && bioText.isNotEmpty) ...[
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
          fontWeight: phoneText.isNotEmpty ? AppStyle.w600 : AppStyle.w500,
          color: phoneText.isNotEmpty ? AppColors.white : AppColors.softGrayDim,
          textAlign: TextAlign.center,
        ),
        10.height,
        (emailText.isNotEmpty ? emailText : 'No email').toText(
          fontSize: 16,
          fontWeight: emailText.isNotEmpty ? AppStyle.w600 : AppStyle.w500,
          color: emailText.isNotEmpty ? AppColors.white : AppColors.softGrayDim,
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
      ],
    );
  }
}
