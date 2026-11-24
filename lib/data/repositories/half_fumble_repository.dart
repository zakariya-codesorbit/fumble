import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'package:fumble/core/config/app_urls.dart';
import 'package:fumble/data/models/half_fumble.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/data/repositories/fumble_code_repository.dart';
import 'package:fumble/utils/constant.dart';

class HalfFumbleException implements Exception {
  HalfFumbleException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Firestore-backed Half Fumble invitations.
class HalfFumbleRepository {
  HalfFumbleRepository({
    FirebaseFirestore? db,
    FirebaseStorage? storage,
  })  : _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  static const invitationTtl = Duration(days: 30);

  CollectionReference<Map<String, dynamic>> _halfFumbles(String uid) =>
      _db.collection('users').doc(uid).collection('halfFumbles');

  CollectionReference<Map<String, dynamic>> get _invitations =>
      _db.collection('invitations');

  Stream<List<HalfFumble>> watchHalfFumbles(String ownerUid) {
    return _halfFumbles(ownerUid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => HalfFumble.fromMap(doc.id, doc.data()))
          .where((h) => h.status.isActive)
          .toList();
    });
  }

  Future<HalfFumble?> findActiveByEmail({
    required String ownerUid,
    required String normalizedEmail,
  }) async {
    try {
      final snap = await _halfFumbles(ownerUid)
          .where('normalizedEmail', isEqualTo: normalizedEmail)
          .limit(10)
          .get();
      for (final doc in snap.docs) {
        final item = HalfFumble.fromMap(doc.id, doc.data());
        if (item.status.isActive) return item;
      }
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw HalfFumbleException(AppConstant.halfFumblePermissionDenied);
      }
      rethrow;
    }
  }

  Future<List<HalfFumbleInvitation>> pendingInvitationsForEmail(
    String normalizedEmail,
  ) async {
    final query = _invitations
        .where('normalizedEmail', isEqualTo: normalizedEmail)
        .where('status', whereIn: [
          HalfFumbleStatus.invitationSent.firestoreValue,
          HalfFumbleStatus.pendingAcceptance.firestoreValue,
        ])
        .limit(20);
    // Prefer server so invites appear after relaunch / accept without stale cache.
    QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap = await query.get(const GetOptions(source: Source.server));
    } catch (_) {
      snap = await query.get();
    }
    return snap.docs
        .map((d) => HalfFumbleInvitation.fromMap(d.id, d.data()))
        .where((i) => i.canAccept)
        .toList();
  }

  Future<HalfFumbleInvitation?> getInvitation(String invitationId) async {
    final doc = await _invitations.doc(invitationId).get();
    if (!doc.exists || doc.data() == null) return null;
    return HalfFumbleInvitation.fromMap(doc.id, doc.data()!);
  }

  /// Creates a Half Fumble + invitation.
  /// Returns store URL (not installed) + app deep link (installed) + raw token
  /// for the installed-app link only (never stored in cleartext).
  Future<
      ({
        HalfFumble halfFumble,
        String storeUrl,
        String appLink,
        String invitedEmail,
        String rawToken,
      })> createAndInvite({
    required UserProfile inviter,
    required String name,
    required String email,
    required String phone,
    required String whatsApp,
    String? meetingLocation,
    DateTime? meetingDate,
    String? personalNote,
    File? localPhoto,
  }) async {
    final normalized = HalfFumble.normalizeEmail(email);
    if (name.trim().isEmpty) {
      throw HalfFumbleException(AppConstant.nameRequired);
    }
    if (!_isValidEmail(normalized)) {
      throw HalfFumbleException(AppConstant.emailInvalid);
    }
    if (normalized == HalfFumble.normalizeEmail(inviter.email)) {
      throw HalfFumbleException(AppConstant.halfFumbleCannotInviteSelf);
    }

    final ownerUid = FirebaseAuth.instance.currentUser?.uid ?? inviter.uid;
    if (ownerUid.isEmpty) {
      throw HalfFumbleException(AppConstant.authPleaseLogIn);
    }

    final existing = await findActiveByEmail(
      ownerUid: ownerUid,
      normalizedEmail: normalized,
    );
    if (existing != null) {
      throw HalfFumbleException(AppConstant.halfFumbleAlreadyInvited);
    }

    // Block if already fully connected via email match on connections (best-effort).
    final connections = await _db
        .collection('users')
        .doc(ownerUid)
        .collection('connections')
        .where('email', isEqualTo: normalized)
        .limit(1)
        .get();
    if (connections.docs.isNotEmpty) {
      throw HalfFumbleException(AppConstant.halfFumbleAlreadyConnected);
    }

    final halfId = _uuid.v4();
    final invitationId = _uuid.v4();
    final rawToken = _secureToken();
    final tokenHash = _hashToken(rawToken);
    final expiresAt = DateTime.now().add(invitationTtl);

    String? photoUrl;
    if (localPhoto != null) {
      photoUrl = await _uploadPhoto(
        ownerUid: ownerUid,
        halfFumbleId: halfId,
        file: localPhoto,
      );
    }

    final half = HalfFumble(
      id: halfId,
      inviterUserId: ownerUid,
      name: name.trim(),
      email: email.trim(),
      normalizedEmail: normalized,
      phone: phone.trim(),
      whatsApp: whatsApp.trim(),
      photoUrl: photoUrl,
      meetingLocation: meetingLocation?.trim().isEmpty == true
          ? null
          : meetingLocation?.trim(),
      meetingDate: meetingDate,
      personalNote:
          personalNote?.trim().isEmpty == true ? null : personalNote?.trim(),
      invitationId: invitationId,
      status: HalfFumbleStatus.invitationSent,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      expiresAt: expiresAt,
    );

    final batch = _db.batch();
    batch.set(_halfFumbles(ownerUid).doc(halfId), half.toCreateMap());
    batch.set(_invitations.doc(invitationId), {
      'inviterUserId': ownerUid,
      'inviterName': inviter.name,
      'inviterPhotoUrl': inviter.photoUrl,
      'invitedEmail': email.trim(),
      'normalizedEmail': normalized,
      'tokenHash': tokenHash,
      'halfFumbleId': halfId,
      'status': HalfFumbleStatus.invitationSent.firestoreValue,
      'meetingLocation': half.meetingLocation,
      'meetingDate': half.meetingDate == null
          ? null
          : Timestamp.fromDate(half.meetingDate!),
      'personalNote': half.personalNote,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'acceptedAt': null,
      'acceptedByUserId': null,
    });
    await batch.commit();

    return (
      halfFumble: half,
      storeUrl: AppUrls.halfFumbleBothStoresText,
      appLink: AppUrls.halfFumbleAppInviteUrl(
        invitationId: invitationId,
        token: rawToken,
      ),
      invitedEmail: email.trim(),
      rawToken: rawToken,
    );
  }

  Future<({String storeUrl, String appLink, String invitedEmail})>
      resendInvitation({
    required UserProfile inviter,
    required HalfFumble halfFumble,
  }) async {
    if (!halfFumble.status.canResend) {
      throw HalfFumbleException(AppConstant.halfFumbleCannotResend);
    }
    if (halfFumble.isExpired) {
      throw HalfFumbleException(AppConstant.halfFumbleInviteExpired);
    }

    final invitationId = halfFumble.invitationId ?? _uuid.v4();
    final rawToken = _secureToken();
    final tokenHash = _hashToken(rawToken);
    final expiresAt = DateTime.now().add(invitationTtl);

    final batch = _db.batch();
    batch.update(_halfFumbles(inviter.uid).doc(halfFumble.id), {
      'invitationId': invitationId,
      'status': HalfFumbleStatus.invitationSent.firestoreValue,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_invitations.doc(invitationId), {
      'inviterUserId': inviter.uid,
      'inviterName': inviter.name,
      'inviterPhotoUrl': inviter.photoUrl,
      'invitedEmail': halfFumble.email,
      'normalizedEmail': halfFumble.normalizedEmail,
      'tokenHash': tokenHash,
      'halfFumbleId': halfFumble.id,
      'status': HalfFumbleStatus.invitationSent.firestoreValue,
      'meetingLocation': halfFumble.meetingLocation,
      'meetingDate': halfFumble.meetingDate == null
          ? null
          : Timestamp.fromDate(halfFumble.meetingDate!),
      'personalNote': halfFumble.personalNote,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'acceptedAt': null,
      'acceptedByUserId': null,
    }, SetOptions(merge: true));
    await batch.commit();

    return (
      storeUrl: AppUrls.halfFumbleBothStoresText,
      appLink: AppUrls.halfFumbleAppInviteUrl(
        invitationId: invitationId,
        token: rawToken,
      ),
      invitedEmail: halfFumble.email,
    );
  }

  Future<void> revokeInvitation({
    required String ownerUid,
    required HalfFumble halfFumble,
  }) async {
    if (!halfFumble.status.canCancel) {
      throw HalfFumbleException(AppConstant.halfFumbleCannotCancel);
    }
    final batch = _db.batch();
    batch.update(_halfFumbles(ownerUid).doc(halfFumble.id), {
      'status': HalfFumbleStatus.revoked.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final invitationId = halfFumble.invitationId;
    if (invitationId != null && invitationId.isNotEmpty) {
      batch.set(_invitations.doc(invitationId), {
        'status': HalfFumbleStatus.revoked.firestoreValue,
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  /// Invitee accepts after email verification. Creates mutual connections.
  ///
  /// [rawToken] is optional: required only when opened via installed-app deep
  /// link. Email-recovery path authorizes via verified Auth email alone.
  Future<void> acceptInvitation({
    required UserProfile acceptor,
    required String invitationId,
    String? rawToken,
  }) async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null || !authUser.emailVerified) {
      throw HalfFumbleException(AppConstant.halfFumbleEmailRequired);
    }
    if (acceptor.email.trim().isEmpty) {
      throw HalfFumbleException(AppConstant.halfFumbleEmailRequired);
    }

    final invitation = await getInvitation(invitationId);
    if (invitation == null) {
      throw HalfFumbleException(AppConstant.halfFumbleInviteNotFound);
    }
    final token = rawToken?.trim() ?? '';
    if (token.isNotEmpty && _hashToken(token) != invitation.tokenHash) {
      throw HalfFumbleException(AppConstant.halfFumbleInviteInvalid);
    }
    if (!invitation.canAccept) {
      throw HalfFumbleException(
        invitation.isExpired
            ? AppConstant.halfFumbleInviteExpired
            : AppConstant.halfFumbleInviteUnavailable,
      );
    }

    final normalized = HalfFumble.normalizeEmail(
      authUser.email ?? acceptor.email,
    );
    if (normalized != invitation.normalizedEmail) {
      throw HalfFumbleException(AppConstant.halfFumbleEmailMismatch);
    }
    if (acceptor.uid == invitation.inviterUserId) {
      throw HalfFumbleException(AppConstant.halfFumbleCannotInviteSelf);
    }

    final existing = await _db
        .collection('users')
        .doc(acceptor.uid)
        .collection('connections')
        .doc(invitation.inviterUserId)
        .get();
    if (existing.exists) {
      // Idempotent — already connected.
      await _markAccepted(
        invitation: invitation,
        acceptor: acceptor,
      );
      return;
    }

    // Do not read users/{inviter} — private profile is owner-only.
    // Use invitation snapshot + public fumbleCodes card (readable when signed in).
    final publicInviter =
        await FumbleCodeRepository(firestore: _db).loadPublicProfile(
      invitation.inviterUserId,
    );
    final inviterUid = invitation.inviterUserId;
    final inviterName = (publicInviter?.name.trim().isNotEmpty == true)
        ? publicInviter!.name.trim()
        : invitation.inviterName.trim();
    if (inviterName.isEmpty) {
      throw HalfFumbleException(AppConstant.halfFumbleInviterMissing);
    }
    final inviterPhoto =
        publicInviter?.photoUrl ?? invitation.inviterPhotoUrl;
    final inviterEmail = publicInviter == null
        ? ''
        : (publicInviter.shareEmail ? publicInviter.email.trim() : '');
    final inviterPhone = publicInviter == null
        ? null
        : (publicInviter.sharePhone ? publicInviter.phone : null);
    final inviterWhatsApp = publicInviter == null
        ? null
        : (publicInviter.shareWhatsApp ? publicInviter.whatsApp : null);
    final inviterSharePhone = publicInviter?.sharePhone ?? true;
    final inviterShareEmail = publicInviter?.shareEmail ?? true;
    final inviterShareWhatsApp = publicInviter?.shareWhatsApp ?? true;

    final now = DateTime.now();
    final fumbledAt = invitation.meetingDate ?? now;
    final batch = _db.batch();

    // Acceptor → inviter card
    batch.set(
      _db
          .collection('users')
          .doc(acceptor.uid)
          .collection('connections')
          .doc(inviterUid),
      {
        'peerUid': inviterUid,
        'name': inviterName,
        'email': inviterEmail,
        'photoUrl': inviterPhoto,
        'bio': publicInviter?.bio,
        'location': publicInviter?.location,
        'phone': inviterPhone,
        'whatsApp': inviterWhatsApp,
        'sharePhone': inviterSharePhone,
        'shareEmail': inviterShareEmail,
        'shareWhatsApp': inviterShareWhatsApp,
        'note': invitation.personalNote,
        'noteUpdatedAt': invitation.personalNote == null
            ? null
            : Timestamp.fromDate(now),
        'fumblePlace': invitation.meetingLocation,
        'initiatedBy': inviterUid,
        'fumbledAt': Timestamp.fromDate(fumbledAt),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    // Inviter → acceptor card
    batch.set(
      _db
          .collection('users')
          .doc(inviterUid)
          .collection('connections')
          .doc(acceptor.uid),
      {
        'peerUid': acceptor.uid,
        'name': acceptor.name,
        'email': acceptor.publicEmail,
        'photoUrl': acceptor.photoUrl,
        'bio': acceptor.bio,
        'location': acceptor.location,
        'phone': acceptor.publicPhone,
        'whatsApp': acceptor.publicWhatsApp,
        'sharePhone': acceptor.sharePhone,
        'shareEmail': acceptor.shareEmail,
        'shareWhatsApp': acceptor.shareWhatsApp,
        'note': invitation.personalNote,
        'noteUpdatedAt': invitation.personalNote == null
            ? null
            : Timestamp.fromDate(now),
        'fumblePlace': invitation.meetingLocation,
        'initiatedBy': inviterUid,
        'fumbledAt': Timestamp.fromDate(fumbledAt),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    batch.update(
      _halfFumbles(inviterUid).doc(invitation.halfFumbleId),
      {
        'status': HalfFumbleStatus.fumbled.firestoreValue,
        'connectedUserId': acceptor.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    batch.update(_invitations.doc(invitationId), {
      'status': HalfFumbleStatus.fumbled.firestoreValue,
      'acceptedAt': FieldValue.serverTimestamp(),
      'acceptedByUserId': acceptor.uid,
    });

    await batch.commit();
  }

  Future<void> declineInvitation({
    required UserProfile acceptor,
    required String invitationId,
    String? rawToken,
  }) async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null || !authUser.emailVerified) {
      throw HalfFumbleException(AppConstant.halfFumbleEmailRequired);
    }
    final invitation = await getInvitation(invitationId);
    if (invitation == null) {
      throw HalfFumbleException(AppConstant.halfFumbleInviteNotFound);
    }
    final token = rawToken?.trim() ?? '';
    if (token.isNotEmpty && _hashToken(token) != invitation.tokenHash) {
      throw HalfFumbleException(AppConstant.halfFumbleInviteInvalid);
    }
    final normalized = HalfFumble.normalizeEmail(
      authUser.email ?? acceptor.email,
    );
    if (normalized != invitation.normalizedEmail) {
      throw HalfFumbleException(AppConstant.halfFumbleEmailMismatch);
    }

    final batch = _db.batch();
    batch.update(_invitations.doc(invitationId), {
      'status': HalfFumbleStatus.declined.firestoreValue,
    });
    batch.update(
      _halfFumbles(invitation.inviterUserId).doc(invitation.halfFumbleId),
      {
        'status': HalfFumbleStatus.declined.firestoreValue,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
    await batch.commit();
  }

  Future<void> markPendingAcceptance(String invitationId) async {
    await _invitations.doc(invitationId).set({
      'status': HalfFumbleStatus.pendingAcceptance.firestoreValue,
    }, SetOptions(merge: true));
  }

  Future<void> _markAccepted({
    required HalfFumbleInvitation invitation,
    required UserProfile acceptor,
  }) async {
    final batch = _db.batch();
    batch.update(_invitations.doc(invitation.id), {
      'status': HalfFumbleStatus.fumbled.firestoreValue,
      'acceptedAt': FieldValue.serverTimestamp(),
      'acceptedByUserId': acceptor.uid,
    });
    batch.update(
      _halfFumbles(invitation.inviterUserId).doc(invitation.halfFumbleId),
      {
        'status': HalfFumbleStatus.fumbled.firestoreValue,
        'connectedUserId': acceptor.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
    await batch.commit();
  }

  Future<String> _uploadPhoto({
    required String ownerUid,
    required String halfFumbleId,
    required File file,
  }) async {
    final ref = _storage
        .ref()
        .child('users')
        .child(ownerUid)
        .child('halfFumbles')
        .child(halfFumbleId)
        .child('photo.jpg');
    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  static String _secureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static String _hashToken(String rawToken) {
    return sha256.convert(utf8.encode(rawToken)).toString();
  }
}
