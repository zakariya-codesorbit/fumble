import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../services/crashlytics/crashlytics_service.dart';
import '../../services/location/fumble_location_service.dart';
import '../../services/network/connection_manager.dart';
import '../../utils/constant.dart';
import '../db/connection_local_store.dart';
import '../db/local_prefs.dart';
import '../models/connection.dart';
import '../models/fumble_preview.dart';
import '../models/public_fumble_profile.dart';
import '../models/user_profile.dart';
import 'fumble_code_repository.dart';
import 'repo_utils.dart';
import 'user_repository.dart';

/// Connections: save locally first, sync to cloud, link/remove both users.
class ConnectionRepository {
  ConnectionRepository({
    FirebaseFirestore? firestore,
    UserRepository? userRepository,
    FumbleCodeRepository? fumbleCodes,
    ConnectionLocalStore? localStore,
    CrashlyticsService? crashlytics,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _users = userRepository,
        _codes = fumbleCodes ??
            FumbleCodeRepository(
              firestore: firestore ?? FirebaseFirestore.instance,
            ),
        _local = localStore ?? ConnectionLocalStore(),
        _crashlytics = crashlytics ?? CrashlyticsService.instance;

  final FirebaseFirestore _db;
  final UserRepository? _users;
  final FumbleCodeRepository _codes;
  final ConnectionLocalStore _local;
  final CrashlyticsService _crashlytics;
  final StreamController<String> _changes =
      StreamController<String>.broadcast();
  final Set<String> _syncing = {};
  final Set<String> _resync = {};

  CollectionReference<Map<String, dynamic>> _connections(String uid) =>
      _db.collection('users').doc(uid).collection('connections');

  /// Live list of this owner's connections (local store).
  Stream<List<Connection>> watchConnections(String ownerUid) {
    return Stream<List<Connection>>.multi((listener) {
      var generation = 0;

      Future<void> emit() async {
        final token = ++generation;
        try {
          final rows = await _local.loadAllConnections(ownerUid);
          if (token != generation || listener.isClosed) return;
          listener.add(rows);
        } catch (e, st) {
          if (token != generation || listener.isClosed) return;
          listener.addError(e, st);
        }
      }

      final sub = _changes.stream.listen((changedUid) {
        if (changedUid == ownerUid) unawaited(emit());
      });
      listener.onCancel = sub.cancel;
      unawaited(emit());
    });
  }

  /// Asks listeners to reload from the local store (e.g. opening Connections).
  void refreshConnections(String ownerUid) {
    if (ownerUid.isEmpty) return;
    _changes.add(ownerUid);
  }

  Future<bool> hasLocalConnection({
    required String ownerUid,
    required String peerUid,
  }) {
    return _local.hasConnection(ownerUid: ownerUid, peerUid: peerUid);
  }

  /// Saves a scanned peer locally, then starts a background cloud sync.
  /// Returns false when this peer is already connected.
  Future<bool> saveScannedConnection({
    required String ownerUid,
    required FumblePreview preview,
    FumbleLocation? fumbleLocation,
    String? note,
  }) async {
    if (await hasLocalConnection(
      ownerUid: ownerUid,
      peerUid: preview.peerUid,
    )) {
      return false;
    }

    FumbleLocation? coords = fumbleLocation;
    String? placeLabel;
    if (coords == null) {
      try {
        final card = await _codes.loadPublicProfile(preview.peerUid);
        coords = card?.fumbleLocation;
        placeLabel = card?.fumblePlace;
      } catch (_) {}
    }
    if (coords != null && (placeLabel == null || placeLabel.isEmpty)) {
      placeLabel = await FumbleLocationService.placeLabel(coords);
    }

    final now = DateTime.now();
    final initialNote = RepoUtils.blankToNull(note);
    final connection = Connection(
      id: preview.peerUid,
      peerUid: preview.peerUid,
      name: preview.name.trim(),
      email: preview.email?.trim() ?? '',
      photoUrl: preview.photoUrl,
      bio: RepoUtils.blankToNull(preview.bio),
      location: RepoUtils.blankToNull(preview.location),
      phone: RepoUtils.blankToNull(preview.phone),
      note: initialNote,
      noteUpdatedAt: initialNote != null ? now : null,
      sharePhone: RepoUtils.filled(preview.phone),
      shareEmail: RepoUtils.filled(preview.email),
      fumbleLocation: coords,
      fumblePlace: RepoUtils.blankToNull(placeLabel),
      initiatedBy: ownerUid,
      fumbledAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    final inserted = await _local.insertConnection(ownerUid, connection);
    if (!inserted) return false;
    _changes.add(ownerUid);
    unawaited(syncConnections(ownerUid));
    return true;
  }

  /// Updates the shared note on an existing local connection and syncs.
  Future<void> updateConnectionNote({
    required String ownerUid,
    required String peerUid,
    required String note,
  }) {
    return updateConnectionMemory(
      ownerUid: ownerUid,
      peerUid: peerUid,
      note: note,
    );
  }

  /// Updates shared note and/or meeting place, then syncs to both users.
  Future<void> updateConnectionMemory({
    required String ownerUid,
    required String peerUid,
    String? note,
    String? fumblePlace,
  }) async {
    final existing = await _local.loadSingleConnection(
      ownerUid: ownerUid,
      peerUid: peerUid,
    );
    if (existing == null) return;

    var updated = existing;
    final now = DateTime.now();
    if (note != null) {
      final trimmed = note.trim();
      final nextNote = trimmed.isEmpty ? null : trimmed;
      if (nextNote != existing.note) {
        updated = updated.copyWith(
          note: nextNote,
          clearNote: nextNote == null,
          noteUpdatedAt: now,
        );
      }
    }
    if (fumblePlace != null) {
      final trimmed = fumblePlace.trim();
      updated = updated.copyWith(
        fumblePlace: trimmed.isEmpty ? null : trimmed,
        clearFumblePlace: trimmed.isEmpty,
      );
    }
    if (updated.sameContent(existing)) return;

    updated = updated.copyWith(
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );
    await _local.saveConnection(ownerUid, updated);
    _changes.add(ownerUid);
    unawaited(syncConnections(ownerUid));
  }

  /// Merges public-card fields into a locally saved offline connection.
  Future<void> enrichLocalConnection({
    required String ownerUid,
    required FumblePreview preview,
  }) async {
    if (ownerUid.isEmpty || !preview.isResolved) return;
    final existing = await _local.loadSingleConnection(
      ownerUid: ownerUid,
      peerUid: preview.peerUid,
    );
    if (existing == null) return;

    final updated = existing.copyWith(
      name: preview.name.trim().isNotEmpty ? preview.name.trim() : existing.name,
      email: preview.email?.trim() ?? existing.email,
      photoUrl: preview.photoUrl ?? existing.photoUrl,
      bio: RepoUtils.blankToNull(preview.bio) ?? existing.bio,
      location: RepoUtils.blankToNull(preview.location) ?? existing.location,
      phone: RepoUtils.blankToNull(preview.phone) ?? existing.phone,
      sharePhone: RepoUtils.filled(preview.phone) || existing.sharePhone,
      shareEmail: RepoUtils.filled(preview.email) || existing.shareEmail,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
    await _local.saveConnection(ownerUid, updated);
    _changes.add(ownerUid);
    unawaited(syncConnections(ownerUid));
  }

  /// Pushes pending local rows to Firestore, then pulls remote updates.
  Future<void> syncConnections(String ownerUid) async {
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
          await _pushPendingToCloud(ownerUid);
          if (!ConnectionManager().isConnected) return;
          await _pullUpdatesFromCloud(ownerUid);
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
        unawaited(syncConnections(ownerUid));
      }
    }
  }

  Future<void> _pushPendingToCloud(String ownerUid) async {
    final rows = await _local.loadAllConnections(ownerUid);
    if (rows.isEmpty) return;

    final scanner = await _loadOwnerProfile(ownerUid);
    if (scanner == null) {
      for (final row in rows) {
        if (row.syncStatus == SyncStatus.synced) continue;
        await _markSyncStatus(ownerUid, row.peerUid, SyncStatus.failed);
      }
      return;
    }

    for (final row in rows) {
      if (!ConnectionManager().isConnected) return;
      final peer = await _resolvePeerProfile(row);
      final next = _mergeLocalWithPeerProfile(row, peer);
      final changed = !_sameSharedFields(row, next);
      final needsWrite = changed || row.syncStatus != SyncStatus.synced;
      if (!needsWrite) continue;

      if (changed) {
        await _local.saveConnection(
          ownerUid,
          next.copyWith(updatedAt: DateTime.now()),
        );
        _changes.add(ownerUid);
      }

      final wasSynced = row.syncStatus == SyncStatus.synced;
      if (!wasSynced) {
        await _markSyncStatus(ownerUid, row.peerUid, SyncStatus.syncing);
      }
      try {
        final coords = row.fumbleLocation ?? peer.fumbleLocation;
        var placeLabel = row.fumblePlace ?? peer.fumblePlace;
        if (coords != null && (placeLabel == null || placeLabel.isEmpty)) {
          placeLabel = await FumbleLocationService.placeLabel(coords);
          if (RepoUtils.filled(placeLabel)) {
            await _local.saveConnection(
              ownerUid,
              next.copyWith(
                fumblePlace: placeLabel,
                updatedAt: DateTime.now(),
              ),
            );
          }
        }
        final noteSync = await _resolveSharedNoteForPush(
          ownerUid: ownerUid,
          peerUid: row.peerUid,
          local: row,
        );
        if (noteSync.shouldUpdateLocal &&
            (noteSync.note != row.note ||
                noteSync.noteUpdatedAt != row.noteUpdatedAt)) {
          await _local.saveConnection(
            ownerUid,
            next.copyWith(
              note: noteSync.note,
              clearNote: noteSync.note == null,
              noteUpdatedAt: noteSync.noteUpdatedAt,
              clearNoteUpdatedAt: noteSync.noteUpdatedAt == null,
              updatedAt: DateTime.now(),
            ),
          );
          _changes.add(ownerUid);
        }

        await saveConnectionForBoth(
          scanner: scanner,
          peer: peer,
          fumbledAt: row.fumbledAt,
          fumbleLocation: coords,
          fumblePlace: placeLabel,
          note: noteSync.note,
          noteUpdatedAt: noteSync.noteUpdatedAt,
          writeNote: noteSync.writeNote,
          initiatedBy: row.initiatedBy,
        );
        await _markSyncStatus(ownerUid, row.peerUid, SyncStatus.synced);
      } catch (e, st) {
        if (RepoUtils.isOfflineError(e)) {
          if (!wasSynced) {
            await _markSyncStatus(ownerUid, row.peerUid, SyncStatus.pending);
          }
          return;
        }
        if (!wasSynced) {
          await _markSyncStatus(ownerUid, row.peerUid, SyncStatus.failed);
        }
        await _crashlytics.recordError(e, st, reason: 'connection_sync_failed');
      }
    }
  }

  Future<PublicFumbleProfile> _resolvePeerProfile(Connection row) async {
    try {
      final card = await _codes.loadPublicProfile(row.peerUid);
      if (card == null) return _profileFromLocalConnection(row);
      return PublicFumbleProfile(
        uid: row.peerUid,
        name: card.name.isNotEmpty ? card.name : row.name,
        email: card.shareEmail ? card.email : '',
        photoUrl:
            RepoUtils.filled(card.photoUrl) ? card.photoUrl : row.photoUrl,
        bio: RepoUtils.filled(card.bio) ? card.bio : row.bio,
        aboutMe: card.aboutMe,
        location: card.location,
        phone: card.sharePhone ? card.phone : null,
        sharePhone: card.sharePhone,
        shareEmail: card.shareEmail,
        fumbleLocation: card.fumbleLocation ?? row.fumbleLocation,
        fumblePlace: RepoUtils.filled(card.fumblePlace)
            ? card.fumblePlace
            : row.fumblePlace,
      );
    } catch (e) {
      if (RepoUtils.isOfflineError(e)) rethrow;
      return _profileFromLocalConnection(row);
    }
  }

  PublicFumbleProfile _profileFromLocalConnection(Connection row) {
    return PublicFumbleProfile(
      uid: row.peerUid,
      name: row.name,
      email: row.shareEmail ? row.email : '',
      photoUrl: row.photoUrl,
      bio: row.bio,
      phone: row.sharePhone ? row.phone : null,
      sharePhone: row.sharePhone,
      shareEmail: row.shareEmail,
      fumbleLocation: row.fumbleLocation,
      fumblePlace: row.fumblePlace,
    );
  }


  Connection _mergeLocalWithPeerProfile(
    Connection row,
    PublicFumbleProfile card,
  ) {
    return row.copyWith(
      name: card.name,
      email: card.shareEmail ? card.email : '',
      photoUrl: card.photoUrl,
      bio: card.bio,
      location: card.location,
      clearLocation: !RepoUtils.filled(card.location),
      phone: card.sharePhone ? card.phone : null,
      clearPhone: !card.sharePhone || !RepoUtils.filled(card.phone),
      sharePhone: card.sharePhone,
      shareEmail: card.shareEmail,
      fumbleLocation: row.fumbleLocation ?? card.fumbleLocation,
      clearFumbleLocation:
          row.fumbleLocation == null && card.fumbleLocation == null,
      fumblePlace: RepoUtils.filled(row.fumblePlace)
          ? row.fumblePlace
          : card.fumblePlace,
      clearFumblePlace:
          !RepoUtils.filled(row.fumblePlace) &&
          !RepoUtils.filled(card.fumblePlace),
    );
  }

  bool _sameSharedFields(Connection a, Connection b) {
    return a.name == b.name &&
        a.email == b.email &&
        a.photoUrl == b.photoUrl &&
        a.bio == b.bio &&
        a.location == b.location &&
        a.phone == b.phone &&
        a.sharePhone == b.sharePhone &&
        a.shareEmail == b.shareEmail &&
        a.fumbleLocation?.latitude == b.fumbleLocation?.latitude &&
        a.fumbleLocation?.longitude == b.fumbleLocation?.longitude &&
        a.fumblePlace == b.fumblePlace;
  }

  Future<void> _pullUpdatesFromCloud(String ownerUid) async {
    final snap = await _connections(ownerUid).get();
    final remotePeerIds = <String>{};
    var changed = false;
    for (final doc in snap.docs) {
      final remote = Connection.fromMap(doc.id, doc.data());
      if (remote.peerUid.isEmpty) continue;
      remotePeerIds.add(remote.peerUid);
      final local = await _local.loadSingleConnection(
        ownerUid: ownerUid,
        peerUid: remote.peerUid,
      );
      if (local == null) {
        await _local.saveConnection(
          ownerUid,
          remote.copyWith(syncStatus: SyncStatus.synced),
        );
        changed = true;
        continue;
      }
      if (local.syncStatus != SyncStatus.synced) continue;

      final merged = local.copyWith(
        name: remote.name.isNotEmpty ? remote.name : local.name,
        email: remote.shareEmail ? remote.email : '',
        photoUrl: remote.photoUrl ?? local.photoUrl,
        bio: remote.bio ?? local.bio,
        location: remote.location ?? local.location,
        clearLocation: !RepoUtils.filled(remote.location) &&
            !RepoUtils.filled(local.location),
        phone: remote.sharePhone ? remote.phone : null,
        clearPhone: !remote.sharePhone || !RepoUtils.filled(remote.phone),
        // Shared note: when local is synced, cloud is source of truth (LWW).
        note: remote.note,
        clearNote: !RepoUtils.filled(remote.note),
        noteUpdatedAt: remote.noteUpdatedAt ?? local.noteUpdatedAt,
        clearNoteUpdatedAt:
            remote.noteUpdatedAt == null && local.noteUpdatedAt == null,
        sharePhone: remote.sharePhone,
        shareEmail: remote.shareEmail,
        fumbleLocation: remote.fumbleLocation ?? local.fumbleLocation,
        clearFumbleLocation:
            remote.fumbleLocation == null && local.fumbleLocation == null,
        fumblePlace: RepoUtils.filled(remote.fumblePlace)
            ? remote.fumblePlace
            : local.fumblePlace,
        clearFumblePlace: !RepoUtils.filled(remote.fumblePlace) &&
            !RepoUtils.filled(local.fumblePlace),
        initiatedBy: RepoUtils.filled(remote.initiatedBy)
            ? remote.initiatedBy
            : local.initiatedBy,
        fumbledAt: remote.fumbledAt,
        updatedAt: remote.updatedAt,
        syncStatus: SyncStatus.synced,
      );
      if (merged.sameContent(local)) continue;
      await _local.saveConnection(ownerUid, merged);
      changed = true;
    }

    final localRows = await _local.loadAllConnections(ownerUid);
    for (final row in localRows) {
      if (row.syncStatus != SyncStatus.synced) continue;
      if (remotePeerIds.contains(row.peerUid)) continue;
      await _local.removeConnection(ownerUid: ownerUid, peerUid: row.peerUid);
      changed = true;
    }

    if (changed) _changes.add(ownerUid);
  }

  Future<UserProfile?> _loadOwnerProfile(String ownerUid) async {
    Object? lookupError;
    final users = _users;
    if (users != null) {
      try {
        final remote = await users.loadUserProfile(ownerUid);
        if (remote != null) return remote;
      } catch (e, st) {
        lookupError = e;
        if (!RepoUtils.isOfflineError(e)) {
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
    if (lookupError != null && RepoUtils.isOfflineError(lookupError)) {
      throw lookupError;
    }
    return null;
  }

  Future<void> _markSyncStatus(
    String ownerUid,
    String peerUid,
    SyncStatus status,
  ) async {
    await _local.updateConnectionSyncStatus(
      ownerUid: ownerUid,
      peerUid: peerUid,
      status: status,
    );
    _changes.add(ownerUid);
  }

  Future<bool> hasRemoteConnection({
    required String uid,
    required String peerUid,
  }) async {
    final snap = await _connections(uid).doc(peerUid).get();
    return snap.exists;
  }

  /// Deletes the connection for both users (Firestore + local).
  Future<void> removeConnectionForBoth({
    required String ownerUid,
    required String peerUid,
  }) async {
    if (ownerUid.isEmpty || peerUid.isEmpty) return;

    await ConnectionManager().ready();
    if (!ConnectionManager().isConnected) {
      throw StateError(AppConstant.offline);
    }

    final batch = _db.batch();
    batch.delete(_connections(ownerUid).doc(peerUid));
    batch.delete(_connections(peerUid).doc(ownerUid));
    await batch.commit();

    await _local.removeConnection(ownerUid: ownerUid, peerUid: peerUid);
    _changes.add(ownerUid);
  }

  /// Picks which shared note to push so a newer remote note is not wiped.
  Future<({String? note, DateTime? noteUpdatedAt, bool writeNote, bool shouldUpdateLocal})>
      _resolveSharedNoteForPush({
    required String ownerUid,
    required String peerUid,
    required Connection local,
  }) async {
    try {
      final snap = await _connections(ownerUid).doc(peerUid).get();
      if (!snap.exists) {
        return (
          note: local.note,
          noteUpdatedAt: local.noteUpdatedAt,
          writeNote: local.noteUpdatedAt != null || RepoUtils.filled(local.note),
          shouldUpdateLocal: false,
        );
      }
      final data = snap.data() ?? {};
      final remoteNote = RepoUtils.blankToNull(data['note'] as String?);
      final remoteUpdated = Connection.fromMap(peerUid, data).noteUpdatedAt;
      final localUpdated = local.noteUpdatedAt;

      if (localUpdated == null && remoteUpdated == null) {
        final note = RepoUtils.filled(local.note) ? local.note : remoteNote;
        return (
          note: note,
          noteUpdatedAt: null,
          writeNote: RepoUtils.filled(note),
          shouldUpdateLocal: note != local.note,
        );
      }
      if (localUpdated == null) {
        return (
          note: remoteNote,
          noteUpdatedAt: remoteUpdated,
          writeNote: false,
          shouldUpdateLocal: true,
        );
      }
      if (remoteUpdated == null || !localUpdated.isBefore(remoteUpdated)) {
        return (
          note: local.note,
          noteUpdatedAt: localUpdated,
          writeNote: true,
          shouldUpdateLocal: false,
        );
      }
      return (
        note: remoteNote,
        noteUpdatedAt: remoteUpdated,
        writeNote: false,
        shouldUpdateLocal: true,
      );
    } catch (_) {
      return (
        note: local.note,
        noteUpdatedAt: local.noteUpdatedAt,
        writeNote: local.noteUpdatedAt != null,
        shouldUpdateLocal: false,
      );
    }
  }

  /// Writes the connection under both users' Firestore trees.
  Future<void> saveConnectionForBoth({
    required UserProfile scanner,
    required PublicFumbleProfile peer,
    DateTime? fumbledAt,
    FumbleLocation? fumbleLocation,
    String? fumblePlace,
    String? note,
    DateTime? noteUpdatedAt,
    /// When false, existing shared notes on both docs are left untouched.
    bool writeNote = false,
    String? initiatedBy,
  }) async {
    final at = fumbledAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(fumbledAt);
    final coords = fumbleLocation ?? peer.fumbleLocation;
    final placeValue = coords?.toGeoPoint();
    var placeLabel = RepoUtils.blankToNull(fumblePlace) ?? peer.fumblePlace;
    if (coords != null && !RepoUtils.filled(placeLabel)) {
      placeLabel = await FumbleLocationService.placeLabel(coords);
    }
    final initiator = RepoUtils.blankToNull(initiatedBy);
    final now = FieldValue.serverTimestamp();
    final batch = _db.batch();

    final sharedNote = RepoUtils.blankToNull(note);
    final noteFields = <String, dynamic>{
      if (writeNote) ...{
        'note': sharedNote ?? FieldValue.delete(),
        'noteUpdatedAt': noteUpdatedAt == null
            ? FieldValue.delete()
            : Timestamp.fromDate(noteUpdatedAt),
      },
    };

    final scannerDoc = <String, dynamic>{
      'peerUid': peer.uid,
      'name': peer.name,
      'email': peer.shareEmail ? peer.email : '',
      'photoUrl': peer.photoUrl,
      'bio': peer.bio,
      'location': peer.location,
      'phone': peer.sharePhone ? peer.phone : null,
      'sharePhone': peer.sharePhone,
      'shareEmail': peer.shareEmail,
      'fumbleLocation': placeValue,
      'fumblePlace': placeLabel,
      'fumbledAt': at,
      'updatedAt': now,
      'initiatedBy': ?initiator,
      ...noteFields,
    };

    final peerDoc = <String, dynamic>{
      'peerUid': scanner.uid,
      'name': scanner.name,
      'email': scanner.publicEmail,
      'photoUrl': scanner.photoUrl,
      'bio': scanner.bio,
      'location': scanner.location,
      'phone': scanner.publicPhone,
      'sharePhone': scanner.sharePhone,
      'shareEmail': scanner.shareEmail,
      'fumbleLocation': placeValue,
      'fumblePlace': placeLabel,
      'fumbledAt': at,
      'updatedAt': now,
      'initiatedBy': ?initiator,
      // Same shared note on both sides so both cards stay in sync.
      ...noteFields,
    };

    batch.set(
      _connections(scanner.uid).doc(peer.uid),
      scannerDoc,
      SetOptions(merge: true),
    );
    batch.set(
      _connections(peer.uid).doc(scanner.uid),
      peerDoc,
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
