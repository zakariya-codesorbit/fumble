import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/navigation/app_routes.dart';
import 'core/navigation/navigator_keys.dart';
import 'core/navigation/router_navigator.dart';
import 'core/theme/app_theme.dart';
import 'core/ui/scroll_behaviour.dart';
import 'services/analytics/analytics_service.dart';
import 'state/providers/app_providers.dart';
import 'utils/colors.dart';
import 'utils/constant.dart';
import 'view/widgets/dialogs/loading_dialog.dart';
import 'view/widgets/feedback/custom_snackbar.dart';

class FumbleApp extends ConsumerWidget {
  const FumbleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appStartupProvider);
    ref.listen(authNotifierProvider, _onAuthUi);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.displayName,
      navigatorKey: navigatorKey,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      localizationsDelegates: const [CountryLocalizations.delegate],
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppColors.statusBar,
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1)),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      initialRoute: AppRoutes.initial,
      routes: AppRoutes.routes,
      navigatorObservers: [
        routeObserver,
        if (AnalyticsService.instance.navigatorObserver != null)
          AnalyticsService.instance.navigatorObserver!,
      ],
    );
  }
}

void _onAuthUi(AuthUiState? previous, AuthUiState next) {
  if (next.isLoading && previous?.isLoading != true) {
    showLoadingDialog(message: AppConstant.loading);
  }
  if (!next.isLoading && previous?.isLoading == true) {
    hideLoadingDialog();
  }

  final toast = next.toast;
  if (toast != null && toast.id != previous?.toast?.id) {
    showAppToast(toast.message, isError: toast.isError);
  }

  final navigation = next.navigation;
  if (navigation != null && navigation.id != previous?.navigation?.id) {
    if (navigation.pop) {
      pop();
    } else if (navigation.route != null) {
      pushAndClearAll(navigation.route!);
    }
  }
}
