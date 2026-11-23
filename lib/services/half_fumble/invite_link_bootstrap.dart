import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/services/half_fumble/invite_link_service.dart';
import 'package:fumble/state/providers/app_providers.dart';

/// Listens for Half Fumble deep links and persists them only.
///
/// Invitations are never auto-opened after signup/onboarding. User B reviews
/// every pending invite on Connections → Half Fumble (supports multiple).
class InviteLinkBootstrap extends ConsumerStatefulWidget {
  const InviteLinkBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InviteLinkBootstrap> createState() =>
      _InviteLinkBootstrapState();
}

class _InviteLinkBootstrapState extends ConsumerState<InviteLinkBootstrap> {
  StreamSubscription<Uri>? _sub;
  var _handledInitial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final service = ref.read(inviteLinkServiceProvider);
    if (!_handledInitial) {
      _handledInitial = true;
      // Capture for optional later use; UI is the Half Fumble tab only.
      await service.captureIncoming();
    }
    await _sub?.cancel();
    _sub = service.uriLinkStream.listen((uri) async {
      final parsed = InviteLinkService.parseInviteUri(uri);
      if (parsed == null) return;
      await service.persistPendingInvite(
        invitationId: parsed.invitationId,
        token: parsed.token,
      );
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
