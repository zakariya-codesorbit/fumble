import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';

class LegalWebViewScreen extends ConsumerWidget {
  const LegalWebViewScreen({
    super.key,
    required this.title,
    required this.isPrivacy,
  });

  final String title;
  final bool isPrivacy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final load = ref.watch(legalWebViewNotifierProvider(isPrivacy));
    final notifier = ref.read(legalWebViewNotifierProvider(isPrivacy).notifier);

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: title,
          showBack: true,
          actions: [
            IconButton(
              tooltip: AppConstant.reloadTooltip,
              icon: const Icon(AppIcons.refresh),
              onPressed: notifier.reload,
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: notifier.controller),
            if (load.isLoading) const AppLoader(),
          ],
        ),
      ),
    );
  }
}
