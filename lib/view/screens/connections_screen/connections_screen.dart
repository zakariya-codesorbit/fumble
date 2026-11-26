import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/connection.dart';
import 'package:fumble/data/models/half_fumble.dart';
import 'package:fumble/data/repositories/half_fumble_repository.dart';
import 'package:fumble/services/half_fumble/half_fumble_invite_share.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/state/providers/service_providers.dart';
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

sealed class _ConnectionsRow {
  const _ConnectionsRow();
}

class _IncomingRow extends _ConnectionsRow {
  const _IncomingRow(this.invite);
  final HalfFumbleInvitation invite;
}

class _HalfRow extends _ConnectionsRow {
  const _HalfRow(this.half);
  final HalfFumble half;
}

class _FumbledRow extends _ConnectionsRow {
  const _FumbledRow(this.connection);
  final Connection connection;
}

class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen>
    with WidgetsBindingObserver {
  static const _pageSize = 20;

  _ConnectionsTab _tab = _ConnectionsTab.fumbled;
  String? _busyInviteId;
  final _scrollController = ScrollController();
  var _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refreshConnectionsLists();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final onConnections =
        ref.read(bottomNavProvider).index == AppNavIndex.connections;
    if (onConnections) ref.refreshConnectionsLists();
  }

  void _resetPagination() {
    _visibleCount = _pageSize;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 240) return;
    if (_visibleCount >= _lastTotalRows) return;
    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, _lastTotalRows);
    });
  }

  /// Total rows for the current tab — updated each build for scroll paging.
  var _lastTotalRows = 0;

  void _onSubTabChanged(_ConnectionsTab tab) {
    setState(() {
      _tab = tab;
      _resetPagination();
    });
    // Re-fetch the lists relevant to the visible tab.
    ref.refreshConnectionsLists();
  }

  List<_ConnectionsRow> _buildRows({
    required List<Connection> visibleFumbled,
    required List<HalfFumble> visibleHalf,
    required List<HalfFumbleInvitation> visibleIncoming,
    required bool showFumbled,
    required bool showHalf,
  }) {
    return [
      if (showHalf) ...[
        for (final invite in visibleIncoming) _IncomingRow(invite),
        for (final item in visibleHalf) _HalfRow(item),
      ],
      if (showFumbled) ...[
        for (final connection in visibleFumbled) _FumbledRow(connection),
      ],
    ];
  }

  List<Connection> _fumbledConnections(List<Connection> connections) {
    return connections.where((c) => c.syncStatus == SyncStatus.synced).toList();
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
      await ref
          .read(halfFumbleRepositoryProvider)
          .revokeInvitation(ownerUid: uid, halfFumble: half);
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

      await ref
          .read(halfFumbleRepositoryProvider)
          .acceptInvitation(acceptor: profile, invitationId: invite.id);
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
      await ref
          .read(halfFumbleRepositoryProvider)
          .declineInvitation(acceptor: profile, invitationId: invite.id);
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
        appBar: AppAppBar(title: AppConstant.brand, brandTitle: true),
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
                      color: AppColors.textPrimary,
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
                        color: AppColors.primary,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        AppIcons.add,
                        size: 20.w,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _ConnectionsTabs(selected: _tab, onChanged: _onSubTabChanged),
            if (!emailVerified &&
                (_tab == _ConnectionsTab.halfFumble ||
                    _tab == _ConnectionsTab.all))
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                child: AppConstant.verifyEmailBody.toText(
                  fontSize: 13,
                  color: AppColors.textSecondary,
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
                      incomingAsync.valueOrNull ??
                      const <HalfFumbleInvitation>[];
                  // Fumbled tab: synced + offline unsynced QR fumbles.
                  final fumbledItems = [
                    ..._fumbledConnections(connections),
                    ..._pendingSyncConnections(connections),
                  ];
                  // Half Fumble tab: outbound invites + inbound invitations.
                  final halfItems = halfFumbles;

                  final showFumbled =
                      _tab == _ConnectionsTab.fumbled ||
                      _tab == _ConnectionsTab.all;
                  final showHalf =
                      _tab == _ConnectionsTab.halfFumble ||
                      _tab == _ConnectionsTab.all;

                  final visibleFumbled = showFumbled
                      ? fumbledItems
                      : const <Connection>[];
                  final visibleHalf = showHalf
                      ? halfItems
                      : const <HalfFumble>[];
                  final visibleIncoming = showHalf
                      ? incoming
                      : const <HalfFumbleInvitation>[];

                  final rows = _buildRows(
                    visibleFumbled: visibleFumbled,
                    visibleHalf: visibleHalf,
                    visibleIncoming: visibleIncoming,
                    showFumbled: showFumbled,
                    showHalf: showHalf,
                  );
                  _lastTotalRows = rows.length;
                  final pageCount = _visibleCount > rows.length
                      ? rows.length
                      : _visibleCount;

                  if (rows.isEmpty) {
                    if ((halfAsync.isLoading || incomingAsync.isLoading) &&
                        _tab != _ConnectionsTab.fumbled) {
                      return const AppLoader();
                    }
                    if (profile != null && _tab == _ConnectionsTab.halfFumble) {
                      return ListView(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                        children: [
                          const NoDataFound(
                            title: AppConstant.connectionsEmptyTitle,
                            subtitle: AppConstant.connectionsEmptyBody,
                          ),
                          16.height,
                          PrimaryAddSomeoneButton(
                            onPressed: () => push(AppRoutes.addSomeone),
                          ),
                        ],
                      );
                    }
                    return const NoDataFound(
                      title: AppConstant.connectionsEmptyTitle,
                      subtitle: AppConstant.connectionsEmptyBody,
                    );
                  }

                  final hasMore = pageCount < rows.length;
                  final showAddSomeone =
                      profile != null && _tab == _ConnectionsTab.halfFumble;
                  final itemCount =
                      pageCount + (hasMore ? 1 : 0) + (showAddSomeone ? 1 : 0);

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (index < pageCount) {
                        final row = rows[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: switch (row) {
                            _IncomingRow(:final invite) =>
                              IncomingInvitationTile(
                                invitation: invite,
                                isBusy: _busyInviteId == invite.id,
                                onTap: () => _openIncoming(invite),
                                onAccept: () => _acceptIncoming(invite),
                                onCancel: () => _declineIncoming(invite),
                              ),
                            _HalfRow(:final half) => HalfFumbleTile(
                              halfFumble: half,
                              onResend: () => _resend(half),
                              onCancel: () => _cancel(half),
                            ),
                            _FumbledRow(:final connection) => ConnectionTile(
                              connection: connection,
                              ownerUid: ownerUid,
                              onTap: () => ConnectionActions.openDetail(
                                connection.peerUid,
                              ),
                              onDeleteTap: () =>
                                  ConnectionActions.confirmRemove(
                                    context: context,
                                    ref: ref,
                                    connection: connection,
                                  ),
                            ),
                          },
                        );
                      }

                      var cursor = pageCount;
                      if (hasMore && index == cursor) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          if (_visibleCount >= _lastTotalRows) return;
                          setState(() {
                            _visibleCount = (_visibleCount + _pageSize).clamp(
                              0,
                              _lastTotalRows,
                            );
                          });
                        });
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }
                      if (hasMore) cursor += 1;
                      if (showAddSomeone && index == cursor) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: PrimaryAddSomeoneButton(
                            onPressed: () => push(AppRoutes.addSomeone),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
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
        icon: const Icon(AppIcons.add, color: AppColors.primary, size: 18),
        label: AppConstant.addSomeone.toText(
          fontSize: 14,
          fontWeight: AppStyle.w600,
          color: AppColors.primary,
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
  const _ConnectionsTabs({required this.selected, required this.onChanged});

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
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            maxLine: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 2,
                          width: double.infinity,
                          color: selected == entry.$1
                              ? AppColors.primary
                              : AppColors.clear,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(height: 1, width: double.infinity, color: AppColors.border),
      ],
    );
  }
}
