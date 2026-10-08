import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/connection_local_store.dart';
import '../../data/db/local_prefs.dart';
import '../../data/db/pending_fumble_local_store.dart';
import '../../data/models/connection.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/connection_repository.dart';
import '../../data/repositories/fumble_code_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/auth/auth_service.dart';
import '../../services/fumble/fumble_service.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/offline/connection_sync.dart';
import '../../services/offline/offline_fumble_queue.dart';
import '../../services/storage/profile_photo_service.dart';

final pendingFumbleLocalStoreProvider = Provider<PendingFumbleLocalStore>((
  ref,
) {
  return PendingFumbleLocalStore();
});

final fumbleCodeRepositoryProvider = Provider<FumbleCodeRepository>((ref) {
  return FumbleCodeRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(fumbleCodes: ref.read(fumbleCodeRepositoryProvider));
});

final connectionLocalStoreProvider = Provider<ConnectionLocalStore>((ref) {
  return ConnectionLocalStore();
});

final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  return ConnectionRepository(
    userRepository: ref.read(userRepositoryProvider),
    fumbleCodes: ref.read(fumbleCodeRepositoryProvider),
    localStore: ref.read(connectionLocalStoreProvider),
  );
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(userRepository: ref.read(userRepositoryProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    users: ref.read(userRepositoryProvider),
    auth: ref.read(authServiceProvider),
  );
});

final profilePhotoServiceProvider = Provider<ProfilePhotoService>((ref) {
  return ProfilePhotoService();
});

final offlineQueueProvider = Provider<OfflineFumbleQueue>((ref) {
  final queue = OfflineFumbleQueue(
    repository: ref.read(pendingFumbleLocalStoreProvider),
  );
  ref.onDispose(queue.dispose);
  return queue;
});

final fumbleServiceProvider = Provider<FumbleService>((ref) {
  final queue = ref.read(offlineQueueProvider);
  final service = FumbleService(
    userRepository: ref.read(userRepositoryProvider),
    fumbleCodeRepository: ref.read(fumbleCodeRepositoryProvider),
    connectionRepository: ref.read(connectionRepositoryProvider),
    pendingRepo: ref.read(pendingFumbleLocalStoreProvider),
    queue: queue,
  );
  queue.attachFumbleService(service);
  return service;
});

final connectionSyncProvider = Provider<ConnectionSync>((ref) {
  final sync = ConnectionSync(
    repository: ref.read(connectionRepositoryProvider),
    currentUid: () => ref.read(authServiceProvider).currentUser?.uid,
  );
  ref.onDispose(sync.dispose);
  return sync;
});

/// Registers FCM and starts offline sync once the provider graph exists.
/// The queue object is stable, so this does not need to rebuild [FumbleService].
final appStartupProvider = Provider<void>((ref) {
  ref.read(notificationServiceProvider).initialize();
  ref.read(offlineQueueProvider).start();
  ref.read(connectionSyncProvider).start();
  ref.listen(currentUserProfileProvider, (_, next) {
    final profile = next.valueOrNull;
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (profile == null || profile.uid != uid) return;
    unawaited(LocalPrefs.saveUserProfile(profile));
  });
  ref.listen(authStateProvider, (_, next) {
    if (next.valueOrNull != null) {
      ref.read(connectionSyncProvider).kick();
    }
  });
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return Stream<UserProfile?>.value(null);
  return ref.watch(userRepositoryProvider).watchUser(auth.uid);
});

/// Optimistic share flags so the Fumble QR updates before Firestore catches up.
final shareVisibilityProvider =
    StateProvider<({bool sharePhone, bool shareEmail})?>((ref) => null);

final connectionsProvider = StreamProvider<List<Connection>>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return Stream<List<Connection>>.value(const []);
  return ref.watch(connectionRepositoryProvider).watchOwnerConnections(auth.uid);
});
