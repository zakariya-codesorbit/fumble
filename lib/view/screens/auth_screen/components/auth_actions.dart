import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/focus_utils.dart';

abstract final class AuthActions {
  AuthActions._();

  static void goToForgotPassword() => push(AppRoutes.forgotPassword);

  static void goToSignup() => replace(AppRoutes.signup);

  static void goToLogin() => replace(AppRoutes.login);

  static Future<void> login({
    required WidgetRef ref,
    required GlobalKey<FormState> formKey,
    required String email,
    required String password,
  }) async {
    await unfocusKeyboard();
    if (!(formKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).login(
          email: email,
          password: password,
        );
  }

  static Future<void> signUp({
    required WidgetRef ref,
    required GlobalKey<FormState> formKey,
    required String name,
    required String email,
    required String password,
  }) async {
    await unfocusKeyboard();
    if (!(formKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).signUp(
          name: name,
          email: email,
          password: password,
        );
  }

  static Future<void> sendPasswordReset({
    required WidgetRef ref,
    required GlobalKey<FormState> formKey,
    required String email,
  }) async {
    await unfocusKeyboard();
    if (!(formKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).sendPasswordReset(
          email: email,
        );
  }
}
