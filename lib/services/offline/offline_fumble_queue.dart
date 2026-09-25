import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/db/pending_fumble_repository.dart';
import '../../data/models/pending_fumble_op.dart';
import '../analytics/analytics_service.dart';
import '../crashlytics/crashlytics_service.dart';
import '../fumble/fumble_service.dart';
import '../network/connection_manager.dart';

/// Retries queued completeFumble operations with exponential backoff.
class OfflineFumbleQueue {
  OfflineFumbleQueue({
    required PendingFumbleRepository repository,
    FumbleService? fumbleService,
  })  : _repo = repository,
        _fumbleService = fumbleService;

  final PendingFumbleRepository _repo;
  FumbleService? _fumbleService;
  StreamSubscription<bool>? _connectivitySub;
  bool _processing = false;
  static const _maxAttempts = 8;
  static const _uuid = Uuid();

  void attachFumbleService(FumbleService service) {
    _fumbleService = service;
  }

  void start() {
    _connectivitySub?.cancel();
    _connectivitySub = ConnectionManager().connectionStream.listen((online) {
      if (online) kick();
    });
    kick();
  }

  void kick() {
    unawaited(_process());
  }

  Future<void> enqueueSession(String sessionId) async {
    await _repo.enqueue(
      PendingFumbleOp(
        id: _uuid.v4(),
        sessionId: sessionId,
        createdAt: DateTime.now(),
        attemptCount: 0,
        status: PendingOpStatus.pending,
      ),
    );
    kick();
  }

  Future<void> _process() async {
    if (_processing) return;
    if (!ConnectionManager().isConnected) return;
    final service = _fumbleService;
    if (service == null) return;

    _processing = true;
    try {
      final pending = await _repo.getPending();
      for (final op in pending) {
        if (!ConnectionManager().isConnected) break;
        try {
          await service.completeRemoteForQueue(op.sessionId);
          await _repo.remove(op.id);
          await AnalyticsService.instance.logConnectionCreated();
        } catch (e, st) {
          final nextAttempt = op.attemptCount + 1;
          if (nextAttempt >= _maxAttempts) {
            await _repo.update(
              op.copyWith(
                attemptCount: nextAttempt,
                status: PendingOpStatus.failed,
                lastError: e.toString(),
              ),
            );
            await CrashlyticsService.instance.recordError(
              e,
              st,
              reason: 'offline_fumble_exhausted',
            );
          } else {
            await _repo.update(
              op.copyWith(
                attemptCount: nextAttempt,
                lastError: e.toString(),
              ),
            );
            final delayMs = min(30000, 500 * pow(2, nextAttempt).toInt());
            await Future<void>.delayed(Duration(milliseconds: delayMs));
          }
        }
      }
    } catch (e) {
      debugPrint('[OfflineFumbleQueue] process error: $e');
    } finally {
      _processing = false;
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}
