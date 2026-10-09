import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
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
      if (!mounted) return;
      setState(() => _online = online);
      if (online) {
        unawaited(
          ref.read(fumbleNotifierProvider.notifier).loadPreviewDetails(),
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(fumbleNotifierProvider.notifier).loadPreviewDetails(),
      );
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

    final showDetails = _online && preview.enriched;
    final showShimmer =
        _online && fumble.isLoadingPreview && !preview.enriched;
    final phoneText = showDetails ? (preview.phone?.trim() ?? '') : '';
    final emailText = showDetails ? (preview.email?.trim() ?? '') : '';
    final bioText = showDetails ? (preview.bio?.trim() ?? '') : '';
    final aboutText = showDetails ? (preview.aboutMe?.trim() ?? '') : '';
    final locationText = showDetails ? (preview.location?.trim() ?? '') : '';
    final memberSince = showDetails && preview.createdAt != null
        ? DateFormat('MMMM yyyy').format(preview.createdAt!)
        : null;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.brand,
          brandTitle: true,
          showBack: true,
          onBack: fumble.isSavingNote ? null : actions.cancel,
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
                      showDetails: showDetails,
                      showShimmer: showShimmer,
                      bioText: bioText,
                      phoneText: phoneText,
                      emailText: emailText,
                      onCall: () => _call(preview.phone),
                      onText: () => _text(preview.phone),
                    ),
                    if (showShimmer) ...[
                      24.height,
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                      ),
                      24.height,
                      const _PreviewShimmerCards(),
                      12.height,
                    ] else if (showDetails) ...[
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
                        enabled: !fumble.isSavingNote,
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
                  onPressed: fumble.isSavingNote
                      ? null
                      : () => actions.saveNoteAndFinish(note: _note.text),
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
    required this.showDetails,
    required this.showShimmer,
    required this.bioText,
    required this.phoneText,
    required this.emailText,
    required this.onCall,
    required this.onText,
  });

  final FumblePreview preview;
  final bool showDetails;
  final bool showShimmer;
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
        if (showShimmer)
          const _ShimmerBox(width: 120, height: 120, radius: 60)
        else
          ProfileAvatar(
            photoUrl: showDetails ? preview.photoUrl : null,
            name: preview.name,
            size: 120,
          ),
        16.height,
        preview.name.toText(
          fontSize: 28,
          fontWeight: AppStyle.w700,
          textAlign: TextAlign.center,
        ),
        if (showShimmer) ...[
          10.height,
          const _ShimmerBox(width: 180, height: 14, radius: 8),
          18.height,
          const _ShimmerBox(width: 140, height: 16, radius: 8),
          10.height,
          const _ShimmerBox(width: 200, height: 16, radius: 8),
          20.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _ShimmerBox(width: 85, height: 38, radius: 99),
              12.width,
              const _ShimmerBox(width: 85, height: 38, radius: 99),
            ],
          ),
        ] else if (showDetails) ...[
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
            fontWeight: phoneText.isNotEmpty ? AppStyle.w600 : AppStyle.w500,
            color:
                phoneText.isNotEmpty ? AppColors.white : AppColors.softGrayDim,
            textAlign: TextAlign.center,
          ),
          10.height,
          (emailText.isNotEmpty ? emailText : 'No email').toText(
            fontSize: 16,
            fontWeight: emailText.isNotEmpty ? AppStyle.w600 : AppStyle.w500,
            color:
                emailText.isNotEmpty ? AppColors.white : AppColors.softGrayDim,
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
      ],
    );
  }
}

class _PreviewShimmerCards extends StatelessWidget {
  const _PreviewShimmerCards();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ShimmerCard(titleWidth: 72, lines: const [1.0, 0.85, 0.55]),
        12.height,
        _ShimmerCard(titleWidth: 88, lines: const [0.7]),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({
    required this.titleWidth,
    required this.lines,
  });

  final double titleWidth;
  final List<double> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.navBar,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBox(width: titleWidth, height: 12, radius: 6),
          12.height,
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) 8.height,
            FractionallySizedBox(
              widthFactor: lines[i],
              child: const _ShimmerBox(
                width: double.infinity,
                height: 14,
                radius: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: AppColors.softGrayDim.withValues(alpha: 0.35),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
