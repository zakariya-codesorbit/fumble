import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/data/repositories/user_repository.dart';
import 'package:fumble/services/fumble/fumble_service.dart';
import 'package:fumble/services/storage/profile_photo_service.dart';
import 'package:fumble/state/providers/service_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/focus_utils.dart';
import 'package:fumble/view/screens/my_flumble_screen/components/photo_action_tile.dart';
import 'package:fumble/view/widgets/dialogs/app_bottom_sheet.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';

class ProfileEditState {
  const ProfileEditState({
    this.saving = false,
    this.localPhoto,
    this.removePhoto = false,
  });

  final bool saving;
  final File? localPhoto;
  final bool removePhoto;

  bool hasExistingPhoto(UserProfile? profile) {
    return !removePhoto &&
        (localPhoto != null ||
            (profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty));
  }

  String? displayPhotoUrl(UserProfile? profile) =>
      removePhoto ? null : profile?.photoUrl;

  ProfileEditState copyWith({
    bool? saving,
    File? localPhoto,
    bool clearLocalPhoto = false,
    bool? removePhoto,
  }) {
    return ProfileEditState(
      saving: saving ?? this.saving,
      localPhoto: clearLocalPhoto ? null : (localPhoto ?? this.localPhoto),
      removePhoto: removePhoto ?? this.removePhoto,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileEditState> {
  UserRepository get _users => ref.read(userRepositoryProvider);

  ProfilePhotoService get _photos => ref.read(profilePhotoServiceProvider);

  FumbleService get _fumble => ref.read(fumbleServiceProvider);

  UserProfile? get _currentProfile =>
      ref.read(currentUserProfileProvider).valueOrNull;

  @override
  ProfileEditState build() => const ProfileEditState();

  void resetEdit() => state = const ProfileEditState();

  void markPhotoRemoved() {
    state = state.copyWith(clearLocalPhoto: true, removePhoto: true);
  }

  Future<void> showPhotoSheet(BuildContext context) async {
    final profile = _currentProfile;
    final hasExisting = state.hasExistingPhoto(profile);

    await showAppBottomSheet<void>(
      context: context,
      title: AppConstant.changePhoto,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhotoActionTile(
              icon: AppIcons.photoLibrary,
              label: AppConstant.chooseFromLibrary,
              onTap: () {
                Navigator.pop(sheetContext);
                pickFromGallery();
              },
            ),
            if (hasExisting)
              PhotoActionTile(
                icon: AppIcons.deleteOutline,
                label: AppConstant.removePhoto,
                destructive: true,
                onTap: () {
                  Navigator.pop(sheetContext);
                  markPhotoRemoved();
                },
              ),
            8.height,
          ],
        );
      },
    );
  }

  Future<void> pickFromGallery() async {
    try {
      final file = await _photos.pickFromGallery();
      if (file == null) return;
      state = state.copyWith(localPhoto: file, removePhoto: false);
    } catch (e) {
      showAppToast(e.toString(), isError: true);
    }
  }

  Future<void> save({
    required String name,
    required String bio,
    required String phone,
    required String aboutMe,
    required String location,
  }) async {
    final profile = _currentProfile;
    if (profile == null) return;
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      showAppToast(AppConstant.nameRequired, isError: true);
      return;
    }
    if (state.saving) return;

    unfocusKeyboard();
    state = state.copyWith(saving: true);
    try {
      String? nextPhoto;
      if (state.removePhoto) {
        nextPhoto = '';
      } else if (state.localPhoto != null) {
        nextPhoto = await _photos.toBase64(state.localPhoto!);
      }

      await _users.updateProfile(
        uid: profile.uid,
        name: trimmedName,
        photoUrl: nextPhoto,
        bio: bio,
        phone: phone,
        aboutMe: aboutMe,
        location: location,
      );

      state = const ProfileEditState();
      showAppToast(
        nextPhoto != null
            ? AppConstant.photoUpdated
            : AppConstant.profileUpdated,
      );
      pop();
    } catch (e) {
      state = state.copyWith(saving: false);
      showAppToast(e.toString(), isError: true);
    }
  }

  Future<void> shareCurrent() async {
    final profile = _currentProfile;
    if (profile == null) return;
    await SharePlus.instance.share(
      ShareParams(
        text: AppConstant.shareFlumbleMessage(profile.flumbleCode),
        subject: AppConstant.shareFlumble,
      ),
    );
  }

  void copyFlumbleCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
  }

  String qrPayload(String flumbleCode) => _fumble.buildQrPayload(flumbleCode);

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
