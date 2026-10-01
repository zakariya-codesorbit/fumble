import 'dart:convert';

/// Versioned QR payload. Generation and validation do not touch Firebase.
abstract final class FumbleQr {
  static const int version = 1;

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
    return jsonEncode(payload);
  }

  static fumbleQrDecodeResult decode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const fumbleQrDecodeResult.error(QrDecodeError.invalid);
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(trimmed);
    } catch (_) {
      return fumbleQrDecodeResult.error(
        trimmed.startsWith('{')
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
