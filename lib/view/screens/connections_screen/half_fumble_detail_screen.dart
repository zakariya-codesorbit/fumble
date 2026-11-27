import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/half_fumble.dart';
import 'package:fumble/data/repositories/half_fumble_repository.dart';
import 'package:fumble/services/half_fumble/half_fumble_invite_share.dart';
import 'package:fumble/services/speech/voice_memory_service.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/connections_screen/components/connection_ai_group_card.dart';
import 'package:fumble/view/screens/connections_screen/components/connection_ai_hero_image.dart';
import 'package:fumble/view/screens/connections_screen/components/connection_detail_actions.dart';
import 'package:fumble/view/screens/fumble_screen/components/fumble_preview_actions.dart';
import 'package:fumble/view/screens/fumble_screen/components/fumble_preview_moment_card.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/ai_coins_badge.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/profile_actions.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/app_error_state.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/profile/profile_card.dart';

class HalfFumbleDetailScreen extends ConsumerStatefulWidget {
  const HalfFumbleDetailScreen({super.key, required this.halfFumbleId});

  final String halfFumbleId;

  @override
  ConsumerState<HalfFumbleDetailScreen> createState() =>
      _HalfFumbleDetailScreenState();
}

class _HalfFumbleDetailScreenState
    extends ConsumerState<HalfFumbleDetailScreen> {
  final _note = TextEditingController();
  final _location = TextEditingController();
  final _aiPrompt = TextEditingController();
  VoiceMemoryService? _voice;
  var _initializedNote = false;
  var _locationSeeded = false;
  var _seedingControllers = false;
  var _saving = false;
  var _sendingInvite = false;
  var _editingLocation = false;
  var _listening = false;
  var _aiTab = ConnectionAiTab.record;

  @override
  void initState() {
    super.initState();
    _voice = ref.read(voiceMemoryServiceProvider);
    _note.addListener(_onEdited);
    _location.addListener(_onEdited);
  }

  @override
  void dispose() {
    _note.removeListener(_onEdited);
    _location.removeListener(_onEdited);
    unawaited(_voice?.stop());
    _note.dispose();
    _location.dispose();
    _aiPrompt.dispose();
    super.dispose();
  }

  void _onEdited() {
    if (!mounted || _seedingControllers) return;
    setState(() {});
  }

  void _ensureSeeded(HalfFumble half) {
    _seedingControllers = true;
    try {
      if (!_initializedNote) {
        _note.text = half.personalNote?.trim() ?? '';
        _initializedNote = true;
      }
      if (!_locationSeeded) {
        final place = half.meetingLocation?.trim() ?? '';
        if (place.isNotEmpty) {
          _location.text = place;
        }
        _locationSeeded = true;
      }
    } finally {
      _seedingControllers = false;
    }
  }

  Future<void> _toggleVoiceMemory() async {
    final voice = _voice;
    if (voice == null) return;
    final listening = await FumblePreviewActions.toggleVoiceMemory(
      context: context,
      ref: ref,
      noteController: _note,
      onChanged: () {
        if (!mounted) return;
        setState(() => _listening = voice.isListening);
      },
    );
    if (!mounted) return;
    setState(() => _listening = listening);
  }

  Future<void> _onSave(HalfFumble half) async {
    if (_saving) return;
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(halfFumbleRepositoryProvider).updateDetails(
            ownerUid: uid,
            halfFumbleId: half.id,
            personalNote: _note.text,
            meetingLocation: _location.text,
          );
      if (!mounted) return;
      pop();
    } on HalfFumbleException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppToast(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppToast(AppConstant.somethingWrong, isError: true);
    }
  }

  Future<void> _sendInvite(HalfFumble half) async {
    if (_sendingInvite || !half.status.canResend) return;
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile == null) return;
    setState(() => _sendingInvite = true);
    try {
      final shared = await ref
          .read(halfFumbleRepositoryProvider)
          .resendInvitation(inviter: profile, halfFumble: half);
      if (!mounted) return;
      await HalfFumbleInviteShare.present(
        context: context,
        invitedEmail: shared.invitedEmail,
        storeUrl: shared.storeUrl,
        appLink: shared.appLink,
        phone: half.phone,
        whatsApp: half.whatsApp,
      );
      if (!mounted) return;
      showAppToast(AppConstant.halfFumbleInviteShared);
    } on HalfFumbleException catch (e) {
      showAppToast(e.message, isError: true);
    } catch (_) {
      showAppToast(AppConstant.somethingWrong, isError: true);
    } finally {
      if (mounted) setState(() => _sendingInvite = false);
    }
  }

  void _aiComingSoon() => showAppToast(AppConstant.aiComingSoon);

  @override
  Widget build(BuildContext context) {
    final halfAsync = ref.watch(halfFumblesProvider);
    final aiCoins =
        ref.watch(currentUserProfileProvider).valueOrNull?.aiCoins ?? 0;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.brand,
          brandTitle: true,
          showBack: true,
          onBack: (_saving || _sendingInvite) ? null : pop,
          actions: [
            AiCoinsBadge(
              count: aiCoins,
              onTap: ProfileActions.showAiImageComingSoon,
            ),
          ],
        ),
        body: halfAsync.when(
          loading: () => const AppLoader(),
          error: (e, _) =>
              AppErrorState(onRetry: () => ref.invalidate(halfFumblesProvider)),
          data: (halfFumbles) {
            HalfFumble? match;
            for (final h in halfFumbles) {
              if (h.id == widget.halfFumbleId) {
                match = h;
                break;
              }
            }
            if (match == null) {
              return Center(
                child: AppConstant.connectionsEmptyTitle.toText(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              );
            }
            final half = match;
            _ensureSeeded(half);

            final noteDirty =
                _note.text.trim() != (half.personalNote?.trim() ?? '');
            final savedPlace = half.meetingLocation?.trim() ?? '';
            final currentPlace = _location.text.trim();
            final placeDirty =
                currentPlace != savedPlace &&
                currentPlace != AppConstant.enterFumbleLocation;
            final dirty = noteDirty || placeDirty;
            final displayName =
                half.firstName.isNotEmpty ? half.firstName : half.name;
            final statusLabel =
                AppConstant.halfFumbled(displayName).toUpperCase();
            final moment = half.meetingDate ?? half.createdAt;
            final dateLabel = DateFormat('d MMMM yyyy').format(moment);
            final timeLabel = DateFormat('HH:mm').format(moment);
            final hasLocation = _location.text.trim().isNotEmpty;
            final locationLabel = hasLocation
                ? _location.text.trim()
                : AppConstant.enterFumbleLocation;
            final hasWhatsApp = half.whatsApp.trim().isNotEmpty;
            final phone =
                half.phone.trim().isNotEmpty ? half.phone.trim() : null;
            final whatsApp = hasWhatsApp ? half.whatsApp.trim() : phone;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        8.height,
                        ConnectionAiHeroImage(onTap: _aiComingSoon),
                        16.height,
                        ProfileCardHeader(
                          name: half.name,
                          eyebrow: statusLabel,
                          photoUrl: half.photoUrl,
                          bio: null,
                          phone: phone,
                          hideBioWhenEmpty: true,
                          showEmail: false,
                          showWhatsAppIcon: hasWhatsApp,
                          emptyPhoneLabel: 'No phone number',
                          topSpacing: 0,
                          onCall: () => ConnectionDetailActions.call(phone),
                          onText: () => ConnectionDetailActions.text(phone),
                          onWhatsApp: () =>
                              ConnectionDetailActions.whatsApp(whatsApp),
                        ),
                        if (half.status.canResend) ...[
                          16.height,
                          _SendFumbleInviteButton(
                            isLoading: _sendingInvite,
                            onPressed: _saving
                                ? null
                                : () => _sendInvite(half),
                          ),
                        ],
                        24.height,
                        if (_editingLocation)
                          _LocationEditor(
                            controller: _location,
                            enabled: !_saving,
                            onDone: () =>
                                setState(() => _editingLocation = false),
                          )
                        else
                          FumblePreviewMomentCard(
                            dateLabel: dateLabel,
                            timeLabel: timeLabel,
                            locationLabel: locationLabel,
                            locationPlaceholder: !hasLocation,
                            onLocationTap: _saving
                                ? null
                                : () =>
                                    setState(() => _editingLocation = true),
                          ),
                        16.height,
                        ConnectionAiGroupCard(
                          tab: _aiTab,
                          onTabChanged: (tab) => setState(() => _aiTab = tab),
                          noteController: _note,
                          promptController: _aiPrompt,
                          isListening: _listening,
                          noteEnabled: !_saving && !_listening,
                          showVideoTab: false,
                          aiImageAsset: AppIcons.aiPlaceholder,
                          onRecordTap: _saving ? null : _toggleVoiceMemory,
                          onGenerateTap: _aiComingSoon,
                          onEditTap: () =>
                              setState(() => _aiTab = ConnectionAiTab.record),
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
                      onPressed: _saving ? null : () => _onSave(half),
                      isLoading: _saving,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SendFumbleInviteButton extends StatelessWidget {
  const _SendFumbleInviteButton({
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.surfaceElevated,
          foregroundColor: AppColors.onPrimary,
          disabledForegroundColor: AppColors.textDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyle.radiusPill),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.h,
                height: 22.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(AppIcons.send, size: 18),
                  10.width,
                  AppConstant.sendFumbleInvite.toText(
                    color: AppColors.onPrimary,
                    fontSize: 14,
                    fontWeight: AppStyle.w700,
                    letterSpacing: 0.8,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        autofocus: true,
        cursorColor: AppColors.primary,
        onSubmitted: (_) => onDone(),
        onTapOutside: (_) => onDone(),
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontFamily: AppStyle.fontFamily,
          fontFamilyFallback: AppStyle.fontFamilyFallback,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          hintText: AppConstant.enterFumbleLocation,
          hintStyle: TextStyle(
            fontSize: 14,
            color: AppColors.textDisabled,
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
