import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_initializer.dart';
import '../../data/models/connection.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/auth/auth_service.dart';
import '../../services/fumble/fumble_service.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/offline/offline_fumble_queue.dart';
import '../../services/storage/profile_photo_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final userRepositoryProvider =
    Provider<UserRepository>((ref) => UserRepository());

final connectionRepositoryProvider =
    Provider<ConnectionRepository>((ref) => ConnectionRepository());

final notificationServiceProvider =
    Provider<NotificationService>((ref) => AppInitializer.notifications);

final profilePhotoServiceProvider =
    Provider<ProfilePhotoService>((ref) => ProfilePhotoService());

final offlineQueueProvider =
    Provider<OfflineFumbleQueue>((ref) => AppInitializer.offlineQueue);

final fumbleServiceProvider = Provider<FumbleService>((ref) {
  final queue = ref.watch(offlineQueueProvider);
  final service = FumbleService(queue: queue);
  queue.attachFumbleService(service);
  return service;
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
