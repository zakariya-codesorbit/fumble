import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/view/screens/connections_screen/connections_screen.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/navigation/bottom_navigation.dart';
import '../fumble_screen/fumble_screen.dart';
import '../my_fumble_screen/my_fumble_screen.dart';

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
        canPop: nav.index == AppNavIndex.fumble,
        onPopInvokedWithResult: (didPop, _) {
          if (nav.index != AppNavIndex.fumble) {
            controller.reset();
          }
        },
        child: ScaffoldContent(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: nav.index,
            children: const [
              FumbleScreen(),
              MyFumbleScreen(),
              ConnectionsScreen(),
            ],
          ),
          bottomNavigationBar: const BottomNavigation(),
        ),
      ),
    );
  }
}
