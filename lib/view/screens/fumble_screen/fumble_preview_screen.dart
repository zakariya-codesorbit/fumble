import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fumble/services/network/connection_manager.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/fumble_screen/components/fumble_preview_actions.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/profile/profile_card.dart';

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
      if (online) unawaited(FumblePreviewActions.loadDetails(ref));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(FumblePreviewActions.loadDetails(ref));
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

  @override
  Widget build(BuildContext context) {
    final fumble = ref.watch(fumbleNotifierProvider);
    final preview = fumble.preview;

    if (preview == null) {
      return BaseScreenWidget(
        builder: (context) => ScaffoldContent(
          body: Center(
            child: PrimaryButton(
              buttonName: AppConstant.done,
              onPressed: () => FumblePreviewActions.cancel(ref),
            ),
          ),
        ),
      );
    }

    final showDetails = _online && preview.enriched;
    final showShimmer =
        _online && fumble.isLoadingPreview && !preview.enriched;
    final displayName =
        preview.firstName.isNotEmpty ? preview.firstName : preview.name;
    final memberSince = showDetails && preview.createdAt != null
        ? DateFormat('MMMM yyyy').format(preview.createdAt!)
        : null;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.brand,
          brandTitle: true,
          showBack: true,
          onBack: fumble.isSavingNote
              ? null
              : () => FumblePreviewActions.cancel(ref),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ProfileCardHeader(
                      name: preview.name,
                      eyebrow: AppConstant.youFumbled(displayName),
                      photoUrl: showDetails ? preview.photoUrl : null,
                      bio: showDetails ? preview.bio : null,
                      phone: showDetails ? preview.phone : null,
                      email: showDetails ? preview.email : null,
                      hideBioWhenEmpty: true,
                      showContact: showDetails || showShimmer,
                      showActions: showDetails || showShimmer,
                      avatarLoading: showShimmer,
                      contactLoading: showShimmer,
                      emptyPhoneLabel: 'No phone number',
                      topSpacing: 16,
                      onCall: () => FumblePreviewActions.call(preview.phone),
                      onText: () => FumblePreviewActions.text(preview.phone),
                    ),
                    ProfileCardSections(
                      showDivider: showDetails || showShimmer,
                      loading: showShimmer,
                      aboutMe: showDetails
                          ? ProfileCardSection(
                              body: preview.aboutMe?.trim() ?? '',
                              emptyBody: AppConstant.addAboutMe,
                            )
                          : const ProfileCardSection(visible: false),
                      location: showDetails
                          ? ProfileCardSection(
                              body: preview.location?.trim() ?? '',
                              emptyBody: AppConstant.addLocation,
                            )
                          : const ProfileCardSection(visible: false),
                      noteController: _note,
                      noteEnabled: !fumble.isSavingNote,
                      footerLabel: memberSince != null
                          ? AppConstant.memberSinceLabel(memberSince)
                          : null,
                    ),
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
                      : () => FumblePreviewActions.saveNoteAndFinish(
                            ref: ref,
                            note: _note.text,
                          ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
