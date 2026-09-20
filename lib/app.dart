import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/navigation/app_routes.dart';
import 'core/navigation/navigator_keys.dart';
import 'core/theme/app_theme.dart';
import 'core/ui/scroll_behaviour.dart';
import 'services/analytics/analytics_service.dart';
import 'state/providers/provider_container.dart';
import 'utils/colors.dart';

class FlumbleApp extends StatelessWidget {
  const FlumbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: appContainer,
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.displayName,
      navigatorKey: navigatorKey,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      localizationsDelegates: const [
        CountryLocalizations.delegate,
      ],
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppColors.statusBar,
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1),
              ),
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
