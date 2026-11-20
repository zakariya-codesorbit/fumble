import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/connection.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/connections_screen/components/connection_actions.dart';
import 'package:fumble/view/screens/connections_screen/components/connection_tile.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/app_error_state.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
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

  List<Connection> _filtered(List<Connection> connections) {
    switch (_tab) {
      case _ConnectionsTab.fumbled:
        // Already synced to Firebase.
        return connections
            .where((c) => c.syncStatus == SyncStatus.synced)
            .toList();
      case _ConnectionsTab.halfFumble:
        // Offline / not yet on Firebase.
        return connections
            .where(
              (c) =>
                  c.syncStatus == SyncStatus.pending ||
                  c.syncStatus == SyncStatus.syncing ||
                  c.syncStatus == SyncStatus.failed,
            )
            .toList();
      case _ConnectionsTab.all:
        return connections;
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionsAsync = ref.watch(connectionsProvider);
    final ownerUid = ref.watch(authServiceProvider).currentUser?.uid ?? '';

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: const AppAppBar(
          title: AppConstant.brand,
          brandTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(28.w, 8.h, 28.w, 12.h),
              child: AppConstant.connectionsTitle.toText(
                fontSize: 24,
                fontWeight: AppStyle.w600,
                color: AppColors.white,
              ),
            ),
            _ConnectionsTabs(
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
            Expanded(
              child: connectionsAsync.when(
                loading: () => const AppLoader(),
                error: (e, _) => AppErrorState(
                  onRetry: () => ref.invalidate(connectionsProvider),
                ),
                data: (connections) {
                  final visible = _filtered(connections);
                  if (visible.isEmpty) {
                    return const NoDataFound(
                      title: AppConstant.connectionsEmptyTitle,
                      subtitle: AppConstant.connectionsEmptyBody,
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                    itemCount: visible.length,
                    separatorBuilder: (context, index) => 12.height,
                    itemBuilder: (context, index) {
                      final connection = visible[index];
                      return ConnectionTile(
                        connection: connection,
                        ownerUid: ownerUid,
                        onTap: () =>
                            ConnectionActions.openDetail(connection.peerUid),
                        onDeleteTap: () => ConnectionActions.confirmRemove(
                          context: context,
                          ref: ref,
                          connection: connection,
                        ),
                      );
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
