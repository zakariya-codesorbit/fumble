import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/view/screens/connections_screen/connections_screen.dart';
import 'package:fumble/view/screens/flumble_screen/flumble_screen.dart';
import 'package:fumble/view/screens/my_flumble_screen/my_flumble_screen.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/navigation/bottom_navigation.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      authStateProvider,
      ref.read(authNotifierProvider.notifier).onAuthState,
    );

    final nav = ref.watch(bottomNavProvider);
    final controller = ref.read(bottomNavProvider.notifier);

    return BaseScreenWidget(
      builder: (context) => PopScope(
        canPop: nav.index == AppNavIndex.flumble,
        onPopInvokedWithResult: (didPop, _) {
          if (nav.index != AppNavIndex.flumble) {
            controller.reset();
          }
        },
        child: ScaffoldContent(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: nav.index,
            children: const [
              FlumbleScreen(),
              MyFlumbleScreen(),
              ConnectionsScreen(),
            ],
          ),
          bottomNavigationBar: const BottomNavigation(),
        ),
      ),
    );
  }
}
