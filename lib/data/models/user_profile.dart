import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.flumbleCode,
    this.bio,
    this.phone,
    this.aboutMe,
    this.location,
    this.createdAt,
    this.lastActiveAt,
    this.fcmToken,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String flumbleCode;
  final String? bio;
  final String? phone;
  final String? aboutMe;
  final String? location;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;
  final String? fcmToken;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      name: (data['name'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim() ?? '',
      photoUrl: data['photoUrl'] as String?,
      flumbleCode: (data['flumbleCode'] as String?) ?? '',
      bio: (data['bio'] as String?)?.trim(),
      phone: (data['phone'] as String?)?.trim(),
      aboutMe: (data['aboutMe'] as String?)?.trim(),
      location: (data['location'] as String?)?.trim(),
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
      'flumbleCode': flumbleCode,
      'bio': bio,
      'phone': phone,
      'aboutMe': aboutMe,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? flumbleCode,
    String? bio,
    String? phone,
    String? aboutMe,
    String? location,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? fcmToken,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      flumbleCode: flumbleCode ?? this.flumbleCode,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      aboutMe: aboutMe ?? this.aboutMe,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
