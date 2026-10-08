import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../services/location/fumble_location_service.dart';
import '../../utils/constant.dart';
import '../models/public_fumble_profile.dart';
import '../models/user_profile.dart';
import 'repo_utils.dart';

/// Public `fumbleCodes` cards and live meeting place on the card.
class FumbleCodeRepository {
  FumbleCodeRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const _uuid = Uuid();

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> _codeRef(String code) =>
      _db.collection('fumbleCodes').doc(code.toUpperCase());

  /// Loads public profile fields for a fumble / QR code string.
  Future<Map<String, dynamic>?> fetchPublicProfileByCode(String code) async {
    final snap = await _codeRef(code).get();
    if (!snap.exists || snap.data() == null) return null;
    return snap.data();
  }

  /// Loads the latest public fumble profile for a user id.
  Future<PublicFumbleProfile?> fetchPublicProfile(String uid) async {
    final query = await _db
        .collection('fumbleCodes')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final data = query.docs.first.data();
    return PublicFumbleProfile(
      uid: uid,
      name: (data['name'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim() ?? '',
      photoUrl: data['photoUrl'] as String?,
      bio: RepoUtils.blankToNull(data['bio'] as String?),
      phone: RepoUtils.blankToNull(data['phone'] as String?),
      sharePhone: data['sharePhone'] as bool? ?? true,
      shareEmail: data['shareEmail'] as bool? ?? true,
      fumbleLocation: FumbleLocation.fromFirestore(data['fumbleLocation']),
      fumblePlace: RepoUtils.blankToNull(data['fumblePlace'] as String?),
    );
  }

  /// Creates the initial public fumble profile when a user account is created.
  Future<void> createPublicProfile(UserProfile profile) async {
    await _codeRef(profile.fumbleCode).set({
      'uid': profile.uid,
      'name': profile.name,
      'email': profile.publicEmail,
      'photoUrl': null,
      'bio': null,
      'phone': profile.publicPhone,
      'sharePhone': profile.sharePhone,
      'shareEmail': profile.shareEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates the public fumble profile from share-visibility fields.
  Future<void> updatePublicProfile({
    required String code,
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
    String? bio,
    String? phone,
    required bool sharePhone,
    required bool shareEmail,
  }) async {
    await _codeRef(code).set({
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'phone': phone,
      'sharePhone': sharePhone,
      'shareEmail': shareEmail,
      'aboutMe': FieldValue.delete(),
      'location': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deletePublicProfile(String code) async {
    if (code.isEmpty) return;
    await _codeRef(code).delete();
  }

  /// Publishes (or clears) meeting coordinates + place label on user + card.
  Future<void> publishMeetingPlace({
    required String uid,
    FumbleLocation? location,
  }) async {
    final userSnap = await _userRef(uid).get();
    if (!userSnap.exists || userSnap.data() == null) return;
    final current = UserProfile.fromMap(uid, userSnap.data()!);
    if (current.fumbleCode.isEmpty) return;

    final value = location?.toGeoPoint();
    final place = location == null
        ? null
        : await FumbleLocationService.placeLabel(location);
    final batch = _db.batch();
    batch.set(_userRef(uid), {
      'fumbleLocation': value,
      'fumblePlace': place,
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(_codeRef(current.fumbleCode), {
      'uid': uid,
      'fumbleLocation': value,
      'fumblePlace': place,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  /// Issues a new fumble code and rewrites the public card.
  Future<String> rotateFumbleCode(String uid) async {
    final userSnap = await _userRef(uid).get();
    if (!userSnap.exists || userSnap.data() == null) {
      throw StateError(AppConstant.profileMissing);
    }
    final current = UserProfile.fromMap(uid, userSnap.data()!);
    final next = _uuid.v4().replaceAll('-', '').substring(0, 12).toUpperCase();

    final batch = _db.batch();
    batch.update(_userRef(uid), {
      'fumbleCode': next,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
    batch.delete(_codeRef(current.fumbleCode));
    batch.set(_codeRef(next), {
      'uid': uid,
      'name': current.name,
      'email': current.publicEmail,
      'photoUrl': current.photoUrl,
      'bio': current.bio,
      'phone': current.publicPhone,
      'sharePhone': current.sharePhone,
      'shareEmail': current.shareEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return next;
  }
}
