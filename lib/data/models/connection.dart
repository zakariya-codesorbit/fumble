import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fumble/services/location/fumble_location_service.dart';

enum SyncStatus { pending, syncing, synced, failed }

class Connection {
  const Connection({
    required this.id,
    required this.peerUid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    this.location,
    this.phone,
    this.note,
    this.sharePhone = true,
    this.shareEmail = true,
    this.fumbleLocation,
    this.fumblePlace,
    required this.fumbledAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  final String id;
  final String peerUid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;
  /// Peer's profile location (city / place text).
  final String? location;
  final String? phone;
  /// Private note for the owner about this connection.
  final String? note;
  final bool sharePhone;
  final bool shareEmail;
  final FumbleLocation? fumbleLocation;
  /// Human-readable place (street/city) saved with the connection.
  final String? fumblePlace;
  final DateTime fumbledAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }

  bool get hasBio => bio != null && bio!.trim().isNotEmpty;

  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;

  /// Contact shown in the connections UI (respects peer share toggles).
  String get visibleEmail => shareEmail ? email.trim() : '';

  String? get visiblePhone =>
      sharePhone && hasPhone ? phone!.trim() : null;

  factory Connection.fromMap(String id, Map<String, dynamic> data) {
    final fumbledAt = _asDateTime(data['fumbledAt']) ?? DateTime.now();
    return Connection(
      id: id,
      peerUid: (data['peerUid'] as String?) ?? id,
      name: (data['name'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim() ?? '',
      photoUrl: data['photoUrl'] as String?,
      bio: _blankToNull(data['bio'] as String?),
      location: _blankToNull(data['location'] as String?),
      phone: _blankToNull(data['phone'] as String?),
      note: _blankToNull(data['note'] as String?),
      sharePhone: data['sharePhone'] as bool? ?? true,
      shareEmail: data['shareEmail'] as bool? ?? true,
      fumbleLocation: FumbleLocation.fromFirestore(data['fumbleLocation']),
      fumblePlace: _blankToNull(data['fumblePlace'] as String?),
      fumbledAt: fumbledAt,
      updatedAt: _asDateTime(data['updatedAt']) ?? fumbledAt,
      syncStatus: SyncStatus.synced,
    );
  }

  factory Connection.fromLocalRow(Map<String, Object?> row) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      row['created_at'] as int,
    );
    final lat = row['fumble_lat'];
    final lng = row['fumble_lng'];
    return Connection(
      id: row['peer_uid'] as String,
      peerUid: row['peer_uid'] as String,
      name: (row['name'] as String?)?.trim() ?? '',
      email: (row['email'] as String?)?.trim() ?? '',
      photoUrl: row['photo_url'] as String?,
      bio: _blankToNull(row['bio'] as String?),
      location: _blankToNull(row['location'] as String?),
      phone: _blankToNull(row['phone'] as String?),
      note: _blankToNull(row['note'] as String?),
      sharePhone: _boolFromSql(row['share_phone']),
      shareEmail: _boolFromSql(row['share_email']),
      fumbleLocation: lat is num && lng is num
          ? FumbleLocation(
              latitude: lat.toDouble(),
              longitude: lng.toDouble(),
            )
          : null,
      fumblePlace: _blankToNull(row['fumble_place'] as String?),
      fumbledAt: createdAt,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
      syncStatus: SyncStatus.values.firstWhere(
        (status) => status.name == row['sync_status'],
        orElse: () => SyncStatus.pending,
      ),
    );
  }

  Map<String, Object?> toLocalRow(String ownerUid) {
    return {
      'owner_uid': ownerUid,
      'peer_uid': peerUid,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'bio': bio,
      'location': location,
      'phone': phone,
      'note': note,
      'share_phone': sharePhone ? 1 : 0,
      'share_email': shareEmail ? 1 : 0,
      'fumble_lat': fumbleLocation?.latitude,
      'fumble_lng': fumbleLocation?.longitude,
      'fumble_place': fumblePlace,
      'created_at': fumbledAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_status': syncStatus.name,
    };
  }

  Connection copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
    String? location,
    bool clearLocation = false,
    String? phone,
    bool clearPhone = false,
    String? note,
    bool clearNote = false,
    bool? sharePhone,
    bool? shareEmail,
    FumbleLocation? fumbleLocation,
    bool clearFumbleLocation = false,
    String? fumblePlace,
    bool clearFumblePlace = false,
    DateTime? fumbledAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Connection(
      id: id,
      peerUid: peerUid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      location: clearLocation ? null : (location ?? this.location),
      phone: clearPhone ? null : (phone ?? this.phone),
      note: clearNote ? null : (note ?? this.note),
      sharePhone: sharePhone ?? this.sharePhone,
      shareEmail: shareEmail ?? this.shareEmail,
      fumbleLocation: clearFumbleLocation
          ? null
          : (fumbleLocation ?? this.fumbleLocation),
      fumblePlace: clearFumblePlace
          ? null
          : (fumblePlace ?? this.fumblePlace),
      fumbledAt: fumbledAt ?? this.fumbledAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  bool sameContent(Connection other) {
    return peerUid == other.peerUid &&
        name == other.name &&
        email == other.email &&
        photoUrl == other.photoUrl &&
        bio == other.bio &&
        location == other.location &&
        phone == other.phone &&
        note == other.note &&
        sharePhone == other.sharePhone &&
        shareEmail == other.shareEmail &&
        fumbleLocation?.latitude == other.fumbleLocation?.latitude &&
        fumbleLocation?.longitude == other.fumbleLocation?.longitude &&
        fumblePlace == other.fumblePlace &&
        fumbledAt == other.fumbledAt &&
        syncStatus == other.syncStatus;
  }

  static bool _boolFromSql(Object? value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    return true;
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
