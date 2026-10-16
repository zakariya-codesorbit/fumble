import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/models/connection.dart';
import 'package:fumble/services/network/connection_manager.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/setting_screen/components/setting_actions.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';

/// List-level connection actions (open detail, remove).
abstract final class ConnectionActions {
  ConnectionActions._();

  static void openDetail(String peerUid) {
    push(AppRoutes.connectionDetail, arguments: peerUid);
  }

  static Future<void> confirmRemove({
    required BuildContext context,
    required WidgetRef ref,
    required Connection connection,
  }) {
    return SettingActions.showConfirmSheet(
      context: context,
      title: AppConstant.removeConnection,
      description: AppConstant.removeConnectionConfirm(connection.firstName),
      primaryCta: AppConstant.delete,
      destructive: true,
      onPrimaryTap: () => remove(ref: ref, connection: connection),
    );
  }

  static Future<void> remove({
    required WidgetRef ref,
    required Connection connection,
  }) async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;
    final wasOffline = !ConnectionManager().isConnected;
    try {
      await ref.read(connectionRepositoryProvider).removeConnectionForBoth(
            ownerUid: uid,
            peerUid: connection.peerUid,
          );
      showAppToast(
        wasOffline
            ? AppConstant.connectionRemovedOffline
            : AppConstant.connectionRemoved,
      );
    } catch (e) {
      showAppToast(AppConstant.removeConnectionFailed, isError: true);
    }
  }
}
