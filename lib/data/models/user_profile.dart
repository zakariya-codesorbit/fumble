import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.fumbleCode,
    this.bio,
    this.aboutMe,
    this.location,
    this.phone,
    this.sharePhone = true,
    this.shareEmail = true,
    this.createdAt,
    this.lastActiveAt,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String fumbleCode;
  final String? bio;
  final String? aboutMe;
  final String? location;
  final String? phone;
  final bool sharePhone;
  final bool shareEmail;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }

  bool get hasPhoto => _filled(photoUrl);

  bool get hasPhone => _filled(phone);

  bool get hasBio => _filled(bio);

  bool get hasAboutMe => _filled(aboutMe);

  bool get hasLocation => _filled(location);

  bool get isOnboardingComplete => hasPhoto && hasPhone;

  /// Contact values exposed to connections / QR when sharing is on.
  String get publicEmail => shareEmail ? email.trim() : '';

  String? get publicPhone => sharePhone && _filled(phone) ? phone!.trim() : null;

  static bool _filled(String? value) =>
      value != null && value.trim().isNotEmpty;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      name: (data['name'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim() ?? '',
      photoUrl: data['photoUrl'] as String?,
      fumbleCode: (data['fumbleCode'] as String?) ?? '',
      bio: (data['bio'] as String?)?.trim(),
      aboutMe: (data['aboutMe'] as String?)?.trim(),
      location: (data['location'] as String?)?.trim(),
      phone: (data['phone'] as String?)?.trim(),
      sharePhone: data['sharePhone'] as bool? ?? true,
      shareEmail: data['shareEmail'] as bool? ?? true,
      createdAt: _asDateTime(data['createdAt']),
      lastActiveAt: _asDateTime(data['lastActiveAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'fumbleCode': fumbleCode,
      'bio': bio,
      'aboutMe': aboutMe,
      'location': location,
      'phone': phone,
      'sharePhone': sharePhone,
      'shareEmail': shareEmail,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? fumbleCode,
    String? bio,
    String? aboutMe,
    String? location,
    String? phone,
    bool? sharePhone,
    bool? shareEmail,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      fumbleCode: fumbleCode ?? this.fumbleCode,
      bio: bio ?? this.bio,
      aboutMe: aboutMe ?? this.aboutMe,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      sharePhone: sharePhone ?? this.sharePhone,
      shareEmail: shareEmail ?? this.shareEmail,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'fumbleCode': fumbleCode,
      'bio': bio,
      'aboutMe': aboutMe,
      'location': location,
      'phone': phone,
      'sharePhone': sharePhone,
      'shareEmail': shareEmail,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory UserProfile.fromCacheJson(Map<String, dynamic> json) {
    final createdAtMs = json['createdAt'];
    return UserProfile(
      uid: (json['uid'] as String?)?.trim() ?? '',
      name: (json['name'] as String?)?.trim() ?? '',
      email: (json['email'] as String?)?.trim() ?? '',
      photoUrl: json['photoUrl'] as String?,
      fumbleCode: (json['fumbleCode'] as String?) ?? '',
      bio: (json['bio'] as String?)?.trim(),
      aboutMe: (json['aboutMe'] as String?)?.trim(),
      location: (json['location'] as String?)?.trim(),
      phone: (json['phone'] as String?)?.trim(),
      sharePhone: json['sharePhone'] as bool? ?? true,
      shareEmail: json['shareEmail'] as bool? ?? true,
      createdAt: createdAtMs is int
          ? DateTime.fromMillisecondsSinceEpoch(createdAtMs)
          : null,
    );
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
