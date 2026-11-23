import 'package:cloud_firestore/cloud_firestore.dart';

/// Lifecycle of an invite-based Half Fumble contact.
enum HalfFumbleStatus {
  /// Contact saved; invitation not shared yet.
  halfFumble,
  /// Invitation created and shared.
  invitationSent,
  /// Invitee registered / opened invite; not accepted.
  pendingAcceptance,
  /// Converted into a normal Fumbled connection.
  fumbled,
  declined,
  expired,
  revoked,
}

extension HalfFumbleStatusX on HalfFumbleStatus {
  String get firestoreValue => name;

  static HalfFumbleStatus fromFirestore(String? raw) {
    return HalfFumbleStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => HalfFumbleStatus.halfFumble,
    );
  }

  bool get isActive =>
      this == HalfFumbleStatus.halfFumble ||
      this == HalfFumbleStatus.invitationSent ||
      this == HalfFumbleStatus.pendingAcceptance;

  bool get canResend =>
      this == HalfFumbleStatus.invitationSent ||
      this == HalfFumbleStatus.pendingAcceptance ||
      this == HalfFumbleStatus.halfFumble;

  bool get canCancel => isActive;
}

/// Invite-based contact for someone who does not yet have a Fumble account.
class HalfFumble {
  const HalfFumble({
    required this.id,
    required this.inviterUserId,
    required this.name,
    required this.email,
    required this.normalizedEmail,
    required this.phone,
    required this.whatsApp,
    this.photoUrl,
    this.meetingLocation,
    this.meetingDate,
    this.personalNote,
    this.invitationId,
    this.connectedUserId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  final String id;
  final String inviterUserId;
  final String name;
  final String email;
  final String normalizedEmail;
  final String phone;
  final String whatsApp;
  final String? photoUrl;
  final String? meetingLocation;
  final DateTime? meetingDate;
  final String? personalNote;
  final String? invitationId;
  final String? connectedUserId;
  final HalfFumbleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }

  bool get isExpired {
    final expires = expiresAt;
    if (expires == null) return status == HalfFumbleStatus.expired;
    return DateTime.now().isAfter(expires);
  }

  factory HalfFumble.fromMap(String id, Map<String, dynamic> data) {
    return HalfFumble(
      id: id,
      inviterUserId: (data['inviterUserId'] as String?)?.trim() ?? '',
      name: (data['name'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim() ?? '',
      normalizedEmail: (data['normalizedEmail'] as String?)?.trim() ?? '',
      phone: (data['phone'] as String?)?.trim() ?? '',
      whatsApp: (data['whatsApp'] as String?)?.trim() ?? '',
      photoUrl: data['photoUrl'] as String?,
      meetingLocation: (data['meetingLocation'] as String?)?.trim(),
      meetingDate: asDateTime(data['meetingDate']),
      personalNote: (data['personalNote'] as String?)?.trim(),
      invitationId: data['invitationId'] as String?,
      connectedUserId: data['connectedUserId'] as String?,
      status: HalfFumbleStatusX.fromFirestore(data['status'] as String?),
      createdAt: asDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: asDateTime(data['updatedAt']) ?? DateTime.now(),
      expiresAt: asDateTime(data['expiresAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'inviterUserId': inviterUserId,
      'name': name,
      'email': email,
      'normalizedEmail': normalizedEmail,
      'phone': phone,
      'whatsApp': whatsApp,
      'photoUrl': photoUrl,
      'meetingLocation': meetingLocation,
      'meetingDate': meetingDate == null
          ? null
          : Timestamp.fromDate(meetingDate!),
      'personalNote': personalNote,
      'invitationId': invitationId,
      'connectedUserId': connectedUserId,
      'status': status.firestoreValue,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'expiresAt': expiresAt == null ? null : Timestamp.fromDate(expiresAt!),
    };
  }

  HalfFumble copyWith({
    String? name,
    String? email,
    String? normalizedEmail,
    String? phone,
    String? whatsApp,
    String? photoUrl,
    String? meetingLocation,
    DateTime? meetingDate,
    String? personalNote,
    String? invitationId,
    String? connectedUserId,
    HalfFumbleStatus? status,
    DateTime? updatedAt,
    DateTime? expiresAt,
    bool clearPhoto = false,
    bool clearMeetingDate = false,
  }) {
    return HalfFumble(
      id: id,
      inviterUserId: inviterUserId,
      name: name ?? this.name,
      email: email ?? this.email,
      normalizedEmail: normalizedEmail ?? this.normalizedEmail,
      phone: phone ?? this.phone,
      whatsApp: whatsApp ?? this.whatsApp,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      meetingLocation: meetingLocation ?? this.meetingLocation,
      meetingDate: clearMeetingDate ? null : (meetingDate ?? this.meetingDate),
      personalNote: personalNote ?? this.personalNote,
      invitationId: invitationId ?? this.invitationId,
      connectedUserId: connectedUserId ?? this.connectedUserId,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  static DateTime? asDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static String normalizeEmail(String email) => email.trim().toLowerCase();
}

/// Public invitation document used to resolve / accept Half Fumbles.
class HalfFumbleInvitation {
  const HalfFumbleInvitation({
    required this.id,
    required this.inviterUserId,
    required this.inviterName,
    this.inviterPhotoUrl,
    required this.invitedEmail,
    required this.normalizedEmail,
    required this.tokenHash,
    required this.halfFumbleId,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.acceptedAt,
    this.acceptedByUserId,
    this.meetingLocation,
    this.meetingDate,
    this.personalNote,
  });

  final String id;
  final String inviterUserId;
  final String inviterName;
  final String? inviterPhotoUrl;
  final String invitedEmail;
  final String normalizedEmail;
  final String tokenHash;
  final String halfFumbleId;
  final HalfFumbleStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final String? acceptedByUserId;
  final String? meetingLocation;
  final DateTime? meetingDate;
  final String? personalNote;

  bool get isExpired =>
      DateTime.now().isAfter(expiresAt) || status == HalfFumbleStatus.expired;

  bool get canAccept =>
      !isExpired &&
      (status == HalfFumbleStatus.invitationSent ||
          status == HalfFumbleStatus.pendingAcceptance);

  factory HalfFumbleInvitation.fromMap(String id, Map<String, dynamic> data) {
    return HalfFumbleInvitation(
      id: id,
      inviterUserId: (data['inviterUserId'] as String?)?.trim() ?? '',
      inviterName: (data['inviterName'] as String?)?.trim() ?? '',
      inviterPhotoUrl: data['inviterPhotoUrl'] as String?,
      invitedEmail: (data['invitedEmail'] as String?)?.trim() ?? '',
      normalizedEmail: (data['normalizedEmail'] as String?)?.trim() ?? '',
      tokenHash: (data['tokenHash'] as String?)?.trim() ?? '',
      halfFumbleId: (data['halfFumbleId'] as String?)?.trim() ?? '',
      status: HalfFumbleStatusX.fromFirestore(data['status'] as String?),
      createdAt: HalfFumble.asDateTime(data['createdAt']) ?? DateTime.now(),
      expiresAt: HalfFumble.asDateTime(data['expiresAt']) ??
          DateTime.now().add(const Duration(days: 30)),
      acceptedAt: HalfFumble.asDateTime(data['acceptedAt']),
      acceptedByUserId: data['acceptedByUserId'] as String?,
      meetingLocation: (data['meetingLocation'] as String?)?.trim(),
      meetingDate: HalfFumble.asDateTime(data['meetingDate']),
      personalNote: (data['personalNote'] as String?)?.trim(),
    );
  }
}
