import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/config/app_config.dart';
import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/state/notifiers/onboarding_notifier.dart';

class SplashState {
  const SplashState({this.navigated = false});

  final bool navigated;

  SplashState copyWith({bool? navigated}) =>
      SplashState(navigated: navigated ?? this.navigated);
}

class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() => const SplashState();

  void onAuth(AsyncValue<User?>? previous, AsyncValue<User?> next) {
    next.when(
      data: (user) => unawaited(continueToApp(authenticated: user != null)),
      loading: () {},
      error: (error, stackTrace) =>
          unawaited(continueToApp(authenticated: false)),
    );
  }

  void scheduleContinue(User? user) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(continueToApp(authenticated: user != null));
    });
  }

  Future<void> continueToApp({required bool authenticated}) async {
    if (state.navigated) return;
    state = const SplashState(navigated: true);
    await Future<void>.delayed(AppConfig.splashMinDuration);
    if (!authenticated) {
      pushAndClearAll(AppRoutes.login);
      return;
    }
    await ref.read(onboardingNotifierProvider.notifier).navigateAfterAuth();
  }
}

final splashNotifierProvider =
    NotifierProvider<SplashNotifier, SplashState>(SplashNotifier.new);
