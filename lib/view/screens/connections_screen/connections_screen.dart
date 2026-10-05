import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/data/models/connection.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/connections_screen/components/connection_tile.dart';
import 'package:fumble/view/screens/setting_screen/components/setting_actions.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/feedback/app_error_state.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import 'package:fumble/view/widgets/feedback/no_data_found.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';

class ConnectionsScreen extends ConsumerWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionsAsync = ref.watch(connectionsProvider);

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: const AppAppBar(
          title: AppConstant.brand,
          brandTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppConstant.connectionsTitle
                .toText(
                  fontSize: 26,
                  fontWeight: AppStyle.w700,
                  lineHeight: 1.15,
                )
                .paddingOnly(left: 28.w, right: 28.w, top: 8.h, bottom: 16.h),
            Expanded(
              child: connectionsAsync.when(
                loading: () => const AppLoader(),
                error: (e, _) => AppErrorState(
                  onRetry: () => ref.invalidate(connectionsProvider),
                ),
                data: (connections) {
                  if (connections.isEmpty) {
                    return const NoDataFound(
                      title: AppConstant.connectionsEmptyTitle,
                      subtitle: AppConstant.connectionsEmptyBody,
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(28.w, 0, 28.w, 24.h),
                    itemCount: connections.length,
                    separatorBuilder: (context, index) => 12.height,
                    itemBuilder: (context, index) {
                      final connection = connections[index];
                      return ConnectionTile(
                        connection: connection,
                        onDeleteTap: () => _confirmRemove(
                          context,
                          ref,
                          connection,
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

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    Connection connection,
  ) {
    return SettingActions.showConfirmSheet(
      context: context,
      title: AppConstant.removeConnection,
      description: AppConstant.removeConnectionConfirm(connection.firstName),
      primaryCta: AppConstant.delete,
      destructive: true,
      onPrimaryTap: () => _remove(ref, connection),
    );
  }

  Future<void> _remove(WidgetRef ref, Connection connection) async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;
    try {
      await ref.read(connectionRepositoryProvider).removeConnection(
            ownerUid: uid,
            peerUid: connection.peerUid,
          );
      showAppToast(AppConstant.connectionRemoved);
    } catch (e) {
      final message = e is StateError && e.message == AppConstant.offline
          ? AppConstant.offline
          : AppConstant.removeConnectionFailed;
      showAppToast(message, isError: true);
    }
  }
}
