import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/pending_fumble_repository.dart';
import '../../data/models/connection.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/auth/auth_service.dart';
import '../../services/fumble/fumble_service.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/offline/offline_fumble_queue.dart';
import '../../services/storage/profile_photo_service.dart';

final pendingFumbleRepositoryProvider = Provider<PendingFumbleRepository>((ref) {
  return PendingFumbleRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  return ConnectionRepository();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    userRepository: ref.read(userRepositoryProvider),
  );
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
    repository: ref.read(pendingFumbleRepositoryProvider),
  );
  ref.onDispose(queue.dispose);
  return queue;
});

final fumbleServiceProvider = Provider<FumbleService>((ref) {
  final queue = ref.read(offlineQueueProvider);
  final service = FumbleService(
    userRepository: ref.read(userRepositoryProvider),
    connectionRepository: ref.read(connectionRepositoryProvider),
    pendingRepo: ref.read(pendingFumbleRepositoryProvider),
    queue: queue,
  );
  queue.attachFumbleService(service);
  return service;
});

/// Registers FCM and starts the offline queue once the provider graph exists.
/// The queue object is stable, so this does not need to rebuild [FumbleService].
final appStartupProvider = Provider<void>((ref) {
  ref.read(notificationServiceProvider).initialize();
  ref.read(offlineQueueProvider).start();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return Stream<UserProfile?>.value(null);
  return ref.watch(userRepositoryProvider).watchUser(auth.uid);
});

final connectionsProvider = StreamProvider<List<Connection>>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return Stream<List<Connection>>.value(const []);
  return ref.watch(connectionRepositoryProvider).watchConnections(auth.uid);
});
