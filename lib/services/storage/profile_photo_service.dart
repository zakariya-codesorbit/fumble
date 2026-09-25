import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Gallery pick + compress for profile photos (stored as base64 in Firestore).
/// No Firebase Storage — free Spark plan only.
class ProfilePhotoService {
  ProfilePhotoService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Keep small so the Firestore doc stays well under the 1 MB limit.
  static const int _maxDimension = 512;
  static const int _quality = 70;

  Future<File?> pickFromGallery() => _pick(ImageSource.gallery);

  Future<File?> pickFromCamera() => _pick(ImageSource.camera);

  Future<File?> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: _maxDimension.toDouble(),
      maxHeight: _maxDimension.toDouble(),
      imageQuality: 85,
    );
    if (picked == null) return null;

    final compressed = await _compress(File(picked.path));
    return compressed ?? File(picked.path);
  }

  Future<File?> _compress(File input) async {
    final dir = await getTemporaryDirectory();
    final target = p.join(
      dir.path,
      'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      input.absolute.path,
      target,
      quality: _quality,
      minWidth: _maxDimension,
      minHeight: _maxDimension,
      format: CompressFormat.jpeg,
    );
    if (result == null) return null;
    return File(result.path);
  }

  Future<String> toBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  static bool isSvg(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.trimLeft().startsWith('<svg') ||
        value.trimLeft().startsWith('<?xml');
  }

  static Uint8List? decodeBase64(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return null;
    }
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
