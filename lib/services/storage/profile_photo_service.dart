import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_avatars.dart';
import 'package:fumble/utils/constant.dart';

/// Thrown when a photo cannot be kept under the Storage size limit.
class PhotoTooLargeException implements Exception {
  @override
  String toString() => AppConstant.photoTooLarge;
}

/// Gallery/camera pick, crop, then upload profile photos/avatars to Firebase Storage.
/// Firestore only stores the download URL in `photoUrl`.
class ProfilePhotoService {
  ProfilePhotoService({
    ImagePicker? picker,
    ImageCropper? cropper,
    FirebaseStorage? storage,
  })  : _picker = picker ?? ImagePicker(),
        _cropper = cropper ?? ImageCropper(),
        _storage = storage ?? FirebaseStorage.instance;

  final ImagePicker _picker;
  final ImageCropper _cropper;
  final FirebaseStorage _storage;

  /// Must stay in sync with `storage/storage.rules`.
  static const int maxBytes = 2 * 1024 * 1024;
  static const int _pickMaxDimension = 1024;

  Future<File?> pickFromGallery() => _pick(ImageSource.gallery);

  Future<File?> pickFromCamera() => _pick(ImageSource.camera);

  Future<File?> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      // Keep source large enough for a clean crop; we resize after crop.
      imageQuality: 95,
    );
    if (picked == null) return null;

    final cropped = await _crop(picked.path);
    if (cropped == null) return null;

    // Use dart:io temp (not path_provider) — avoids the jni 1.2.0
    // ClassNotFoundException: Landroid/content/Context; crash on Android.
    final dest = File(
      p.join(
        Directory.systemTemp.path,
        'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    );
    await File(cropped.path).copy(dest.path);
    await _ensureUnderLimit(dest);
    return dest;
  }

  Future<CroppedFile?> _crop(String sourcePath) {
    return _cropper.cropImage(
      sourcePath: sourcePath,
      maxWidth: _pickMaxDimension,
      maxHeight: _pickMaxDimension,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppConstant.cropPhotoTitle,
          toolbarColor: AppColors.background,
          statusBarLight: false,
          navBarLight: false,
          toolbarWidgetColor: AppColors.primary,
          activeControlsWidgetColor: AppColors.primary,
          backgroundColor: AppColors.background,
          dimmedLayerColor: const Color(0xCC000000),
          cropFrameColor: AppColors.primary,
          cropGridColor: AppColors.primaryMuted,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: false,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(
          title: AppConstant.cropPhotoTitle,
          doneButtonTitle: AppConstant.cropPhotoDone,
          cancelButtonTitle: AppConstant.cropPhotoCancel,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
      ],
    );
  }

  Future<void> _ensureUnderLimit(File file) async {
    if (await file.length() > maxBytes) {
      throw PhotoTooLargeException();
    }
  }

  /// Uploads a camera/gallery JPEG and returns its download URL.
  Future<String> uploadProfilePhoto({
    required String uid,
    required File file,
    String? previousPhotoUrl,
  }) async {
    await _ensureUnderLimit(file);
    final ref = _profileObject(uid, 'photo.jpg');
    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final url = await ref.getDownloadURL();
    await deleteIfStorageUrl(previousPhotoUrl, keepPath: ref.fullPath);
    return url;
  }

  /// Uploads a bundled avatar PNG and returns its download URL.
  Future<String> uploadAvatarAsset({
    required String uid,
    required String assetPath,
    String? previousPhotoUrl,
  }) async {
    final resolved = AppAvatars.resolve(assetPath) ?? assetPath;
    final data = await rootBundle.load(resolved);
    final bytes = data.buffer.asUint8List();
    if (bytes.lengthInBytes > maxBytes) {
      throw PhotoTooLargeException();
    }
    final fileName = p.basename(resolved);
    final ref = _profileObject(uid, fileName);
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/png'),
    );
    final url = await ref.getDownloadURL();
    await deleteIfStorageUrl(previousPhotoUrl, keepPath: ref.fullPath);
    return url;
  }

  /// Best-effort delete of a previous Storage object (e.g. on remove photo).
  Future<void> deleteIfStorageUrl(
    String? photoUrl, {
    String? keepPath,
  }) async {
    if (!isStorageUrl(photoUrl)) return;
    try {
      final ref = _storage.refFromURL(photoUrl!);
      if (keepPath != null && ref.fullPath == keepPath) return;
      await ref.delete();
    } catch (_) {
      // Ignore missing/unauthorized objects — profile update still proceeds.
    }
  }

  Reference _profileObject(String uid, String fileName) {
    return _storage
        .ref()
        .child('users')
        .child(uid)
        .child('profile')
        .child(fileName);
  }

  static bool isStorageUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.contains('firebasestorage.googleapis.com') ||
        value.contains('firebasestorage.app');
  }

  /// Legacy helper — older profiles may still store base64 in Firestore.
  static Uint8List? decodeBase64(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return null;
    }
    if (value.startsWith('assets/')) return null;
    try {
      final raw = value.contains(',') ? value.split(',').last : value;
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  static bool isNetworkUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.startsWith('http://') || value.startsWith('https://');
  }
}
