import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_avatars.dart';
import 'package:fumble/utils/constant.dart';

/// Thrown when a photo cannot be compressed under the Storage size limit.
class PhotoTooLargeException implements Exception {
  @override
  String toString() => AppConstant.photoTooLarge;
}

/// Gallery/camera pick + compress, then upload profile photos/avatars to
/// Firebase Storage. Firestore only stores the download URL in `photoUrl`.
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
  static const int _outputSize = 512;
  static const int _pickMaxDimension = 2048;
  static const int _minQuality = 40;

  Future<File?> pickFromGallery() => _pick(ImageSource.gallery);

  Future<File?> pickFromCamera() => _pick(ImageSource.camera);

  Future<File?> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: _pickMaxDimension.toDouble(),
      maxHeight: _pickMaxDimension.toDouble(),
      imageQuality: 95,
    );
    if (picked == null) return null;

    // Let the user manually position / zoom / rotate before we compress.
    final cropped = await _cropManually(picked.path);
    if (cropped == null) return null;

    return _compressUnderLimit(File(cropped.path));
  }

  /// Manual circle crop (1:1) so profile photos match avatar size (512×512).
  Future<CroppedFile?> _cropManually(String sourcePath) {
    return _cropper.cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: _outputSize,
      maxHeight: _outputSize,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppConstant.cropPhoto,
          toolbarColor: AppColors.background,
          toolbarWidgetColor: AppColors.white,
          backgroundColor: AppColors.background,
          activeControlsWidgetColor: AppColors.gold,
          statusBarLight: false,
          navBarLight: false,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: false,
          showCropGrid: true,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(
          title: AppConstant.cropPhoto,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
          rotateButtonsHidden: false,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
      ],
    );
  }

  /// Compresses until the file is ≤ [maxBytes], or throws [PhotoTooLargeException].
  Future<File> _compressUnderLimit(File input) async {
    var quality = 85;
    var dimension = _outputSize;
    File? best;

    while (quality >= _minQuality) {
      final compressed = await _compressOnce(
        input,
        quality: quality,
        dimension: dimension,
      );
      if (compressed != null) {
        best = compressed;
        if (await compressed.length() <= maxBytes) return compressed;
      }

      quality -= 15;
      if (quality < 55 && dimension > 384) {
        dimension = 384;
      } else if (quality < 45 && dimension > 256) {
        dimension = 256;
      }
    }

    if (best != null && await best.length() <= maxBytes) return best;
    throw PhotoTooLargeException();
  }

  Future<File?> _compressOnce(
    File input, {
    required int quality,
    required int dimension,
  }) async {
    final dir = await getTemporaryDirectory();
    final target = p.join(
      dir.path,
      'avatar_${DateTime.now().millisecondsSinceEpoch}_q$quality.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      input.absolute.path,
      target,
      quality: quality,
      minWidth: dimension,
      minHeight: dimension,
      format: CompressFormat.jpeg,
    );
    if (result == null) return null;
    return File(result.path);
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
