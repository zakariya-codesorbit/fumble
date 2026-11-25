import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/services/auth/auth_service.dart';
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

class AuthDialog {
  const AuthDialog({
    required this.id,
    required this.title,
    required this.body,
    required this.cta,
  });

  final int id;
  final String title;
  final String body;
  final String cta;
}

class AuthUiState {
  const AuthUiState({
    this.isLoading = false,
    this.toast,
    this.navigation,
    this.dialog,
  });

  final bool isLoading;
  final AuthToast? toast;
  final AuthNavigation? navigation;
  final AuthDialog? dialog;

  AuthUiState copyWith({
    bool? isLoading,
    AuthToast? toast,
    AuthNavigation? navigation,
    AuthDialog? dialog,
  }) {
    return AuthUiState(
      isLoading: isLoading ?? this.isLoading,
      toast: toast ?? this.toast,
      navigation: navigation ?? this.navigation,
      dialog: dialog ?? this.dialog,
    );
  }
}

class AuthNotifier extends Notifier<AuthUiState> {
  AuthService get _auth => ref.read(authServiceProvider);

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

  /// Creates the account, sends verification email, signs out, then prompts
  /// the user to verify and log in (same for normal + Half Fumble signup).
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      await _auth.signUp(name: name, email: email, password: password);
      try {
        await _auth.logout();
      } catch (_) {
        /* still send them to login */
      }
      _resetSessionState();
      state = state.copyWith(
        isLoading: false,
        dialog: AuthDialog(
          id: ++_eventId,
          title: AppConstant.verifyEmailSignupTitle,
          body: AppConstant.verifyEmailSignupBody,
          cta: AppConstant.verifyEmailSignupCta,
        ),
        navigation: _clearTo(AppRoutes.login),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        toast: _toastMessage(_auth.messageForAuthError(e), isError: true),
      );
    }
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
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      try {
        await _auth.logout();
      } catch (_) {
        try {
          await _auth.logout();
        } catch (_) {/* ignore */}
      }
      _resetSessionState();
      state = state.copyWith(
        isLoading: false,
        navigation: _clearTo(AppRoutes.login),
      );
    } finally {
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> deleteAccount({
    required String password,
    bool manageLoading = true,
  }) {
    return _run(
      manageLoading: manageLoading,
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
    if (state.isLoading) return;
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
    bool manageLoading = true,
  }) async {
    if (manageLoading) {
      if (state.isLoading) return;
      state = state.copyWith(isLoading: true);
    }
    try {
      await action();
      if (manageLoading) {
        state = state.copyWith(isLoading: false);
      }
      onSuccess?.call();
    } catch (e) {
      state = state.copyWith(
        isLoading: manageLoading ? false : state.isLoading,
        toast: _toastMessage(_auth.messageForAuthError(e), isError: true),
      );
    }
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthUiState>(AuthNotifier.new);
