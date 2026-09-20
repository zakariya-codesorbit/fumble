import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/onboarding_gate.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/data/repositories/user_repository.dart';
import 'package:fumble/services/auth/auth_service.dart';
import 'package:fumble/services/storage/profile_photo_service.dart';
import 'package:fumble/state/providers/service_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/focus_utils.dart';
import 'package:fumble/view/widgets/dialogs/loading_dialog.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';

class OnboardingState {
  const OnboardingState({
    this.saving = false,
    this.localPhoto,
  });

  final bool saving;
  final File? localPhoto;

  OnboardingState copyWith({
    bool? saving,
    File? localPhoto,
  }) {
    return OnboardingState(
      saving: saving ?? this.saving,
      localPhoto: localPhoto ?? this.localPhoto,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  AuthService get _auth => ref.read(authServiceProvider);

  UserRepository get _users => ref.read(userRepositoryProvider);

  ProfilePhotoService get _photos => ref.read(profilePhotoServiceProvider);

  UserProfile? get _currentProfile =>
      ref.read(currentUserProfileProvider).valueOrNull;

  @override
  OnboardingState build() => const OnboardingState();

  void reset() => state = const OnboardingState();

  Future<String> resolveRoute({
    bool photoFilled = false,
    bool phoneFilled = false,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return AppRoutes.login;
    UserProfile? profile = ref.read(currentUserProfileProvider).valueOrNull;
    try {
      profile = await _users.getUser(uid) ?? profile;
    } catch (_) {
      // Use the cached stream profile when Firestore is unavailable.
    }
    return OnboardingGate.routeFor(
      profile,
      photoFilled: photoFilled,
      phoneFilled: phoneFilled,
    );
  }

  Future<void> navigateAfterAuth() async {
    reset();
    pushAndClearAll(await resolveRoute());
  }

  Future<void> pickPhoto() async {
    try {
      final file = await _photos.pickFromGallery();
      if (file == null) return;
      state = state.copyWith(localPhoto: file);
    } catch (e) {
      showAppToast(e.toString(), isError: true);
    }
  }

  Future<void> savePhotoAndContinue() {
    return _saveAndContinue(
      validate: () {
        final hasPhoto =
            state.localPhoto != null || (_currentProfile?.hasPhoto ?? false);
        if (!hasPhoto) {
          showAppToast(AppConstant.photoRequired, isError: true);
          return false;
        }
        return true;
      },
      persist: (uid) async {
        if (state.localPhoto == null) return;
        final encoded = await _photos.toBase64(state.localPhoto!);
        await _users.updateProfile(uid: uid, photoUrl: encoded);
      },
      photoFilled: true,
    );
  }

  Future<void> savePhoneAndContinue({
    required GlobalKey<FormState> formKey,
    required String phone,
  }) {
    return _saveAndContinue(
      formKey: formKey,
      persist: (uid) => _users.updateProfile(uid: uid, phone: phone),
      phoneFilled: true,
    );
  }

  Future<void> _saveAndContinue({
    GlobalKey<FormState>? formKey,
    bool Function()? validate,
    required Future<void> Function(String uid) persist,
    bool photoFilled = false,
    bool phoneFilled = false,
  }) async {
    unfocusKeyboard();
    if (formKey != null && !(formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (validate != null && !validate()) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null || state.saving) return;

    showLoadingDialog(message: AppConstant.loading);
    state = state.copyWith(saving: true);
    try {
      await persist(uid);
      final next = await resolveRoute(
        photoFilled: photoFilled,
        phoneFilled: phoneFilled,
      );
      hideLoadingDialog();
      state = state.copyWith(saving: false);
      pushAndClearAll(next);
    } catch (e) {
      hideLoadingDialog();
      state = state.copyWith(saving: false);
      showAppToast(e.toString(), isError: true);
    }
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
