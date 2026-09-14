import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/connection.dart';
import '../models/user_profile.dart';
import '../../utils/constant.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const _uuid = Uuid();

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> _codeRef(String code) =>
      _db.collection('flumbleCodes').doc(code.toUpperCase());

  Future<UserProfile?> getUser(String uid) async {
    final snap = await _userRef(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserProfile.fromMap(uid, snap.data()!);
  }

  Stream<UserProfile?> watchUser(String uid) {
    return _userRef(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProfile.fromMap(uid, snap.data()!);
    });
  }

  Future<Map<String, dynamic>?> getFlumbleCodeCard(String code) async {
    final snap = await _codeRef(code).get();
    if (!snap.exists || snap.data() == null) return null;
    return snap.data();
  }

  Future<UserProfile> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    final flumbleCode =
        _uuid.v4().replaceAll('-', '').substring(0, 12).toUpperCase();
    final profile = UserProfile(
      uid: uid,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      flumbleCode: flumbleCode,
    );

    final batch = _db.batch();
    batch.set(_userRef(uid), profile.toCreateMap());
    batch.set(_codeRef(flumbleCode), {
      'uid': uid,
      'name': profile.name,
      'email': profile.email,
      'photoUrl': null,
      'bio': null,
      'phone': null,
      'aboutMe': null,
      'location': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return profile;
  }

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? photoUrl,
    String? bio,
    String? phone,
    String? aboutMe,
    String? location,
  }) async {
    final userSnap = await _userRef(uid).get();
    if (!userSnap.exists || userSnap.data() == null) return;
    final current = UserProfile.fromMap(uid, userSnap.data()!);

    final data = <String, dynamic>{
      'lastActiveAt': FieldValue.serverTimestamp(),
    };
    if (name != null) data['name'] = name.trim();
    if (photoUrl != null) {
      data['photoUrl'] = photoUrl.isEmpty ? null : photoUrl;
    }
    if (bio != null) data['bio'] = bio.trim();
    if (phone != null) data['phone'] = phone.trim();
    if (aboutMe != null) data['aboutMe'] = aboutMe.trim();
    if (location != null) data['location'] = location.trim();

    final nextName = name?.trim() ?? current.name;
    final nextPhoto = photoUrl != null
        ? (photoUrl.isEmpty ? null : photoUrl)
        : current.photoUrl;
    final nextBio = bio?.trim() ?? current.bio;
    final nextPhone = phone?.trim() ?? current.phone;
    final nextAbout = aboutMe?.trim() ?? current.aboutMe;
    final nextLocation = location?.trim() ?? current.location;

    final batch = _db.batch();
    batch.update(_userRef(uid), data);
    batch.set(
      _codeRef(current.flumbleCode),
      {
        'uid': uid,
        'name': nextName,
        'email': current.email,
        'photoUrl': nextPhoto,
        'bio': nextBio,
        'phone': nextPhone,
        'aboutMe': nextAbout,
        'location': nextLocation,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<String> rotateFlumbleCode(String uid) async {
    final userSnap = await _userRef(uid).get();
    if (!userSnap.exists || userSnap.data() == null) {
      throw StateError(AppConstant.profileMissing);
    }
    final current = UserProfile.fromMap(uid, userSnap.data()!);
    final next =
        _uuid.v4().replaceAll('-', '').substring(0, 12).toUpperCase();

    final batch = _db.batch();
    batch.update(_userRef(uid), {
      'flumbleCode': next,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
    batch.delete(_codeRef(current.flumbleCode));
    batch.set(_codeRef(next), {
      'uid': uid,
      'name': current.name,
      'email': current.email,
      'photoUrl': current.photoUrl,
      'bio': current.bio,
      'phone': current.phone,
      'aboutMe': current.aboutMe,
      'location': current.location,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return next;
  }

  Future<void> updateFcmToken(String uid, String? token) async {
    await _userRef(uid).set({
      'fcmToken': token,
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> touchLastActive(String uid) async {
    await _userRef(uid).set({
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteUserDoc(String uid) async {
    final userSnap = await _userRef(uid).get();
    final code = userSnap.data()?['flumbleCode'] as String?;

    final connections = await _userRef(uid).collection('connections').get();
    final batch = _db.batch();
    for (final doc in connections.docs) {
      batch.delete(doc.reference);
    }
    if (code != null && code.isNotEmpty) {
      batch.delete(_codeRef(code));
    }
    batch.delete(_userRef(uid));
    await batch.commit();
  }
}

class ConnectionRepository {
  ConnectionRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _connections(String uid) =>
      _db.collection('users').doc(uid).collection('connections');

  Stream<List<Connection>> watchConnections(String uid) {
    return _connections(uid)
        .orderBy('fumbledAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Connection.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<bool> hasConnection({
    required String uid,
    required String peerUid,
  }) async {
    final snap = await _connections(uid).doc(peerUid).get();
    return snap.exists;
  }

  /// Creates both sides of a connection in one batch.
  Future<void> createMutualConnection({
    required UserProfile scanner,
    required FumblePeerCard peer,
  }) async {
    final fumbledAt = FieldValue.serverTimestamp();
    final batch = _db.batch();

    batch.set(
      _connections(scanner.uid).doc(peer.uid),
      {
        'peerUid': peer.uid,
        'name': peer.name,
        'email': peer.email,
        'photoUrl': peer.photoUrl,
        'fumbledAt': fumbledAt,
      },
      SetOptions(merge: true),
    );

    batch.set(
      _connections(peer.uid).doc(scanner.uid),
      {
        'peerUid': scanner.uid,
        'name': scanner.name,
        'email': scanner.email,
        'photoUrl': scanner.photoUrl,
        'fumbledAt': fumbledAt,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}

class FumblePeerCard {
  const FumblePeerCard({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
}
