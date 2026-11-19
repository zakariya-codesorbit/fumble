import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/onboarding_gate.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/db/local_prefs.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/data/repositories/user_repository.dart';
import 'package:fumble/services/auth/auth_service.dart';
import 'package:fumble/services/storage/profile_photo_service.dart';
import 'package:fumble/state/providers/service_providers.dart';
import 'package:fumble/utils/app_avatars.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/focus_utils.dart';
import 'package:fumble/view/widgets/avatar/avatar_picker_sheet.dart';
import 'package:fumble/view/widgets/dialogs/loading_dialog.dart';
import 'package:fumble/view/widgets/dialogs/photo_permission_popup.dart';
import 'package:fumble/view/widgets/dialogs/photo_source_sheet.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';

class OnboardingState {
  const OnboardingState({
    this.isSaving = false,
    this.localPhoto,
    this.avatarAsset,
  });

  final bool isSaving;
  final File? localPhoto;
  /// Bundled avatar PNG asset path (e.g. assets/avatars/avatar-1.png).
  final String? avatarAsset;

  OnboardingState copyWith({
    bool? isSaving,
    File? localPhoto,
    bool clearLocalPhoto = false,
    String? avatarAsset,
    bool clearAvatar = false,
  }) {
    return OnboardingState(
      isSaving: isSaving ?? this.isSaving,
      localPhoto: clearLocalPhoto ? null : (localPhoto ?? this.localPhoto),
      avatarAsset: clearAvatar ? null : (avatarAsset ?? this.avatarAsset),
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  AuthService get _auth => ref.read(authServiceProvider);

  UserRepository get _users => ref.read(userRepositoryProvider);

  ProfilePhotoService get _photos => ref.read(profilePhotoServiceProvider);

  @override
  OnboardingState build() => const OnboardingState();

  void reset() {
    state = const OnboardingState();
    LocalPrefs.setOnboardingCompleted(false);
  }

  Future<String> resolveRoute({
    bool photoFilled = false,
    bool phoneFilled = false,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return AppRoutes.login;
    if (await LocalPrefs.onboardingCompleted) return AppRoutes.main;
    UserProfile? profile = ref.read(currentUserProfileProvider).valueOrNull;
    try {
      profile = await _users.loadUserProfile(uid) ?? profile;
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
    // Close IME before tearing down auth TextFields — avoids keyboard flash
    // on onboarding/home during pushAndClearAll.
    await unfocusKeyboard(saveAutofill: true);
    pushAndClearAll(await resolveRoute());
  }

  Future<void> showPhotoSheet(BuildContext context) async {
    final choice = await showPhotoSourceSheet(context);
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case PhotoSourceChoice.camera:
        if (!await ensurePhotoSourcePermission(context, camera: true)) break;
        if (!context.mounted) break;
        await _setPickedFile(context, _photos.pickFromCamera(), camera: true);
      case PhotoSourceChoice.gallery:
        if (!await ensurePhotoSourcePermission(context, camera: false)) break;
        if (!context.mounted) break;
        await _setPickedFile(context, _photos.pickFromGallery(), camera: false);
      case PhotoSourceChoice.avatar:
        final path = await showAvatarPickerSheet(context);
        if (path == null || path.isEmpty) return;
        state = state.copyWith(
          avatarAsset: AppAvatars.resolve(path) ?? path,
          clearLocalPhoto: true,
        );
      case PhotoSourceChoice.remove:
        break;
    }
  }

  Future<void> _setPickedFile(
    BuildContext context,
    Future<File?> pick, {
    required bool camera,
  }) async {
    try {
      final file = await pick;
      if (file == null) return;
      state = state.copyWith(localPhoto: file, clearAvatar: true);
    } catch (e) {
      if (!context.mounted) return;
      if (isPhotoPermissionError(e)) {
        await showPhotoPermissionPopup(context, camera: camera);
        return;
      }
      if (e is PhotoTooLargeException) {
        showAppToast(AppConstant.photoTooLarge, isError: true);
        return;
      }
      showAppToast(e.toString(), isError: true);
    }
  }

  Future<void> savePhotoAndContinue() {
    return _saveAndContinue(
      persist: (uid) async {
        if (state.avatarAsset != null) {
          final photoUrl = await _photos.uploadAvatarAsset(
            uid: uid,
            assetPath: state.avatarAsset!,
          );
          await _users.updateUserProfile(uid: uid, photoUrl: photoUrl);
          return;
        }
        if (state.localPhoto == null) return;
        final photoUrl = await _photos.uploadProfilePhoto(
          uid: uid,
          file: state.localPhoto!,
        );
        await _users.updateUserProfile(uid: uid, photoUrl: photoUrl);
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
      persist: (uid) async {
        if (phone.trim().isEmpty) return;
        await _users.updateUserProfile(uid: uid, phone: phone);
      },
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
    await unfocusKeyboard();
    if (formKey != null && !(formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (validate != null && !validate()) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null || state.isSaving) return;

    showLoadingDialog(message: AppConstant.loading);
    state = state.copyWith(isSaving: true);
    try {
      await persist(uid);
      if (phoneFilled) await LocalPrefs.setOnboardingCompleted(true);
      final next = await resolveRoute(
        photoFilled: photoFilled,
        phoneFilled: phoneFilled,
      );
      hideLoadingDialog();
      state = state.copyWith(isSaving: false);
      // Close IME before tearing down onboarding TextFields.
      await unfocusKeyboard();
      pushAndClearAll(next);
    } catch (e) {
      hideLoadingDialog();
      state = state.copyWith(isSaving: false);
      showAppToast(
        e is PhotoTooLargeException
            ? AppConstant.photoTooLarge
            : e.toString(),
        isError: true,
      );
    }
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
