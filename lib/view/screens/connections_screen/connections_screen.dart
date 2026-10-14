import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
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
import 'package:fumble/view/widgets/layout/app_app_bar.dart';

class ConnectionsScreen extends ConsumerWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionsAsync = ref.watch(connectionsProvider);

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: const AppAppBar(title: AppConstant.brand, brandTitle: true),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppConstant.connectionsTitle.toText(
                  fontSize: 22,
                  fontWeight: AppStyle.w600,
                  lineHeight: 1.15,
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                  ),
                  child: Icon(
                    AppIcons.add,
                    color: AppColors.background,
                    size: 25.w,
                  ),
                ).onPress(() {
                  ref.read(bottomNavProvider.notifier).setIndex(0);
                }),
              ],
            ).paddingOnly(left: 28.w, right: 28.w, top: 4.h, bottom: 16.h),
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
