enum PendingOpStatus { pending, failed, completed }

class PendingFumbleOp {
  const PendingFumbleOp({
    required this.id,
    required this.sessionId,
    required this.createdAt,
    required this.attemptCount,
    required this.status,
    this.lastError,
  });

  final String id;
  final String sessionId;
  final DateTime createdAt;
  final int attemptCount;
  final PendingOpStatus status;
  final String? lastError;

  PendingFumbleOp copyWith({
    int? attemptCount,
    PendingOpStatus? status,
    String? lastError,
  }) {
    return PendingFumbleOp(
      id: id,
      sessionId: sessionId,
      createdAt: createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      status: status ?? this.status,
      lastError: lastError,
    );
  }
}
