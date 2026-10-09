import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;

import 'package:fumble/core/config/app_config.dart';

/// Versioned QR payload. Generation and validation do not touch Firebase.
///
/// Tiny payload for fast scans: user id + name.
/// Offline connect and online enrich both use [userId].
abstract final class FumbleQr {
  /// v4 = userId + name.
  static const int version = 4;

  /// Wire prefix for encrypted payloads: `fumble:4.<payload>`.
  static const String _wirePrefix = '${AppConfig.qrPrefix}$version.';

  static final enc.Key _key = enc.Key.fromUtf8(AppConfig.qrSecret);
  static final enc.Encrypter _aes = enc.Encrypter(
    enc.AES(_key, mode: enc.AESMode.cbc),
  );

  static String build({
    required String userId,
    required String name,
  }) {
    final payload = <String, dynamic>{
      'version': version,
      'userId': userId.trim(),
      'name': name.trim(),
    };
    return _encrypt(jsonEncode(payload));
  }

  static FumbleQrDecodeResult decode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const FumbleQrDecodeResult.error(QrDecodeError.invalid);
    }

    final plain = _decryptIfNeeded(trimmed);
    if (plain == null) {
      return const FumbleQrDecodeResult.error(QrDecodeError.invalid);
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(plain);
    } catch (_) {
      return FumbleQrDecodeResult.error(
        plain.startsWith('{')
            ? QrDecodeError.malformed
            : QrDecodeError.invalid,
      );
    }
    if (decoded is! Map) {
      return const FumbleQrDecodeResult.error(QrDecodeError.malformed);
    }

    final map = <String, dynamic>{};
    for (final entry in decoded.entries) {
      if (entry.key is! String) {
        return const FumbleQrDecodeResult.error(QrDecodeError.malformed);
      }
      map[entry.key as String] = entry.value;
    }

    if (!map.containsKey('version') || map['version'] is! int) {
      return const FumbleQrDecodeResult.error(QrDecodeError.malformed);
    }
    final versionValue = map['version'] as int;
    if (versionValue != version) {
      return const FumbleQrDecodeResult.error(QrDecodeError.unsupportedVersion);
    }

    final userId = _requiredString(map, 'userId');
    if (userId == null || userId.isEmpty) {
      return const FumbleQrDecodeResult.error(QrDecodeError.missingUserId);
    }

    final name = _requiredString(map, 'name');
    if (name == null || name.isEmpty) {
      return const FumbleQrDecodeResult.error(QrDecodeError.missingName);
    }

    return FumbleQrDecodeResult.success(
      FumbleQrPayload(
        version: versionValue,
        userId: userId,
        name: name,
      ),
    );
  }

  static String _encrypt(String plain) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypted = _aes.encrypt(plain, iv: iv);
    final bytes = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    return '$_wirePrefix${base64UrlEncode(bytes)}';
  }

  /// Decrypts `fumble:4.…` (and legacy `fumble:1.`–`fumble:3.` wire).
  static String? _decryptIfNeeded(String raw) {
    if (raw.startsWith(AppConfig.qrPrefix)) {
      final dot = raw.indexOf('.', AppConfig.qrPrefix.length);
      if (dot <= AppConfig.qrPrefix.length) return null;
      try {
        final packed = base64Url.decode(raw.substring(dot + 1));
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

  static String? _requiredString(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key) || map[key] == null) return null;
    final value = map[key];
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class FumbleQrPayload {
  const FumbleQrPayload({
    required this.version,
    required this.userId,
    required this.name,
  });

  final int version;
  final String userId;
  final String name;
}

enum QrDecodeError {
  invalid,
  malformed,
  unsupportedVersion,
  missingUserId,
  missingName,
}

class FumbleQrDecodeResult {
  const FumbleQrDecodeResult.success(this.payload) : error = null;

  const FumbleQrDecodeResult.error(this.error) : payload = null;

  final FumbleQrPayload? payload;
  final QrDecodeError? error;
}
