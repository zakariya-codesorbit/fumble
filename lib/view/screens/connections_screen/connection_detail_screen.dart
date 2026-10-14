import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/connection.dart';
import 'package:fumble/services/network/connection_manager.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/connections_screen/components/connection_detail_actions.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/app_error_state.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
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

  void _onNoteEdited() => setState(() {});

  Future<void> _loadPublicExtras() async {
    final extras = await ConnectionDetailActions.loadPublicExtras(
      ref: ref,
      peerUid: widget.peerUid,
    );
    if (!mounted || extras == null) return;
    setState(() {
      if (extras.aboutMe != null) _aboutMe = extras.aboutMe;
      if (extras.location != null) _locationOverride = extras.location;
    });
  }

  void _ensureNoteSeeded(Connection connection) {
    if (_initializedNote) return;
    _note.text = connection.note?.trim() ?? '';
    _initializedNote = true;
  }

  Future<void> _onSaveNote(Connection connection) async {
    if (_saving) return;
    setState(() => _saving = true);
    final ok = await ConnectionDetailActions.saveNoteAndPop(
      ref: ref,
      connection: connection,
      note: _note.text,
    );
    if (!mounted) return;
    if (!ok) setState(() => _saving = false);
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
            final displayName = connection.firstName.isNotEmpty
                ? connection.firstName
                : connection.name;
            final locationText =
                (_locationOverride ?? connection.location)?.trim() ?? '';
            final fumbledLabel =
                '${AppConstant.fumbledOn} ${DateFormat('MMMM d, yyyy').format(connection.fumbledAt)}';

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        ProfileCardHeader(
                          name: connection.name,
                          eyebrow: AppConstant.youFumbled(displayName),
                          photoUrl: connection.photoUrl,
                          bio: connection.bio,
                          phone: connection.visiblePhone,
                          email: connection.visibleEmail,
                          hideBioWhenEmpty: true,
                          emptyPhoneLabel: 'No phone number',
                          topSpacing: 16,
                          onCall: () => ConnectionDetailActions.call(
                            connection.visiblePhone,
                          ),
                          onText: () => ConnectionDetailActions.text(
                            connection.visiblePhone,
                          ),
                        ),
                        ProfileCardSections(
                          aboutMe: ProfileCardSection(
                            body: _aboutMe?.trim() ?? '',
                            emptyBody: AppConstant.addAboutMe,
                          ),
                          location: ProfileCardSection(
                            body: locationText,
                            emptyBody: AppConstant.addLocation,
                          ),
                          noteController: _note,
                          noteEnabled: !_saving,
                          footerLabel: fumbledLabel,
                        ),
                      ],
                    ),
                  ),
                ),
                if (dirty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 24.h),
                    child: PrimaryButton(
                      buttonName: AppConstant.done,
                      onPressed:
                          _saving ? null : () => _onSaveNote(connection),
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
