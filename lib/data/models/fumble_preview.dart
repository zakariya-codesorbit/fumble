class FumblePreview {
  const FumblePreview({
    required this.fumbleCode,
    required this.name,
    this.peerUid = '',
    this.email,
    this.photoUrl,
    this.bio,
    this.aboutMe,
    this.location,
    this.phone,
    this.createdAt,
  });

  final String fumbleCode;
  final String name;
  /// Empty until Firebase enrich resolves the public card.
  final String peerUid;
  final String? email;
  final String? photoUrl;
  final String? bio;
  final String? aboutMe;
  final String? location;
  final String? phone;
  final DateTime? createdAt;

  bool get isResolved => peerUid.trim().isNotEmpty;

  /// Builds a preview from a `fumbleCodes` Firestore document map.
  factory FumblePreview.fromMap(Map<String, dynamic> data) {
    final sharePhone = data['sharePhone'] as bool? ?? true;
    final shareEmail = data['shareEmail'] as bool? ?? true;
    final phone = (data['phone'] as String?)?.trim();
    final email = (data['email'] as String?)?.trim();
    final rawCreated = data['createdAt'];
    DateTime? createdAt;
    if (rawCreated is DateTime) {
      createdAt = rawCreated;
    } else if (rawCreated != null) {
      try {
        createdAt = (rawCreated as dynamic).toDate() as DateTime?;
      } catch (_) {}
    }
    return FumblePreview(
      fumbleCode: (data['fumbleCode'] as String?)?.trim().toUpperCase() ?? '',
      name: (data['name'] as String?)?.trim() ?? '',
      peerUid: (data['uid'] as String?)?.trim() ?? '',
      email: shareEmail && email != null && email.isNotEmpty ? email : null,
      photoUrl: data['photoUrl'] as String?,
      bio: _blankToNull(data['bio'] as String?),
      aboutMe: _blankToNull(data['aboutMe'] as String?),
      location: _blankToNull(data['location'] as String?),
      phone: sharePhone && phone != null && phone.isNotEmpty ? phone : null,
      createdAt: createdAt,
    );
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }

  bool get hasEmail => _filled(email);

  bool get hasPhone => _filled(phone);

  bool get hasBio => _filled(bio);

  bool get hasAboutMe => _filled(aboutMe);

  bool get hasLocation => _filled(location);

  static bool _filled(String? value) =>
      value != null && value.trim().isNotEmpty;

  FumblePreview copyWith({
    String? fumbleCode,
    String? name,
    String? peerUid,
    String? email,
    String? photoUrl,
    String? bio,
    String? aboutMe,
    String? location,
    String? phone,
    DateTime? createdAt,
    bool clearEmail = false,
    bool clearPhotoUrl = false,
    bool clearBio = false,
    bool clearAboutMe = false,
    bool clearLocation = false,
    bool clearPhone = false,
    bool clearCreatedAt = false,
  }) {
    return FumblePreview(
      fumbleCode: fumbleCode ?? this.fumbleCode,
      name: name ?? this.name,
      peerUid: peerUid ?? this.peerUid,
      email: clearEmail ? null : (email ?? this.email),
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      bio: clearBio ? null : (bio ?? this.bio),
      aboutMe: clearAboutMe ? null : (aboutMe ?? this.aboutMe),
      location: clearLocation ? null : (location ?? this.location),
      phone: clearPhone ? null : (phone ?? this.phone),
      createdAt: clearCreatedAt ? null : (createdAt ?? this.createdAt),
    );
  }
}
