import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fumble/data/db/local_prefs.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/data/repositories/user_repository.dart';
import 'package:fumble/services/fumble/fumble_qr.dart';
import 'package:fumble/services/storage/profile_photo_service.dart';
import 'package:fumble/state/providers/service_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/focus_utils.dart';
import 'package:fumble/view/widgets/avatar/avatar_picker_sheet.dart';
import 'package:fumble/view/widgets/dialogs/photo_permission_popup.dart';
import 'package:fumble/view/widgets/dialogs/photo_source_sheet.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';

class ProfileEditState {
  const ProfileEditState({
    this.isSaving = false,
    this.localPhoto,
    this.avatarSvg,
    this.removePhoto = false,
  });

  final bool isSaving;
  final File? localPhoto;
  final String? avatarSvg;
  final bool removePhoto;

  bool hasExistingPhoto(UserProfile? profile) {
    return !removePhoto &&
        (localPhoto != null ||
            avatarSvg != null ||
            (profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty));
  }

  String? displayPhotoUrl(UserProfile? profile) =>
      removePhoto ? null : profile?.photoUrl;

  ProfileEditState copyWith({
    bool? isSaving,
    File? localPhoto,
    bool clearLocalPhoto = false,
    String? avatarSvg,
    bool clearAvatar = false,
    bool? removePhoto,
  }) {
    return ProfileEditState(
      isSaving: isSaving ?? this.isSaving,
      localPhoto: clearLocalPhoto ? null : (localPhoto ?? this.localPhoto),
      avatarSvg: clearAvatar ? null : (avatarSvg ?? this.avatarSvg),
      removePhoto: removePhoto ?? this.removePhoto,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileEditState> {
  UserRepository get _users => ref.read(userRepositoryProvider);

  ProfilePhotoService get _photos => ref.read(profilePhotoServiceProvider);

  UserProfile? get _currentProfile =>
      ref.read(currentUserProfileProvider).valueOrNull;

  @override
  ProfileEditState build() => const ProfileEditState();

  void resetEdit() => state = const ProfileEditState();

  void markPhotoRemoved() {
    state = state.copyWith(
      clearLocalPhoto: true,
      clearAvatar: true,
      removePhoto: true,
    );
  }

  Future<void> showPhotoSheet(BuildContext context) async {
    final choice = await showPhotoSourceSheet(
      context,
      showRemove: state.hasExistingPhoto(_currentProfile),
    );
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
          avatarSvg: path,
          clearLocalPhoto: true,
          removePhoto: false,
        );
      case PhotoSourceChoice.remove:
        markPhotoRemoved();
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
      state = state.copyWith(
        localPhoto: file,
        clearAvatar: true,
        removePhoto: false,
      );
    } catch (e) {
      if (!context.mounted) return;
      if (isPhotoPermissionError(e)) {
        await showPhotoPermissionPopup(context, camera: camera);
        return;
      }
      showAppToast(e.toString(), isError: true);
    }
  }

  Future<void> updateShareVisibility({
    bool? sharePhone,
    bool? shareEmail,
  }) async {
    final profile = _currentProfile;
    if (profile == null) return;
    if (sharePhone == null && shareEmail == null) return;

    final nextPhone = sharePhone ?? profile.sharePhone;
    final nextEmail = shareEmail ?? profile.shareEmail;
    if (nextPhone == profile.sharePhone && nextEmail == profile.shareEmail) {
      return;
    }

    ref.read(shareVisibilityProvider.notifier).state = (
      sharePhone: nextPhone,
      shareEmail: nextEmail,
    );
    unawaited(
      LocalPrefs.saveUserProfile(
        profile.copyWith(sharePhone: nextPhone, shareEmail: nextEmail),
      ),
    );

    try {
      await _users.updateUserProfile(
        uid: profile.uid,
        sharePhone: nextPhone,
        shareEmail: nextEmail,
      );
    } catch (e) {
      ref.read(shareVisibilityProvider.notifier).state = null;
      showAppToast(e.toString(), isError: true);
    }
  }

  Future<void> save({
    required String name,
    required String bio,
    required String aboutMe,
    required String location,
    required String phone,
    required bool sharePhone,
    required bool shareEmail,
  }) async {
    final profile = _currentProfile;
    if (profile == null) return;
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      showAppToast(AppConstant.nameRequired, isError: true);
      return;
    }
    if (state.isSaving) return;

    unfocusKeyboard();
    state = state.copyWith(isSaving: true);
    try {
      String? nextPhoto;
      if (state.removePhoto) {
        nextPhoto = '';
      } else if (state.avatarSvg != null) {
        nextPhoto = state.avatarSvg;
      } else if (state.localPhoto != null) {
        nextPhoto = await _photos.toBase64(state.localPhoto!);
      }

      // Update QR immediately on save (before Firestore stream catches up).
      ref.read(shareVisibilityProvider.notifier).state = (
        sharePhone: sharePhone,
        shareEmail: shareEmail,
      );
      unawaited(
        LocalPrefs.saveUserProfile(
          profile.copyWith(
            name: trimmedName,
            bio: bio.trim().isEmpty ? null : bio.trim(),
            aboutMe: aboutMe.trim().isEmpty ? null : aboutMe.trim(),
            location: location.trim().isEmpty ? null : location.trim(),
            phone: phone.trim().isEmpty ? null : phone.trim(),
            sharePhone: sharePhone,
            shareEmail: shareEmail,
            photoUrl: nextPhoto == null
                ? profile.photoUrl
                : (nextPhoto.isEmpty ? null : nextPhoto),
          ),
        ),
      );

      await _users.updateUserProfile(
        uid: profile.uid,
        name: trimmedName,
        photoUrl: nextPhoto,
        bio: bio,
        aboutMe: aboutMe,
        location: location,
        phone: phone,
        sharePhone: sharePhone,
        shareEmail: shareEmail,
      );

      state = const ProfileEditState();
      showAppToast(
        nextPhoto != null
            ? AppConstant.photoUpdated
            : AppConstant.profileUpdated,
      );
    } catch (e) {
      ref.read(shareVisibilityProvider.notifier).state = null;
      state = state.copyWith(isSaving: false);
      showAppToast(e.toString(), isError: true);
    }
  }

  Future<void> shareCurrent() async {
    final profile = _currentProfile;
    if (profile == null) return;
    await SharePlus.instance.share(
      ShareParams(
        text: AppConstant.sharefumbleMessage(profile.fumbleCode),
        subject: AppConstant.sharefumble,
      ),
    );
  }

  void copyfumbleCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
  }

  String qrPayload(UserProfile profile) => FumbleQr.build(
    userId: profile.uid,
    name: profile.name,
  );

  Future<void> call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> text(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

final profileNotifierProvider =
    NotifierProvider<ProfileNotifier, ProfileEditState>(ProfileNotifier.new);
