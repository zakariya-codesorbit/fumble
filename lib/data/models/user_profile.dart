import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.fumbleCode,
    this.bio,
    this.phone,
    this.createdAt,
    this.lastActiveAt,
    this.fcmToken,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String fumbleCode;
  final String? bio;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;
  final String? fcmToken;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }

  bool get hasPhoto => _filled(photoUrl);

  bool get hasPhone => _filled(phone);

  bool get hasBio => _filled(bio);

  bool get isOnboardingComplete => hasPhoto && hasPhone;

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
      phone: (data['phone'] as String?)?.trim(),
      createdAt: _asDateTime(data['createdAt']),
      lastActiveAt: _asDateTime(data['lastActiveAt']),
      fcmToken: data['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'fumbleCode': fumbleCode,
      'bio': bio,
      'phone': phone,
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
    String? phone,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? fcmToken,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      fumbleCode: fumbleCode ?? this.fumbleCode,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      fcmToken: fcmToken ?? this.fcmToken,
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
      'phone': phone,
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
      phone: (json['phone'] as String?)?.trim(),
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
