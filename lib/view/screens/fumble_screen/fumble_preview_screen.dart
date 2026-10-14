import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/services/network/connection_manager.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/fumble_screen/components/fumble_preview_actions.dart';
import 'package:fumble/view/screens/fumble_screen/components/fumble_preview_memory_note.dart';
import 'package:fumble/view/screens/fumble_screen/components/fumble_preview_moment_card.dart';
import 'package:fumble/view/screens/fumble_screen/components/fumble_preview_record_memory.dart';
import 'package:fumble/view/screens/fumble_screen/components/fumble_preview_remember_prompt.dart';
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
  final _location = TextEditingController();
  final _momentAt = DateTime.now();
  StreamSubscription<bool>? _connectivitySub;
  var _online = ConnectionManager().isConnected;
  var _hasNote = false;
  var _editingLocation = false;
  var _locationSeeded = false;

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
      _seedLocationFromPreview();
    });
  }

  void _seedLocationFromPreview() {
    if (_locationSeeded) return;
    final place =
        ref.read(fumbleNotifierProvider).preview?.location?.trim() ?? '';
    if (place.isEmpty) return;
    _location.text = place;
    _locationSeeded = true;
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
    _location.dispose();
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

    ref.listen(fumbleNotifierProvider, (previous, next) {
      final place = next.preview?.location?.trim() ?? '';
      if (_locationSeeded || place.isEmpty) return;
      _location.text = place;
      _locationSeeded = true;
    });

    final showDetails = _online && preview.enriched;
    final showShimmer = _online && fumble.isLoadingPreview && !preview.enriched;
    final displayName = preview.firstName.isNotEmpty
        ? preview.firstName
        : preview.name;
    final dateLabel = DateFormat('d MMMM yyyy').format(_momentAt);
    final timeLabel = DateFormat('HH:mm').format(_momentAt);
    final locationLabel = _location.text.trim().isNotEmpty
        ? _location.text.trim()
        : AppConstant.nearExchangeLocation;

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
                      eyebrow: AppConstant.youFumbled(
                        displayName,
                      ).toUpperCase(),
                      photoUrl: showDetails ? preview.photoUrl : null,
                      bio: showDetails ? preview.bio : null,
                      phone: showDetails ? preview.phone : null,
                      hideBioWhenEmpty: true,
                      showEmail: false,
                      showContact: showDetails || showShimmer,
                      showActions: showDetails || showShimmer,
                      avatarLoading: showShimmer,
                      contactLoading: showShimmer,
                      emptyPhoneLabel: 'No phone number',
                      topSpacing: 8,
                      onCall: () => FumblePreviewActions.call(preview.phone),
                      onText: () => FumblePreviewActions.text(preview.phone),
                    ),
                    24.height,
                    if (_editingLocation)
                      _LocationEditor(
                        controller: _location,
                        enabled: !fumble.isSavingNote,
                        onDone: () => setState(() => _editingLocation = false),
                      )
                    else
                      FumblePreviewMomentCard(
                        dateLabel: dateLabel,
                        timeLabel: timeLabel,
                        locationLabel: locationLabel,
                        onLocationTap: fumble.isSavingNote
                            ? null
                            : () => setState(() => _editingLocation = true),
                      ),
                    16.height,
                    FumblePreviewRememberPrompt(
                      message: AppConstant.youFumbledJustNow(displayName),
                    ),
                    16.height,
                    FumblePreviewRecordMemory(
                      onTap: fumble.isSavingNote
                          ? null
                          : FumblePreviewActions.recordMemory,
                    ),
                    16.height,
                    FumblePreviewMemoryNote(
                      controller: _note,
                      enabled: !fumble.isSavingNote,
                    ),
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

class _LocationEditor extends StatelessWidget {
  const _LocationEditor({
    required this.controller,
    required this.enabled,
    required this.onDone,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.navBar,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        autofocus: true,
        cursorColor: AppColors.gold,
        onSubmitted: (_) => onDone(),
        onTapOutside: (_) => onDone(),
        style: TextStyle(
          fontSize: 14,
          color: AppColors.softGray,
          fontFamily: AppStyle.fontFamily,
          fontFamilyFallback: AppStyle.fontFamilyFallback,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          hintText: AppConstant.nearExchangeLocation,
          hintStyle: TextStyle(
            fontSize: 14,
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
    );
  }
}
