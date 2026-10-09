import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;

import 'package:fumble/core/config/app_config.dart';

/// Versioned QR payload. Generation and validation do not touch Firebase.
///
/// Payload is intentionally tiny for fast scans: fumble code + name only.
/// The Fumble app decrypts with the shared app key before reading fields.
abstract final class FumbleQr {
  /// v2 = fumbleCode + name only (current).
  static const int version = 2;

  /// Wire prefix for encrypted payloads: `fumble:2.<payload>`.
  static const String _wirePrefix = '${AppConfig.qrPrefix}$version.';

  static final enc.Key _key = enc.Key.fromUtf8(AppConfig.qrSecret);
  static final enc.Encrypter _aes = enc.Encrypter(
    enc.AES(_key, mode: enc.AESMode.cbc),
  );

  static String build({
    required String fumbleCode,
    required String name,
  }) {
    final code = fumbleCode.trim().toUpperCase();
    final trimmedName = name.trim();
    final payload = <String, dynamic>{
      'version': version,
      'fumbleCode': code,
      'name': trimmedName,
    };
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

    if (!map.containsKey('version') || map['version'] is! int) {
      return const fumbleQrDecodeResult.error(QrDecodeError.malformed);
    }
    final versionValue = map['version'] as int;
    if (versionValue != version) {
      return const fumbleQrDecodeResult.error(QrDecodeError.unsupportedVersion);
    }

    final code = _requiredString(map, 'fumbleCode');
    if (code == null || code.isEmpty) {
      return const fumbleQrDecodeResult.error(QrDecodeError.missingFumbleCode);
    }

    final name = _requiredString(map, 'name');
    if (name == null || name.isEmpty) {
      return const fumbleQrDecodeResult.error(QrDecodeError.missingName);
    }

    return fumbleQrDecodeResult.success(
      fumbleQrPayload(
        version: versionValue,
        fumbleCode: code.toUpperCase(),
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

  /// Decrypts `fumble:2.…` (and legacy `fumble:1.…`) payloads.
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

class fumbleQrPayload {
  const fumbleQrPayload({
    required this.version,
    required this.fumbleCode,
    required this.name,
  });

  final int version;
  final String fumbleCode;
  final String name;
}

enum QrDecodeError {
  invalid,
  malformed,
  unsupportedVersion,
  missingFumbleCode,
  missingName,
}

class fumbleQrDecodeResult {
  const fumbleQrDecodeResult.success(this.payload) : error = null;

  const fumbleQrDecodeResult.error(this.error) : payload = null;

  final fumbleQrPayload? payload;
  final QrDecodeError? error;
}
