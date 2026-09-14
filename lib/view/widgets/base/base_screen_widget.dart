import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/utils/colors.dart';

class BaseScreenWidget extends ConsumerWidget {
  final Widget Function(BuildContext context)? builder;
  final SystemUiOverlayStyle? systemUiOverlayStyle;

  const BaseScreenWidget({super.key, this.builder, this.systemUiOverlayStyle})
      : assert(builder != null, 'builder must be provided');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle ?? AppColors.statusBarDark,
      child: builder!(context),
    );
  }
}

class ScaffoldContent extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool? showFloatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final Widget? blockingOverlay;

  const ScaffoldContent({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.showFloatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.blockingOverlay,
  });

  @override
  Widget build(BuildContext context) {
    final overlay = blockingOverlay;
    return PopScope(
      canPop: overlay == null,
      child: Material(
        color: backgroundColor ?? AppColors.backgroundColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: appBar,
              body: body,
              floatingActionButton: showFloatingActionButton == false
                  ? null
                  : floatingActionButton,
              bottomNavigationBar: bottomNavigationBar,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            ),
            if (overlay != null)
              Positioned.fill(
                child: overlay,
              ),
          ],
        ),
      ),
    );
  }
}
