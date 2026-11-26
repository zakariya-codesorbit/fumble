import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/connection.dart';
import 'package:fumble/services/network/connection_manager.dart';
import 'package:fumble/services/speech/voice_memory_service.dart';
import 'package:fumble/state/providers/app_providers.dart';
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
  final _location = TextEditingController();
  final _aiPrompt = TextEditingController();
  StreamSubscription<bool>? _connectivitySub;
  VoiceMemoryService? _voice;
  var _extrasRequestId = 0;
  var _initializedNote = false;
  var _locationSeeded = false;
  var _seedingControllers = false;
  var _saving = false;
  var _editingLocation = false;
  var _listening = false;
  var _aiTab = ConnectionAiTab.record;

  @override
  void initState() {
    super.initState();
    _voice = ref.read(voiceMemoryServiceProvider);
    _note.addListener(_onNoteEdited);
    _connectivitySub = ConnectionManager().connectionStream.listen((online) {
      if (!mounted || !online) return;
      unawaited(_loadPublicExtras());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_loadPublicExtras());
    });
  }

  @override
  void dispose() {
    _extrasRequestId++;
    _connectivitySub?.cancel();
    _note.removeListener(_onNoteEdited);
    unawaited(_voice?.stop());
    _note.dispose();
    _location.dispose();
    _aiPrompt.dispose();
    super.dispose();
  }

  void _onNoteEdited() {
    if (!mounted || _seedingControllers) return;
    setState(() {});
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

  Future<void> _loadPublicExtras() async {
    if (!mounted) return;
    final requestId = ++_extrasRequestId;
    final extras = await ConnectionDetailActions.loadPublicExtras(
      ref: ref,
      peerUid: widget.peerUid,
    );
    if (!mounted || requestId != _extrasRequestId) return;
    if (extras == null || _locationSeeded) return;
    final place = extras.location?.trim() ?? '';
    if (place.isEmpty) return;
    setState(() {
      _location.text = place;
      _locationSeeded = true;
    });
  }

  void _ensureSeeded(Connection connection) {
    _seedingControllers = true;
    try {
      if (!_initializedNote) {
        _note.text = connection.note?.trim() ?? '';
        _initializedNote = true;
      }
      if (_locationSeeded) return;
      final place = connection.fumblePlace?.trim() ?? '';
      if (place.isEmpty) return;
      _location.text = place;
      _locationSeeded = true;
    } finally {
      _seedingControllers = false;
    }
  }

  Future<void> _onSaveNote(Connection connection) async {
    if (_saving) return;
    setState(() => _saving = true);
    final ok = await ConnectionDetailActions.saveNoteAndPop(
      ref: ref,
      connection: connection,
      note: _note.text,
      fumblePlace: _location.text,
    );
    if (!mounted) return;
    if (!ok) setState(() => _saving = false);
  }

  void _aiComingSoon() => showAppToast(AppConstant.aiComingSoon);

  @override
  Widget build(BuildContext context) {
    final connectionsAsync = ref.watch(connectionsProvider);
    final aiCoins =
        ref.watch(currentUserProfileProvider).valueOrNull?.aiCoins ?? 0;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.brand,
          brandTitle: true,
          showBack: true,
          onBack: _saving ? null : pop,
          actions: [
            AiCoinsBadge(
              count: aiCoins,
              onTap: ProfileActions.showAiImageComingSoon,
            ),
          ],
        ),
        body: connectionsAsync.when(
          loading: () => const AppLoader(),
          error: (e, _) =>
              AppErrorState(onRetry: () => ref.invalidate(connectionsProvider)),
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
                  color: AppColors.textSecondary,
                ),
              );
            }
            final connection = match;
            _ensureSeeded(connection);

            final noteDirty =
                _note.text.trim() != (connection.note?.trim() ?? '');
            final savedPlace = connection.fumblePlace?.trim() ?? '';
            final currentPlace = _location.text.trim();
            final placeDirty =
                currentPlace != savedPlace &&
                currentPlace != AppConstant.enterFumbleLocation;
            final dirty = noteDirty || placeDirty;
            final displayName = connection.firstName.isNotEmpty
                ? connection.firstName
                : connection.name;
            final ownerUid =
                ref.read(authServiceProvider).currentUser?.uid ?? '';
            final youInitiated = connection.youInitiated(ownerUid);
            final fumbleLabel = youInitiated
                ? AppConstant.youFumbled(displayName)
                : AppConstant.fumbledYou(displayName);
            final dateLabel =
                DateFormat('d MMMM yyyy').format(connection.fumbledAt);
            final timeLabel = DateFormat('HH:mm').format(connection.fumbledAt);
            final hasLocation = _location.text.trim().isNotEmpty;
            final locationLabel = hasLocation
                ? _location.text.trim()
                : AppConstant.enterFumbleLocation;
            final hasWhatsApp =
                (connection.visibleWhatsApp?.trim().isNotEmpty ?? false);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        8.height,
                        ConnectionAiHeroImage(
                          onTap: _aiComingSoon,
                        ),
                        16.height,
                        ProfileCardHeader(
                          name: connection.name,
                          eyebrow: fumbleLabel.toUpperCase(),
                          photoUrl: connection.photoUrl,
                          bio: connection.bio,
                          phone: connection.visiblePhone,
                          hideBioWhenEmpty: true,
                          showEmail: false,
                          showWhatsAppIcon: hasWhatsApp,
                          emptyPhoneLabel: 'No phone number',
                          topSpacing: 0,
                          onCall: () => ConnectionDetailActions.call(
                            connection.visiblePhone,
                          ),
                          onText: () => ConnectionDetailActions.text(
                            connection.visiblePhone,
                          ),
                          onWhatsApp: () => ConnectionDetailActions.whatsApp(
                            connection.visibleWhatsApp,
                          ),
                        ),
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
                            mapLocation: connection.fumbleLocation,
                            onLocationTap: _saving
                                ? null
                                : () => setState(() => _editingLocation = true),
                          ),
                        16.height,
                        ConnectionAiGroupCard(
                          tab: _aiTab,
                          onTabChanged: (tab) => setState(() => _aiTab = tab),
                          noteController: _note,
                          promptController: _aiPrompt,
                          isListening: _listening,
                          noteEnabled: !_saving && !_listening,
                          onRecordTap: _saving ? null : _toggleVoiceMemory,
                          onGenerateTap: _aiComingSoon,
                          onRegenerateVideoTap: _aiComingSoon,
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
                      onPressed: _saving ? null : () => _onSaveNote(connection),
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
