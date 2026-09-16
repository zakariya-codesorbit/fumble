class FumblePreview {
  const FumblePreview({
    required this.peerUid,
    required this.name,
    this.email,
    this.photoUrl,
    this.bio,
    this.phone,
    this.aboutMe,
    this.location,
  });

  final String peerUid;
  final String name;
  final String? email;
  final String? photoUrl;
  final String? bio;
  final String? phone;
  final String? aboutMe;
  final String? location;

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

  factory FumblePreview.fromMap(Map<String, dynamic> data) {
    return FumblePreview(
      peerUid: (data['uid'] as String?) ??
          (data['peerUid'] as String?) ??
          '',
      name: (data['name'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim(),
      photoUrl: data['photoUrl'] as String?,
      bio: (data['bio'] as String?)?.trim(),
      phone: (data['phone'] as String?)?.trim(),
      aboutMe: (data['aboutMe'] as String?)?.trim(),
      location: (data['location'] as String?)?.trim(),
    );
  }
}
