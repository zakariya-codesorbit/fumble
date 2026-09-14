import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class BottomNavigation extends ConsumerWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(bottomNavProvider);
    final controller = ref.read(bottomNavProvider.notifier);

    final tabs = const [
      _NavTab(
        label: AppConstant.tabFlumble,
        filledIcon: AppIcons.tabFlumble,
        outlinedIcon: AppIcons.tabFlumble,
      ),
      _NavTab(
        label: AppConstant.tabMyFlumble,
        filledIcon: AppIcons.tabMyFlumble,
        outlinedIcon: AppIcons.tabMyFlumbleOutlined,
      ),
      _NavTab(
        label: AppConstant.tabConnections,
        filledIcon: AppIcons.tabConnections,
        outlinedIcon: AppIcons.tabConnectionsOutlined,
      ),
    ];

    return Container(
      color: AppColors.navBar,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppStyle.bottomNavHeight,
          child: Row(
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final active = nav.index == index;
              final icon = active ? tab.filledIcon : tab.outlinedIcon;
              final color = active ? AppColors.gold : AppColors.softGray;
              return Expanded(
                child: InkWell(
                  onTap: () => controller.setIndex(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: 32),
                      4.height,
                      tab.label.toText(
                        color: color,
                        fontSize: 11,
                        fontWeight: active ? AppStyle.w600 : AppStyle.w500,
                        letterSpacing: 0.5,
                        maxLine: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.label,
    required this.filledIcon,
    required this.outlinedIcon,
  });

  final String label;
  final IconData filledIcon;
  final IconData outlinedIcon;
}
