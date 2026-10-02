import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;

import 'package:fumble/core/config/app_config.dart';

/// Versioned QR payload. Generation and validation do not touch Firebase.
///
/// Built codes are AES-encrypted so a generic scanner only sees ciphertext.
/// The Fumble app decrypts with the shared app key before reading fields.
abstract final class FumbleQr {
  static const int version = 1;

  /// Wire prefix for encrypted payloads: `fumble:1.<payload>`.
  static const String _wirePrefix = '${AppConfig.qrPrefix}$version.';

  static final enc.Key _key = enc.Key.fromUtf8(AppConfig.qrSecret);
  static final enc.Encrypter _aes = enc.Encrypter(
    enc.AES(_key, mode: enc.AESMode.cbc),
  );

  static String build({
    required String userId,
    required String name,
    String? bio,
    String? phone,
    String? email,
  }) {
    final payload = <String, dynamic>{
      'version': version,
      'userId': userId.trim(),
      'name': name.trim(),
    };
    final trimmedBio = bio?.trim();
    if (trimmedBio != null && trimmedBio.isNotEmpty) {
      payload['bio'] = trimmedBio;
    }
    final trimmedPhone = phone?.trim();
    if (trimmedPhone != null && trimmedPhone.isNotEmpty) {
      payload['phone'] = trimmedPhone;
    }
    final trimmedEmail = email?.trim();
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) {
      payload['email'] = trimmedEmail;
    }
    return _encrypt(jsonEncode(payload));
  }

  static fumbleQrDecodeResult decode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const fumbleQrDecodeResult.error(QrDecodeError.invalid);
    }

    final plain = _decryptIfNeeded(trimmed);
    if (plain == null) {
      return const fumbleQrDecodeResult.error(QrDecodeError.invalid);
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(plain);
    } catch (_) {
      return fumbleQrDecodeResult.error(
        plain.startsWith('{')
            ? QrDecodeError.malformed
            : QrDecodeError.invalid,
      );
    }
    if (decoded is! Map) {
      return const fumbleQrDecodeResult.error(QrDecodeError.malformed);
    }

    final map = <String, dynamic>{};
    for (final entry in decoded.entries) {
      if (entry.key is! String) {
        return const fumbleQrDecodeResult.error(QrDecodeError.malformed);
      }
      map[entry.key as String] = entry.value;
    }

    if (!map.containsKey('version')) {
      return const fumbleQrDecodeResult.error(QrDecodeError.malformed);
    }
    final versionValue = map['version'];
    if (versionValue is! int) {
      return const fumbleQrDecodeResult.error(QrDecodeError.malformed);
    }
    if (versionValue != version) {
      return const fumbleQrDecodeResult.error(QrDecodeError.unsupportedVersion);
    }

    if (!map.containsKey('userId') || map['userId'] == null) {
      return const fumbleQrDecodeResult.error(QrDecodeError.missingUserId);
    }
    if (map['userId'] is! String) {
      return const fumbleQrDecodeResult.error(QrDecodeError.malformed);
    }
    final userId = (map['userId'] as String).trim();
    if (userId.isEmpty) {
      return const fumbleQrDecodeResult.error(QrDecodeError.missingUserId);
    }

    if (!map.containsKey('name') || map['name'] == null) {
      return const fumbleQrDecodeResult.error(QrDecodeError.missingName);
    }
    if (map['name'] is! String) {
      return const fumbleQrDecodeResult.error(QrDecodeError.malformed);
    }
    final name = (map['name'] as String).trim();
    if (name.isEmpty) {
      return const fumbleQrDecodeResult.error(QrDecodeError.missingName);
    }

    final bio = _optionalString(map, 'bio');
    if (bio.invalid) {
      return const fumbleQrDecodeResult.error(QrDecodeError.malformed);
    }
    final phone = _optionalString(map, 'phone');
    if (phone.invalid) {
      return const fumbleQrDecodeResult.error(QrDecodeError.malformed);
    }
    final email = _optionalString(map, 'email');
    if (email.invalid) {
      return const fumbleQrDecodeResult.error(QrDecodeError.malformed);
    }

    return fumbleQrDecodeResult.success(
      fumbleQrPayload(
        version: versionValue,
        userId: userId,
        name: name,
        bio: bio.value,
        phone: phone.value,
        email: email.value,
      ),
    );
  }

  static String _encrypt(String plain) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypted = _aes.encrypt(plain, iv: iv);
    final bytes = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    return '$_wirePrefix${base64UrlEncode(bytes)}';
  }

  /// Decrypts `fumble:1.…` payloads. Plain JSON is kept for older codes.
  static String? _decryptIfNeeded(String raw) {
    if (raw.startsWith(_wirePrefix)) {
      try {
        final packed = base64Url.decode(raw.substring(_wirePrefix.length));
        if (packed.length <= 16) return null;
        final iv = enc.IV(Uint8List.fromList(packed.sublist(0, 16)));
        final cipher = enc.Encrypted(
          Uint8List.fromList(packed.sublist(16)),
        );
        return _aes.decrypt(cipher, iv: iv);
      } catch (_) {
        return null;
      }
    }
    if (raw.startsWith('{')) return raw;
    return null;
  }

  static ({String? value, bool invalid}) _optionalString(
    Map<String, dynamic> map,
    String key,
  ) {
    if (!map.containsKey(key) || map[key] == null) {
      return (value: null, invalid: false);
    }
    final value = map[key];
    if (value is! String) return (value: null, invalid: true);
    final trimmed = value.trim();
    return (value: trimmed.isEmpty ? null : trimmed, invalid: false);
  }
}

class fumbleQrPayload {
  const fumbleQrPayload({
    required this.version,
    required this.userId,
    required this.name,
    this.bio,
    this.phone,
    this.email,
  });

  final int version;
  final String userId;
  final String name;
  final String? bio;
  final String? phone;
  final String? email;
}

enum QrDecodeError {
  invalid,
  malformed,
  unsupportedVersion,
  missingUserId,
  missingName,
}

class fumbleQrDecodeResult {
  const fumbleQrDecodeResult.success(this.payload) : error = null;

  const fumbleQrDecodeResult.error(this.error) : payload = null;

  final fumbleQrPayload? payload;
  final QrDecodeError? error;
}
