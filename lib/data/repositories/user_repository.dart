import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../services/crashlytics/crashlytics_service.dart';
import '../../services/network/connection_manager.dart';
import '../../utils/constant.dart';
import '../db/local_database.dart';
import '../db/local_prefs.dart';
import '../models/connection.dart';
import '../models/fumble_preview.dart';
import '../models/user_profile.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const _uuid = Uuid();

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> _codeRef(String code) =>
      _db.collection('fumbleCodes').doc(code.toUpperCase());

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

  Future<Map<String, dynamic>?> getfumbleCodeCard(String code) async {
    final snap = await _codeRef(code).get();
    if (!snap.exists || snap.data() == null) return null;
    return snap.data();
  }

  /// Latest public card for [uid]. Signed-in users can read this collection.
  Future<FumblePeerCard?> findPublicCard(String uid) async {
    final query = await _db
        .collection('fumbleCodes')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final data = query.docs.first.data();
    return FumblePeerCard(
      uid: uid,
      name: (data['name'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim() ?? '',
      photoUrl: data['photoUrl'] as String?,
      bio: ConnectionRepository._blankToNull(data['bio'] as String?),
      phone: ConnectionRepository._blankToNull(data['phone'] as String?),
    );
  }

  Future<UserProfile> createUser({
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

    final batch = _db.batch();
    batch.set(_userRef(uid), profile.toCreateMap());
    batch.set(_codeRef(fumbleCode), {
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
    batch.set(_codeRef(current.fumbleCode), {
      'uid': uid,
      'name': nextName,
      'email': current.email,
      'photoUrl': nextPhoto,
      'bio': nextBio,
      'phone': nextPhone,
      'aboutMe': nextAbout,
      'location': nextLocation,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Future<String> rotatefumbleCode(String uid) async {
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
    final code = userSnap.data()?['fumbleCode'] as String?;

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
  ConnectionRepository({
    FirebaseFirestore? firestore,
    UserRepository? userRepository,
    LocalDatabase? database,
    CrashlyticsService? crashlytics,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _users = userRepository,
       _local = database ?? LocalDatabase.instance,
       _crashlytics = crashlytics ?? CrashlyticsService.instance;

  final FirebaseFirestore _db;
  final UserRepository? _users;
  final LocalDatabase _local;
  final CrashlyticsService _crashlytics;
  final StreamController<String> _changes =
      StreamController<String>.broadcast();
  final Set<String> _syncing = {};
  final Set<String> _resync = {};

  CollectionReference<Map<String, dynamic>> _connections(String uid) =>
      _db.collection('users').doc(uid).collection('connections');

  /// Connections list. Emits the local rows immediately, then again after writes.
  Stream<List<Connection>> watchConnections(String uid) {
    return Stream<List<Connection>>.multi((listener) {
      var generation = 0;

      Future<void> emit() async {
        final token = ++generation;
        try {
          final rows = await _localConnections(uid);
          if (token != generation || listener.isClosed) return;
          listener.add(rows);
        } catch (e, st) {
          if (token != generation || listener.isClosed) return;
          listener.addError(e, st);
        }
      }

      final sub = _changes.stream.listen((changedUid) {
        if (changedUid == uid) unawaited(emit());
      });
      listener.onCancel = sub.cancel;
      unawaited(emit());
    });
  }

  Future<bool> hasLocalConnection({
    required String ownerUid,
    required String peerUid,
  }) async {
    final db = await _local.database;
    final rows = await db.query(
      'connections',
      columns: const ['peer_uid'],
      where: 'owner_uid = ? AND peer_uid = ?',
      whereArgs: [ownerUid, peerUid],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Saves the connection locally first, then syncs in the background.
  /// Returns false when [preview] is already connected for [ownerUid].
  Future<bool> createLocalConnection({
    required String ownerUid,
    required FumblePreview preview,
  }) async {
    if (await hasLocalConnection(
      ownerUid: ownerUid,
      peerUid: preview.peerUid,
    )) {
      return false;
    }

    final now = DateTime.now();
    final connection = Connection(
      id: preview.peerUid,
      peerUid: preview.peerUid,
      name: preview.name.trim(),
      email: preview.email?.trim() ?? '',
      photoUrl: preview.photoUrl,
      bio: _blankToNull(preview.bio),
      phone: _blankToNull(preview.phone),
      fumbledAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    final db = await _local.database;
    try {
      await db.insert(
        'connections',
        connection.toLocalRow(ownerUid),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) return false;
      rethrow;
    }
    _changes.add(ownerUid);
    unawaited(synchronize(ownerUid));
    return true;
  }

  /// Pushes unsynced rows, then pulls remote connections into the local list.
  Future<void> synchronize(String ownerUid) async {
    if (ownerUid.isEmpty) return;
    if (_syncing.contains(ownerUid)) {
      _resync.add(ownerUid);
      return;
    }

    _syncing.add(ownerUid);
    try {
      try {
        await ConnectionManager().ready();
      } catch (e) {
        debugPrint('[ConnectionRepository] connectivity check failed: $e');
        return;
      }

      do {
        _resync.remove(ownerUid);
        if (!ConnectionManager().isConnected) return;
        try {
          await _pushUnsynced(ownerUid);
          if (!ConnectionManager().isConnected) return;
          await _pullRemote(ownerUid);
        } catch (e, st) {
          debugPrint('[ConnectionRepository] sync failed: $e');
          await _crashlytics.recordError(
            e,
            st,
            reason: 'connection_sync_failed',
          );
          return;
        }
      } while (_resync.contains(ownerUid) && ConnectionManager().isConnected);
    } finally {
      _syncing.remove(ownerUid);
      if (_resync.remove(ownerUid)) {
        unawaited(synchronize(ownerUid));
      }
    }
  }

  Future<void> _pushUnsynced(String ownerUid) async {
    final rows = await _localConnections(ownerUid);
    if (rows.isEmpty) return;

    final scanner = await _scannerProfile(ownerUid);
    if (scanner == null) {
      for (final row in rows) {
        if (row.syncStatus == SyncStatus.synced) continue;
        await _setSyncStatus(ownerUid, row.peerUid, SyncStatus.failed);
      }
      return;
    }

    for (final row in rows) {
      if (!ConnectionManager().isConnected) return;
      final peer = await _peerCard(row);
      final next = _connectionFromCard(row, peer);
      final changed = !_sameSharedFields(row, next);
      final needsWrite = changed || row.syncStatus != SyncStatus.synced;
      if (!needsWrite) continue;

      if (changed) {
        await _upsertLocal(
          ownerUid,
          next.copyWith(updatedAt: DateTime.now()),
        );
        _changes.add(ownerUid);
      }

      final wasSynced = row.syncStatus == SyncStatus.synced;
      if (!wasSynced) {
        await _setSyncStatus(ownerUid, row.peerUid, SyncStatus.syncing);
      }
      try {
        await createMutualConnection(
          scanner: scanner,
          peer: peer,
          fumbledAt: row.fumbledAt,
        );
        await _setSyncStatus(ownerUid, row.peerUid, SyncStatus.synced);
      } catch (e, st) {
        if (_isOfflineError(e)) {
          if (!wasSynced) {
            await _setSyncStatus(ownerUid, row.peerUid, SyncStatus.pending);
          }
          return;
        }
        if (!wasSynced) {
          await _setSyncStatus(ownerUid, row.peerUid, SyncStatus.failed);
        }
        await _crashlytics.recordError(e, st, reason: 'connection_sync_failed');
      }
    }
  }

  /// Prefer the peer's current public card so both sides store the same fields.
  Future<FumblePeerCard> _peerCard(Connection row) async {
    final users = _users;
    if (users == null) return _cardFromConnection(row);
    try {
      final card = await users.findPublicCard(row.peerUid);
      if (card == null) return _cardFromConnection(row);
      return FumblePeerCard(
        uid: row.peerUid,
        name: card.name.isNotEmpty ? card.name : row.name,
        email: card.email.isNotEmpty ? card.email : row.email,
        photoUrl: _filled(card.photoUrl) ? card.photoUrl : row.photoUrl,
        bio: _filled(card.bio) ? card.bio : row.bio,
        phone: _filled(card.phone) ? card.phone : row.phone,
      );
    } catch (e) {
      if (_isOfflineError(e)) rethrow;
      return _cardFromConnection(row);
    }
  }

  FumblePeerCard _cardFromConnection(Connection row) {
    return FumblePeerCard(
      uid: row.peerUid,
      name: row.name,
      email: row.email,
      photoUrl: row.photoUrl,
      bio: row.bio,
      phone: row.phone,
    );
  }

  Connection _connectionFromCard(Connection row, FumblePeerCard card) {
    return row.copyWith(
      name: card.name,
      email: card.email,
      photoUrl: card.photoUrl,
      bio: card.bio,
      phone: card.phone,
    );
  }

  bool _sameSharedFields(Connection a, Connection b) {
    return a.name == b.name &&
        a.email == b.email &&
        a.photoUrl == b.photoUrl &&
        a.bio == b.bio &&
        a.phone == b.phone;
  }

  static bool _filled(String? value) => value != null && value.trim().isNotEmpty;

  Future<void> _pullRemote(String ownerUid) async {
    final snap = await _connections(ownerUid).get();
    var changed = false;
    for (final doc in snap.docs) {
      final remote = Connection.fromMap(doc.id, doc.data());
      if (remote.peerUid.isEmpty) continue;
      final local = await _findLocal(ownerUid, remote.peerUid);
      if (local == null) {
        await _upsertLocal(
          ownerUid,
          remote.copyWith(syncStatus: SyncStatus.synced),
        );
        changed = true;
        continue;
      }
      if (local.syncStatus != SyncStatus.synced) continue;

      final merged = local.copyWith(
        name: remote.name.isNotEmpty ? remote.name : local.name,
        email: remote.email.isNotEmpty ? remote.email : local.email,
        photoUrl: remote.photoUrl ?? local.photoUrl,
        bio: remote.bio ?? local.bio,
        phone: remote.phone ?? local.phone,
        fumbledAt: remote.fumbledAt,
        updatedAt: remote.updatedAt,
        syncStatus: SyncStatus.synced,
      );
      if (merged.sameContent(local)) continue;
      await _upsertLocal(ownerUid, merged);
      changed = true;
    }
    if (changed) _changes.add(ownerUid);
  }

  Future<UserProfile?> _scannerProfile(String ownerUid) async {
    Object? lookupError;
    final users = _users;
    if (users != null) {
      try {
        final remote = await users.getUser(ownerUid);
        if (remote != null) return remote;
      } catch (e, st) {
        lookupError = e;
        if (!_isOfflineError(e)) {
          debugPrint('[ConnectionRepository] profile lookup failed: $e');
          await _crashlytics.recordError(
            e,
            st,
            reason: 'sync_profile_lookup_failed',
          );
        }
      }
    }
    final cached = await LocalPrefs.loadUserProfile();
    if (cached != null && cached.uid == ownerUid) return cached;
    if (lookupError != null && _isOfflineError(lookupError)) {
      throw lookupError;
    }
    return null;
  }

  Future<List<Connection>> _localConnections(String ownerUid) async {
    final db = await _local.database;
    final rows = await db.query(
      'connections',
      where: 'owner_uid = ?',
      whereArgs: [ownerUid],
      orderBy: 'created_at DESC',
    );
    return rows.map(Connection.fromLocalRow).toList();
  }

  Future<Connection?> _findLocal(String ownerUid, String peerUid) async {
    final db = await _local.database;
    final rows = await db.query(
      'connections',
      where: 'owner_uid = ? AND peer_uid = ?',
      whereArgs: [ownerUid, peerUid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Connection.fromLocalRow(rows.first);
  }

  Future<void> _upsertLocal(String ownerUid, Connection connection) async {
    final db = await _local.database;
    await db.insert(
      'connections',
      connection.toLocalRow(ownerUid),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _setSyncStatus(
    String ownerUid,
    String peerUid,
    SyncStatus status,
  ) async {
    final db = await _local.database;
    await db.update(
      'connections',
      {
        'sync_status': status.name,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'owner_uid = ? AND peer_uid = ?',
      whereArgs: [ownerUid, peerUid],
    );
    _changes.add(ownerUid);
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static bool _isOfflineError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('network-request-failed') ||
        text.contains('unavailable') ||
        text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('network error') ||
        text.contains('clientexception');
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
    DateTime? fumbledAt,
  }) async {
    final at = fumbledAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(fumbledAt);
    final batch = _db.batch();

    batch.set(_connections(scanner.uid).doc(peer.uid), {
      'peerUid': peer.uid,
      'name': peer.name,
      'email': peer.email,
      'photoUrl': peer.photoUrl,
      'bio': peer.bio,
      'phone': peer.phone,
      'fumbledAt': at,
    }, SetOptions(merge: true));

    batch.set(_connections(peer.uid).doc(scanner.uid), {
      'peerUid': scanner.uid,
      'name': scanner.name,
      'email': scanner.email,
      'photoUrl': scanner.photoUrl,
      'bio': scanner.bio,
      'phone': scanner.phone,
      'fumbledAt': at,
    }, SetOptions(merge: true));

    await batch.commit();
  }
}

class FumblePeerCard {
  const FumblePeerCard({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    this.phone,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;
  final String? phone;
}
