import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  double _scale = 0.30;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(AppColors.statusBar);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _scale = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final splash = ref.read(splashNotifierProvider.notifier);
    ref.listen(authStateProvider, splash.onAuth);

    final auth = ref.watch(authStateProvider);
    auth.whenData(splash.scheduleContinue);

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        body: Center(
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOut,
            child: Center(
              child: AppConstant.brand.toBrandText(
                color: AppColors.gold,
                fontSize: 42,
                fontWeight: AppStyle.w700,
                lineHeight: 1.25,
                textAlign: TextAlign.center,
                letterSpacing: 6,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
