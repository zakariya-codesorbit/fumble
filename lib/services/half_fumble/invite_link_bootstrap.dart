import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/models/half_fumble.dart';
import 'package:fumble/services/half_fumble/invite_link_service.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/view/screens/connections_screen/invitation_accept_screen.dart';

/// Deep-link listener (installed app) + verified-email invitation recovery.
///
/// Signup alone never creates a connection — the invitee must verify email
/// and then accept/decline. Recovery re-runs on auth, ID-token refresh,
/// and app resume (so verifying in the mail client then returning works).
class InviteLinkBootstrap extends ConsumerStatefulWidget {
  const InviteLinkBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InviteLinkBootstrap> createState() =>
      _InviteLinkBootstrapState();
}

class _InviteLinkBootstrapState extends ConsumerState<InviteLinkBootstrap>
    with WidgetsBindingObserver {
  StreamSubscription<Uri>? _sub;
  StreamSubscription<dynamic>? _idTokenSub;
  var _handledInitial = false;
  var _emailRecoveryInFlight = false;
  String? _lastOpenedKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_recoverPendingByVerifiedEmail());
    }
  }

  Future<void> _bootstrap() async {
    final service = ref.read(inviteLinkServiceProvider);
    if (!_handledInitial) {
      _handledInitial = true;
      final pending = await service.captureIncoming();
      if (pending != null) {
        await _openIfReady(
          invitationId: pending.invitationId,
          token: pending.token,
        );
      }
    }
    await _sub?.cancel();
    _sub = service.uriLinkStream.listen((uri) async {
      final parsed = InviteLinkService.parseInviteUri(uri);
      if (parsed == null) return;
      await service.persistPendingInvite(
        invitationId: parsed.invitationId,
        token: parsed.token,
      );
      await _openIfReady(
        invitationId: parsed.invitationId,
        token: parsed.token,
      );
    });

    await _idTokenSub?.cancel();
    _idTokenSub =
        ref.read(authServiceProvider).idTokenChanges.listen((user) async {
      if (user == null) return;
      await _recoverPendingByVerifiedEmail();
    });

    await _recoverPendingByVerifiedEmail();
  }

  /// After install + signup, recover invitations from Firestore by verified email.
  Future<void> _recoverPendingByVerifiedEmail() async {
    if (_emailRecoveryInFlight) return;
    final auth = ref.read(authServiceProvider);
    final user = auth.currentUser;
    if (user == null) return;

    _emailRecoveryInFlight = true;
    try {
      await auth.reloadUser();
      if (!auth.isEmailVerified) {
        debugPrint('[InviteLink] skip recovery — email not verified yet');
        return;
      }

      final email = (auth.currentUser?.email ?? '').trim();
      if (email.isEmpty) return;

      final invites = await ref
          .read(halfFumbleRepositoryProvider)
          .pendingInvitationsForEmail(HalfFumble.normalizeEmail(email));
      if (invites.isEmpty) {
        debugPrint('[InviteLink] no pending invites for $email');
        return;
      }

      final deepLink =
          await ref.read(inviteLinkServiceProvider).loadPendingInvite();
      HalfFumbleInvitation? chosen;
      if (deepLink != null) {
        for (final invite in invites) {
          if (invite.id == deepLink.invitationId) {
            chosen = invite;
            break;
          }
        }
      }
      chosen ??= invites.first;

      await _openIfReady(
        invitationId: chosen.id,
        token: deepLink?.invitationId == chosen.id ? deepLink!.token : null,
      );
    } catch (e) {
      debugPrint('[InviteLink] email recovery failed: $e');
    } finally {
      _emailRecoveryInFlight = false;
    }
  }

  Future<void> _openIfReady({
    required String invitationId,
    String? token,
  }) async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;
    final key = '$invitationId|${token ?? ''}';
    if (_lastOpenedKey == key) return;
    _lastOpenedKey = key;
    push(
      AppRoutes.invitationAccept,
      arguments: InvitationAcceptArgs(
        invitationId: invitationId,
        token: token,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _idTokenSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) async {
      final user = next.valueOrNull;
      if (user == null) {
        _lastOpenedKey = null;
        return;
      }

      final pending =
          await ref.read(inviteLinkServiceProvider).loadPendingInvite();
      if (pending != null) {
        await _openIfReady(
          invitationId: pending.invitationId,
          token: pending.token,
        );
      }
      await _recoverPendingByVerifiedEmail();
    });
    return widget.child;
  }
}
