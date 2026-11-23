import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/connection.dart';
import 'package:fumble/data/models/half_fumble.dart';
import 'package:fumble/data/repositories/half_fumble_repository.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/connections_screen/components/connection_actions.dart';
import 'package:fumble/view/screens/connections_screen/components/connection_tile.dart';
import 'package:fumble/view/screens/connections_screen/components/half_fumble_tile.dart';
import 'package:fumble/view/screens/connections_screen/components/incoming_invitation_tile.dart';
import 'package:fumble/view/screens/connections_screen/invitation_accept_screen.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/dialogs/loading_dialog.dart';
import 'package:fumble/view/widgets/feedback/app_error_state.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import 'package:fumble/view/widgets/feedback/no_data_found.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';

enum _ConnectionsTab { fumbled, halfFumble, all }

class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  _ConnectionsTab _tab = _ConnectionsTab.fumbled;
  String? _busyInviteId;

  List<Connection> _fumbledConnections(List<Connection> connections) {
    return connections
        .where((c) => c.syncStatus == SyncStatus.synced)
        .toList();
  }

  List<Connection> _pendingSyncConnections(List<Connection> connections) {
    return connections
        .where(
          (c) =>
              c.syncStatus == SyncStatus.pending ||
              c.syncStatus == SyncStatus.syncing ||
              c.syncStatus == SyncStatus.failed,
        )
        .toList();
  }

  Future<void> _resend(HalfFumble half) async {
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile == null) return;
    try {
      final shared =
          await ref.read(halfFumbleRepositoryProvider).resendInvitation(
                inviter: profile,
                halfFumble: half,
              );
      await SharePlus.instance.share(
        ShareParams(
          text: AppConstant.halfFumbleShareMessage(
            invitedEmail: shared.invitedEmail,
            storeUrl: shared.storeUrl,
            appLink: shared.appLink,
          ),
          subject: AppConstant.addSomeone,
        ),
      );
      showAppToast(AppConstant.halfFumbleInviteShared);
    } on HalfFumbleException catch (e) {
      showAppToast(e.message, isError: true);
    } catch (_) {
      showAppToast(AppConstant.somethingWrong, isError: true);
    }
  }

  Future<void> _cancel(HalfFumble half) async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;
    try {
      await ref.read(halfFumbleRepositoryProvider).revokeInvitation(
            ownerUid: uid,
            halfFumble: half,
          );
      showAppToast(AppConstant.halfFumbleInviteRevoked);
    } on HalfFumbleException catch (e) {
      showAppToast(e.message, isError: true);
    } catch (_) {
      showAppToast(AppConstant.somethingWrong, isError: true);
    }
  }

  void _openIncoming(HalfFumbleInvitation invite) {
    push(
      AppRoutes.invitationAccept,
      arguments: InvitationAcceptArgs(invitationId: invite.id),
    );
  }

  Future<void> _acceptIncoming(HalfFumbleInvitation invite) async {
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile == null) {
      showAppToast(AppConstant.authPleaseLogIn, isError: true);
      return;
    }
    if (_busyInviteId != null) return;

    setState(() => _busyInviteId = invite.id);
    showLoadingDialog(message: AppConstant.loading);
    try {
      final auth = ref.read(authServiceProvider);
      await auth.reloadUser();
      if (!auth.isEmailVerified) {
        showAppToast(AppConstant.verifyEmailBody, isError: true);
        return;
      }

      await ref.read(halfFumbleRepositoryProvider).acceptInvitation(
            acceptor: profile,
            invitationId: invite.id,
          );
      await ref.read(inviteLinkServiceProvider).clearPendingInvite();

      final connections = ref.read(connectionRepositoryProvider);
      await connections.syncConnections(profile.uid);
      connections.refreshConnections(profile.uid);

      ref.invalidate(incomingInvitationsProvider);
      ref.invalidate(halfFumblesProvider);
      ref.invalidate(connectionsProvider);
      showAppToast(AppConstant.halfFumbleAccepted);
    } on HalfFumbleException catch (e) {
      showAppToast(e.message, isError: true);
    } catch (_) {
      showAppToast(AppConstant.somethingWrong, isError: true);
    } finally {
      hideLoadingDialog();
      if (mounted) setState(() => _busyInviteId = null);
    }
  }

  Future<void> _declineIncoming(HalfFumbleInvitation invite) async {
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile == null) {
      showAppToast(AppConstant.authPleaseLogIn, isError: true);
      return;
    }
    if (_busyInviteId != null) return;

    setState(() => _busyInviteId = invite.id);
    showLoadingDialog(message: AppConstant.loading);
    try {
      await ref.read(halfFumbleRepositoryProvider).declineInvitation(
            acceptor: profile,
            invitationId: invite.id,
          );
      ref.invalidate(incomingInvitationsProvider);
      ref.invalidate(halfFumblesProvider);
      showAppToast(AppConstant.halfFumbleDeclined);
    } on HalfFumbleException catch (e) {
      showAppToast(e.message, isError: true);
    } catch (_) {
      showAppToast(AppConstant.somethingWrong, isError: true);
    } finally {
      hideLoadingDialog();
      if (mounted) setState(() => _busyInviteId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionsAsync = ref.watch(connectionsProvider);
    final halfAsync = ref.watch(halfFumblesProvider);
    final incomingAsync = ref.watch(incomingInvitationsProvider);
    final auth = ref.watch(authServiceProvider);
    final ownerUid = auth.currentUser?.uid ?? '';
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final emailVerified = auth.isEmailVerified;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.brand,
          brandTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(28.w, 8.h, 20.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: AppConstant.connectionsTitle.toText(
                      fontSize: 24,
                      fontWeight: AppStyle.w600,
                      color: AppColors.white,
                    ),
                  ),
                  IconButton(
                    tooltip: AppConstant.addSomeone,
                    onPressed: () => push(AppRoutes.addSomeone),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(
                      width: 40.w,
                      height: 40.w,
                    ),
                    icon: Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        AppIcons.add,
                        size: 20.w,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _ConnectionsTabs(
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
            if (!emailVerified &&
                (_tab == _ConnectionsTab.halfFumble ||
                    _tab == _ConnectionsTab.all))
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                child: AppConstant.verifyEmailBody.toText(
                  fontSize: 13,
                  color: AppColors.softGray,
                ),
              ),
            Expanded(
              child: connectionsAsync.when(
                loading: () => const AppLoader(),
                error: (e, _) => AppErrorState(
                  onRetry: () {
                    ref.invalidate(connectionsProvider);
                    ref.invalidate(halfFumblesProvider);
                    ref.invalidate(incomingInvitationsProvider);
                  },
                ),
                data: (connections) {
                  final halfFumbles =
                      halfAsync.valueOrNull ?? const <HalfFumble>[];
                  final incoming =
                      incomingAsync.valueOrNull ?? const <HalfFumbleInvitation>[];
                  // Fumbled tab: synced + offline unsynced QR fumbles.
                  final fumbledItems = [
                    ..._fumbledConnections(connections),
                    ..._pendingSyncConnections(connections),
                  ];
                  // Half Fumble tab: outbound invites + inbound invitations.
                  final halfItems = halfFumbles;

                  final showFumbled = _tab == _ConnectionsTab.fumbled ||
                      _tab == _ConnectionsTab.all;
                  final showHalf = _tab == _ConnectionsTab.halfFumble ||
                      _tab == _ConnectionsTab.all;

                  final visibleFumbled =
                      showFumbled ? fumbledItems : const <Connection>[];
                  final visibleHalf =
                      showHalf ? halfItems : const <HalfFumble>[];
                  final visibleIncoming =
                      showHalf ? incoming : const <HalfFumbleInvitation>[];

                  if (visibleFumbled.isEmpty &&
                      visibleHalf.isEmpty &&
                      visibleIncoming.isEmpty) {
                    if ((halfAsync.isLoading || incomingAsync.isLoading) &&
                        _tab != _ConnectionsTab.fumbled) {
                      return const AppLoader();
                    }
                    return const NoDataFound(
                      title: AppConstant.connectionsEmptyTitle,
                      subtitle: AppConstant.connectionsEmptyBody,
                    );
                  }

                  return ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                    children: [
                      if (showHalf) ...[
                        for (final invite in visibleIncoming) ...[
                          IncomingInvitationTile(
                            invitation: invite,
                            isBusy: _busyInviteId == invite.id,
                            onTap: () => _openIncoming(invite),
                            onAccept: () => _acceptIncoming(invite),
                            onCancel: () => _declineIncoming(invite),
                          ),
                          12.height,
                        ],
                        for (final item in visibleHalf) ...[
                          HalfFumbleTile(
                            halfFumble: item,
                            onResend: () => _resend(item),
                            onCancel: () => _cancel(item),
                          ),
                          12.height,
                        ],
                      ],
                      if (showFumbled) ...[
                        for (final connection in visibleFumbled) ...[
                          ConnectionTile(
                            connection: connection,
                            ownerUid: ownerUid,
                            onTap: () => ConnectionActions.openDetail(
                              connection.peerUid,
                            ),
                            onDeleteTap: () => ConnectionActions.confirmRemove(
                              context: context,
                              ref: ref,
                              connection: connection,
                            ),
                          ),
                          12.height,
                        ],
                      ],
                      if (profile != null &&
                          _tab == _ConnectionsTab.halfFumble) ...[
                        8.height,
                        PrimaryAddSomeoneButton(
                          onPressed: () => push(AppRoutes.addSomeone),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryAddSomeoneButton extends StatelessWidget {
  const PrimaryAddSomeoneButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(AppIcons.add, color: AppColors.gold, size: 18),
        label: AppConstant.addSomeone.toText(
          fontSize: 14,
          fontWeight: AppStyle.w600,
          color: AppColors.gold,
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ConnectionsTabs extends StatelessWidget {
  const _ConnectionsTabs({
    required this.selected,
    required this.onChanged,
  });

  final _ConnectionsTab selected;
  final ValueChanged<_ConnectionsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (_ConnectionsTab.fumbled, AppConstant.connectionsTabFumbled),
      (_ConnectionsTab.halfFumble, AppConstant.connectionsTabHalfFumble),
      (_ConnectionsTab.all, AppConstant.connectionsTabAll),
    ];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              for (final entry in tabs)
                Expanded(
                  child: InkWell(
                    onTap: () => onChanged(entry.$1),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: entry.$2.toText(
                            fontSize: 12,
                            fontWeight: AppStyle.w600,
                            letterSpacing: 0.6,
                            textAlign: TextAlign.center,
                            color: selected == entry.$1
                                ? AppColors.gold
                                : AppColors.softGray,
                            maxLine: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 2,
                          width: double.infinity,
                          color: selected == entry.$1
                              ? AppColors.gold
                              : AppColors.clear,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.border,
        ),
      ],
    );
  }
}
