import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/state/providers/app_providers.dart';

abstract final class SplashActions {
  SplashActions._();

  static void onAuth(
    WidgetRef ref,
    AsyncValue<User?>? previous,
    AsyncValue<User?> next,
  ) {
    ref.read(splashNotifierProvider.notifier).onAuth(previous, next);
  }

  static void scheduleContinue(WidgetRef ref, User? user) {
    ref.read(splashNotifierProvider.notifier).scheduleContinue(user);
  }
}
