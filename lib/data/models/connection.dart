import 'package:cloud_firestore/cloud_firestore.dart';

class Connection {
  const Connection({
    required this.id,
    required this.peerUid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.fumbledAt,
  });

  final String id;
  final String peerUid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime fumbledAt;

  factory Connection.fromMap(String id, Map<String, dynamic> data) {
    return Connection(
      id: id,
      peerUid: (data['peerUid'] as String?) ?? '',
      name: (data['name'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim() ?? '',
      photoUrl: data['photoUrl'] as String?,
      fumbledAt: _asDateTime(data['fumbledAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
