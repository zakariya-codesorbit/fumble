import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/services/auth/auth_service.dart';
import 'package:fumble/services/notifications/notification_service.dart';
import 'package:fumble/state/notifiers/bottom_navigation_notifier.dart';
import 'package:fumble/state/notifiers/onboarding_notifier.dart';
import 'package:fumble/state/providers/service_providers.dart';
import 'package:fumble/utils/constant.dart';

class AuthToast {
  const AuthToast(this.id, this.message, {this.isError = false});

  final int id;
  final String message;
  final bool isError;
}

class AuthNavigation {
  const AuthNavigation(this.id, {this.route, this.pop = false});

  final int id;
  final String? route;
  final bool pop;
}

class AuthUiState {
  const AuthUiState({
    this.isBusy = false,
    this.toast,
    this.navigation,
  });

  final bool isBusy;
  final AuthToast? toast;
  final AuthNavigation? navigation;

  AuthUiState copyWith({
    bool? isBusy,
    AuthToast? toast,
    AuthNavigation? navigation,
  }) {
    return AuthUiState(
      isBusy: isBusy ?? this.isBusy,
      toast: toast ?? this.toast,
      navigation: navigation ?? this.navigation,
    );
  }
}

class AuthNotifier extends Notifier<AuthUiState> {
  AuthService get _auth => ref.read(authServiceProvider);

  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  int _eventId = 0;

  @override
  AuthUiState build() => const AuthUiState();

  Future<void> login({
    required String email,
    required String password,
  }) {
    return _run(
      action: () => _auth.login(email: email, password: password),
      onSuccess: _goToNextRoute,
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      action: () => _auth.signUp(name: name, email: email, password: password),
      onSuccess: _goToNextRoute,
    );
  }

  Future<void> sendPasswordReset({required String email}) {
    return _run(
      action: () => _auth.sendPasswordReset(email),
      onSuccess: () {
        state = state.copyWith(
          toast: _toastMessage(AppConstant.resetEmailSent),
          navigation: _popNavigation(),
        );
      },
    );
  }

  Future<void> logout() async {
    if (state.isBusy) return;
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
      _resetSessionState();
      state = state.copyWith(
        isBusy: false,
        navigation: _clearTo(AppRoutes.login),
      );
    } finally {
      if (state.isBusy) {
        state = state.copyWith(isBusy: false);
      }
    }
  }

  Future<void> deleteAccount({required String password}) {
    return _run(
      action: () async {
        await _auth.deleteAccount(password: password);
        _resetSessionState();
      },
      onSuccess: () {
        state = state.copyWith(navigation: _clearTo(AppRoutes.login));
      },
    );
  }

  void onAuthState(AsyncValue<User?>? previous, AsyncValue<User?> next) {
    if (state.isBusy) return;
    final wasLoggedIn = previous?.valueOrNull != null;
    if (wasLoggedIn && next.hasValue && next.valueOrNull == null) {
      _resetSessionState();
      state = state.copyWith(navigation: _clearTo(AppRoutes.login));
    }
  }

  void _goToNextRoute() {
    ref.read(onboardingNotifierProvider.notifier).navigateAfterAuth();
  }

  void _resetSessionState() {
    ref.read(bottomNavProvider.notifier).reset();
    ref.read(onboardingNotifierProvider.notifier).reset();
  }

  AuthToast _toastMessage(String message, {bool isError = false}) {
    return AuthToast(++_eventId, message, isError: isError);
  }

  AuthNavigation _clearTo(String route) =>
      AuthNavigation(++_eventId, route: route);

  AuthNavigation _popNavigation() => AuthNavigation(++_eventId, pop: true);

  Future<void> _run({
    required Future<void> Function() action,
    void Function()? onSuccess,
  }) async {
    if (state.isBusy) return;
    state = state.copyWith(isBusy: true);
    try {
      await action();
      state = state.copyWith(isBusy: false);
      onSuccess?.call();
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        toast: _toastMessage(_auth.messageForAuthError(e), isError: true),
      );
    }
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthUiState>(AuthNotifier.new);
