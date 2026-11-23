import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fumble/core/config/app_urls.dart';

/// Parses and persists Half Fumble invite deep links (custom scheme only).
/// Primary recovery path is verified-email lookup in Firestore — not deferred
/// deep linking or a website.
class InviteLinkService {
  InviteLinkService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  static const _prefsInvitationId = 'pending_half_fumble_invitation_id';
  static const _prefsToken = 'pending_half_fumble_token';

  Stream<Uri> get uriLinkStream => _appLinks.uriLinkStream;

  Future<Uri?> getInitialLink() => _appLinks.getInitialLink();

  static ({String invitationId, String token})? parseInviteUri(Uri uri) {
    final isCustom = uri.scheme == AppUrls.inviteScheme &&
        uri.host == AppUrls.inviteHost;
    if (!isCustom) return null;

    final invitationId =
        uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    final token = uri.queryParameters['t'] ?? '';
    if (invitationId.isEmpty || token.isEmpty) return null;
    return (invitationId: invitationId, token: token);
  }

  Future<void> persistPendingInvite({
    required String invitationId,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsInvitationId, invitationId);
    await prefs.setString(_prefsToken, token);
  }

  Future<({String invitationId, String token})?> loadPendingInvite() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefsInvitationId);
    if (id == null || id.isEmpty) return null;
    // Token may be empty when deferred from verified-email recovery.
    final token = prefs.getString(_prefsToken) ?? '';
    return (invitationId: id, token: token);
  }

  Future<void> clearPendingInvite() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsInvitationId);
    await prefs.remove(_prefsToken);
  }

  Future<({String invitationId, String token})?> captureIncoming() async {
    try {
      final initial = await getInitialLink();
      if (initial != null) {
        final parsed = parseInviteUri(initial);
        if (parsed != null) {
          await persistPendingInvite(
            invitationId: parsed.invitationId,
            token: parsed.token,
          );
          return parsed;
        }
      }
    } catch (e) {
      debugPrint('[InviteLink] initial link failed: $e');
    }
    return loadPendingInvite();
  }
}
