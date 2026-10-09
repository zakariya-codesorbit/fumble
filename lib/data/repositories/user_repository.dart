import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/user_profile.dart';
import 'fumble_code_repository.dart';

/// Private `users` profile documents (create / update / delete / tokens).
class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
    FumbleCodeRepository? fumbleCodes,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _codes = fumbleCodes ??
            FumbleCodeRepository(firestore: firestore ?? FirebaseFirestore.instance);

  final FirebaseFirestore _db;
  final FumbleCodeRepository _codes;
  static const _uuid = Uuid();

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  Future<UserProfile?> loadUserProfile(String uid) async {
    final snap = await _userRef(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserProfile.fromMap(uid, snap.data()!);
  }

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _userRef(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProfile.fromMap(uid, snap.data()!);
    });
  }

  Future<UserProfile> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    final fumbleCode = _uuid
        .v4()
        .replaceAll('-', '')
        .substring(0, 12)
        .toUpperCase();
    final profile = UserProfile(
      uid: uid,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      fumbleCode: fumbleCode,
    );

    await _userRef(uid).set(profile.toCreateMap());
    await _codes.createPublicProfile(profile);
    return profile;
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? photoUrl,
    String? bio,
    String? aboutMe,
    String? location,
    String? phone,
    bool? sharePhone,
    bool? shareEmail,
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
    if (aboutMe != null) data['aboutMe'] = aboutMe.trim();
    if (location != null) data['location'] = location.trim();
    if (phone != null) data['phone'] = phone.trim();
    if (sharePhone != null) data['sharePhone'] = sharePhone;
    if (shareEmail != null) data['shareEmail'] = shareEmail;

    final nextName = name?.trim() ?? current.name;
    final nextPhoto = photoUrl != null
        ? (photoUrl.isEmpty ? null : photoUrl)
        : current.photoUrl;
    final nextBio = bio?.trim() ?? current.bio;
    final nextAboutMe = aboutMe?.trim() ?? current.aboutMe;
    final nextLocation = location?.trim() ?? current.location;
    final nextPhone = phone?.trim() ?? current.phone;
    final nextSharePhone = sharePhone ?? current.sharePhone;
    final nextShareEmail = shareEmail ?? current.shareEmail;
    final publicEmail = nextShareEmail ? current.email.trim() : '';
    final publicPhone =
        nextSharePhone && nextPhone != null && nextPhone.trim().isNotEmpty
            ? nextPhone.trim()
            : null;

    final batch = _db.batch();
    batch.update(_userRef(uid), data);

    // Keep existing connections in sync with visibility preferences.
    final connections = await _userRef(uid).collection('connections').get();
    for (final doc in connections.docs) {
      final peerUid = doc.id;
      batch.set(_userRef(peerUid).collection('connections').doc(uid), {
        'peerUid': uid,
        'name': nextName,
        'email': publicEmail,
        'photoUrl': nextPhoto,
        'bio': nextBio,
        'aboutMe': nextAboutMe,
        'location': nextLocation,
        'phone': publicPhone,
        'sharePhone': nextSharePhone,
        'shareEmail': nextShareEmail,
      }, SetOptions(merge: true));
    }
    await batch.commit();

    await _codes.updatePublicProfile(
      code: current.fumbleCode,
      uid: uid,
      name: nextName,
      email: publicEmail,
      photoUrl: nextPhoto,
      bio: nextBio,
      aboutMe: nextAboutMe,
      location: nextLocation,
      phone: publicPhone,
      sharePhone: nextSharePhone,
      shareEmail: nextShareEmail,
      createdAt: current.createdAt,
    );
  }

  Future<void> updateUserFcmToken(String uid, String? token) async {
    await _userRef(uid).set({
      'fcmToken': token,
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserLastActive(String uid) async {
    await _userRef(uid).set({
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteUserProfile(String uid) async {
    final userSnap = await _userRef(uid).get();
    final code = userSnap.data()?['fumbleCode'] as String?;

    final connections = await _userRef(uid).collection('connections').get();
    final batch = _db.batch();
    for (final doc in connections.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_userRef(uid));
    await batch.commit();

    if (code != null && code.isNotEmpty) {
      await _codes.deletePublicProfile(code);
    }
  }
}
