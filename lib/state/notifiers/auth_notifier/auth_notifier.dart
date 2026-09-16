import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/services/auth/auth_service.dart';
import 'package:fumble/services/notifications/notification_service.dart';
import 'package:fumble/state/notifiers/main_notifier/bottom_navigation_notifier.dart';
import 'package:fumble/state/notifiers/onboarding_notifier/onboarding_notifier.dart';
import 'package:fumble/state/providers/service_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/dialogs/loading_dialog.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';

class AuthUiState {
  const AuthUiState({this.isBusy = false});

  final bool isBusy;

  AuthUiState copyWith({bool? isBusy}) =>
      AuthUiState(isBusy: isBusy ?? this.isBusy);
}

class AuthNotifier extends Notifier<AuthUiState> {
  AuthService get _auth => ref.read(authServiceProvider);

  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  @override
  AuthUiState build() => const AuthUiState();

  Future<void> login({
    required GlobalKey<FormState> formKey,
    required String email,
    required String password,
  }) {
    return _run(
      formKey: formKey,
      action: () => _auth.login(email: email, password: password),
      onSuccess: () =>
          ref.read(onboardingNotifierProvider.notifier).navigateAfterAuth(),
    );
  }

  Future<void> signUp({
    required GlobalKey<FormState> formKey,
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      formKey: formKey,
      action: () => _auth.signUp(name: name, email: email, password: password),
      onSuccess: () =>
          ref.read(onboardingNotifierProvider.notifier).navigateAfterAuth(),
    );
  }

  Future<void> sendPasswordReset({
    required GlobalKey<FormState> formKey,
    required String email,
  }) {
    return _run(
      formKey: formKey,
      action: () => _auth.sendPasswordReset(email),
      onSuccess: () {
        showAppToast(AppConstant.resetEmailSent);
        pop();
      },
    );
  }

  Future<void> logout() async {
    showLoadingDialog(message: AppConstant.loading);
    state = state.copyWith(isBusy: true);
    try {
      try {
        await _notifications
            .clearTokenOnLogout()
            .timeout(const Duration(seconds: 2));
      } catch (_) {/* ignore */}
      try {
        await _auth.logout();
      } catch (_) {
        try {
          await _auth.logout();
        } catch (_) {/* ignore */}
      }
      ref.read(bottomNavProvider.notifier).reset();
      ref.read(onboardingNotifierProvider.notifier).reset();
      hideLoadingDialog();
      pushAndClearAll(AppRoutes.login);
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  Future<void> deleteAccount({required String password}) {
    return _run(
      action: () async {
        await _auth.deleteAccount(password: password);
        ref.read(bottomNavProvider.notifier).reset();
        ref.read(onboardingNotifierProvider.notifier).reset();
      },
      onSuccess: () => pushAndClearAll(AppRoutes.login),
    );
  }

  void onAuthState(AsyncValue<User?>? previous, AsyncValue<User?> next) {
    if (state.isBusy) return;
    final wasLoggedIn = previous?.valueOrNull != null;
    if (wasLoggedIn && next.hasValue && next.valueOrNull == null) {
      ref.read(bottomNavProvider.notifier).reset();
      ref.read(onboardingNotifierProvider.notifier).reset();
      pushAndClearAll(AppRoutes.login);
    }
  }

  Future<void> _run({
    GlobalKey<FormState>? formKey,
    required Future<void> Function() action,
    FutureOr<void> Function()? onSuccess,
  }) async {
    if (formKey != null && !(formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (state.isBusy) return;
    showLoadingDialog(message: AppConstant.loading);
    state = state.copyWith(isBusy: true);
    try {
      await action();
      hideLoadingDialog();
      state = state.copyWith(isBusy: false);
      onSuccess?.call();
    } catch (e) {
      hideLoadingDialog();
      state = state.copyWith(isBusy: false);
      showAppToast(_auth.messageForAuthError(e), isError: true);
    }
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthUiState>(AuthNotifier.new);
