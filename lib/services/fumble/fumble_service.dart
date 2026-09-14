import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/db/pending_fumble_repository.dart';
import '../../data/models/fumble_preview.dart';
import '../../data/models/pending_fumble_op.dart';
import '../../data/repositories/user_repository.dart';
import '../../utils/constant.dart';
import '../analytics/analytics_service.dart';
import '../crashlytics/crashlytics_service.dart';
import '../network/connection_manager.dart';
import '../offline/offline_fumble_queue.dart';
import 'flumble_qr.dart';

/// Firestore-only fumble exchange (no Cloud Functions / Blaze plan required).
class FumbleService {
  FumbleService({
    UserRepository? userRepository,
    ConnectionRepository? connectionRepository,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    PendingFumbleRepository? pendingRepo,
    OfflineFumbleQueue? queue,
    AnalyticsService? analytics,
    CrashlyticsService? crashlytics,
  })  : _users = userRepository ?? UserRepository(),
        _connections = connectionRepository ?? ConnectionRepository(),
        _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _pendingRepo = pendingRepo ?? PendingFumbleRepository(),
        _queue = queue,
        _analytics = analytics ?? AnalyticsService.instance,
        _crashlytics = crashlytics ?? CrashlyticsService.instance;

  final UserRepository _users;
  final ConnectionRepository _connections;
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final PendingFumbleRepository _pendingRepo;
  final OfflineFumbleQueue? _queue;
  final AnalyticsService _analytics;
  final CrashlyticsService _crashlytics;
  static const _uuid = Uuid();

  String? parseQrPayload(String raw) => FlumbleQr.parse(raw);

  String buildQrPayload(String flumbleCode) => FlumbleQr.build(flumbleCode);

  Future<FumblePreview> resolveFumble(String flumbleCode) async {
    try {
      await _analytics.logQrScanned();
      final scannerUid = _auth.currentUser?.uid;
      if (scannerUid == null) {
        throw FumbleException(AppConstant.authPleaseLogIn, code: 'unauthenticated');
      }

      final card = await _users.getFlumbleCodeCard(flumbleCode);
      if (card == null) {
        throw FumbleException(AppConstant.flumbleCodeNotFound, code: 'not-found');
      }

      final preview = FumblePreview.fromMap(card);
      if (preview.peerUid.isEmpty) {
        throw FumbleException(AppConstant.flumbleCodeNotFound, code: 'not-found');
      }
      if (preview.peerUid == scannerUid) {
        throw FumbleException(
          AppConstant.cannotFumbleSelf,
          code: 'failed-precondition',
        );
      }

      final already = await _connections.hasConnection(
        uid: scannerUid,
        peerUid: preview.peerUid,
      );
      if (already) {
        throw FumbleException(
          AppConstant.alreadyConnected,
          code: 'already-exists',
        );
      }

      await _analytics.logFumblePreviewViewed();
      return preview;
    } on FumbleException {
      rethrow;
    } catch (e, st) {
      await _crashlytics.recordError(e, st, reason: 'resolve_fumble_failed');
      throw FumbleException(AppConstant.unableToResolveCode);
    }
  }

  Future<void> completeFumble(FumblePreview preview) async {
    await _analytics.logFumbleConfirmed();

    if (!ConnectionManager().isConnected) {
      await _enqueue(preview.peerUid);
      return;
    }

    try {
      await _completeWithPeer(preview.peerUid);
      await _pendingRepo.removeBySession(preview.peerUid);
      await _analytics.logConnectionCreated();
    } on FumbleException catch (e, st) {
      await _crashlytics.recordError(e, st, reason: 'complete_fumble_failed');
      rethrow;
    } catch (e, st) {
      debugPrint('[FumbleService] complete failed, queueing: $e');
      await _crashlytics.recordError(e, st, reason: 'complete_fumble_failed');
      await _enqueue(preview.peerUid);
    }
  }

  Future<void> _completeWithPeer(String peerUid) async {
    final scannerUid = _auth.currentUser?.uid;
    if (scannerUid == null) {
      throw FumbleException(AppConstant.authPleaseLogIn, code: 'unauthenticated');
    }
    if (peerUid == scannerUid) {
      throw FumbleException(
        AppConstant.cannotFumbleSelf,
        code: 'failed-precondition',
      );
    }

    final scanner = await _users.getUser(scannerUid);
    if (scanner == null) {
      throw FumbleException(AppConstant.profileMissing, code: 'not-found');
    }

    final peerCard = await _lookupPeerCard(peerUid);
    if (peerCard == null) {
      throw FumbleException(AppConstant.flumbleCodeNotFound, code: 'not-found');
    }

    final already = await _connections.hasConnection(
      uid: scannerUid,
      peerUid: peerUid,
    );
    if (already) return;

    await _connections.createMutualConnection(
      scanner: scanner,
      peer: peerCard,
    );
  }

  Future<FumblePeerCard?> _lookupPeerCard(String peerUid) async {
    final query = await _db
        .collection('flumbleCodes')
        .where('uid', isEqualTo: peerUid)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final data = query.docs.first.data();
    return FumblePeerCard(
      uid: peerUid,
      name: (data['name'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim() ?? '',
      photoUrl: data['photoUrl'] as String?,
    );
  }

  Future<String> rotateFumbleCode() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FumbleException(AppConstant.authPleaseLogIn, code: 'unauthenticated');
    }
    return _users.rotateFlumbleCode(uid);
  }

  Future<void> _enqueue(String peerUid) async {
    final op = PendingFumbleOp(
      id: _uuid.v4(),
      sessionId: peerUid,
      createdAt: DateTime.now(),
      attemptCount: 0,
      status: PendingOpStatus.pending,
    );
    await _pendingRepo.enqueue(op);
    _queue?.kick();
  }

  /// Used by the offline queue to retry (`sessionId` stores peerUid).
  Future<void> completeRemoteForQueue(String peerUid) =>
      _completeWithPeer(peerUid);
}

class FumbleException implements Exception {
  FumbleException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}
