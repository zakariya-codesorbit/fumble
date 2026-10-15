import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/connections_screen/components/connection_actions.dart';
import 'package:fumble/view/screens/connections_screen/components/connection_tile.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/feedback/app_error_state.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/feedback/no_data_found.dart';

class ConnectionsScreen extends ConsumerWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionsAsync = ref.watch(connectionsProvider);
    final ownerUid = ref.watch(authServiceProvider).currentUser?.uid ?? '';

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppConstant.connectionsTitle
                  .toText(
                    fontSize: 24,
                    fontWeight: AppStyle.w600,
                    lineHeight: 1.15,
                  )
                  .paddingOnly(
                    left: 28.w,
                    right: 28.w,
                    top: 16.h,
                    bottom: 16.h,
                  ),
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
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                      itemCount: connections.length,
                      separatorBuilder: (context, index) => 12.height,
                      itemBuilder: (context, index) {
                        final connection = connections[index];
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
      ),
    );
  }
}
