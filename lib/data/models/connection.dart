import 'package:cloud_firestore/cloud_firestore.dart';

enum SyncStatus { pending, syncing, synced, failed }

class Connection {
  const Connection({
    required this.id,
    required this.peerUid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    this.phone,
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
  final String? phone;
  final DateTime fumbledAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  bool get hasBio => bio != null && bio!.trim().isNotEmpty;

  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;

  factory Connection.fromMap(String id, Map<String, dynamic> data) {
    final fumbledAt = _asDateTime(data['fumbledAt']) ?? DateTime.now();
    return Connection(
      id: id,
      peerUid: (data['peerUid'] as String?) ?? id,
      name: (data['name'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim() ?? '',
      photoUrl: data['photoUrl'] as String?,
      bio: _blankToNull(data['bio'] as String?),
      phone: _blankToNull(data['phone'] as String?),
      fumbledAt: fumbledAt,
      updatedAt: _asDateTime(data['updatedAt']) ?? fumbledAt,
      syncStatus: SyncStatus.synced,
    );
  }

  factory Connection.fromLocalRow(Map<String, Object?> row) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      row['created_at'] as int,
    );
    return Connection(
      id: row['peer_uid'] as String,
      peerUid: row['peer_uid'] as String,
      name: (row['name'] as String?)?.trim() ?? '',
      email: (row['email'] as String?)?.trim() ?? '',
      photoUrl: row['photo_url'] as String?,
      bio: _blankToNull(row['bio'] as String?),
      phone: _blankToNull(row['phone'] as String?),
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
      'phone': phone,
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
    String? phone,
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
      phone: phone ?? this.phone,
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
        phone == other.phone &&
        fumbledAt == other.fumbledAt &&
        syncStatus == other.syncStatus;
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
