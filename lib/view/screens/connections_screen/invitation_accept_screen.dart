import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/half_fumble.dart';
import 'package:fumble/data/models/public_fumble_profile.dart';
import 'package:fumble/data/repositories/half_fumble_repository.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/fumble_screen/components/fumble_preview_moment_card.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/profile/profile_card.dart';

class InvitationAcceptArgs {
  const InvitationAcceptArgs({
    required this.invitationId,
    this.token,
  });

  final String invitationId;

  /// Present only when opened via installed-app custom-scheme deep link.
  final String? token;
}

class InvitationAcceptScreen extends ConsumerStatefulWidget {
  const InvitationAcceptScreen({
    super.key,
    required this.invitationId,
    this.token,
  });

  final String invitationId;
  final String? token;

  @override
  ConsumerState<InvitationAcceptScreen> createState() =>
      _InvitationAcceptScreenState();
}

class _InvitationAcceptScreenState
    extends ConsumerState<InvitationAcceptScreen> {
  HalfFumbleInvitation? _invitation;
  PublicFumbleProfile? _publicInviter;
  String? _error;
  var _loading = true;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      await auth.reloadUser();
      if (!auth.isEmailVerified) {
        setState(() {
          _loading = false;
          _error = AppConstant.verifyEmailBody;
        });
        return;
      }

      final invite = await ref
          .read(halfFumbleRepositoryProvider)
          .getInvitation(widget.invitationId);
      if (invite == null) {
        setState(() {
          _loading = false;
          _error = AppConstant.halfFumbleInviteNotFound;
        });
        return;
      }

      final authEmail = HalfFumble.normalizeEmail(
        auth.currentUser?.email ?? '',
      );
      if (authEmail.isEmpty || authEmail != invite.normalizedEmail) {
        setState(() {
          _loading = false;
          _error = AppConstant.halfFumbleEmailMismatch;
        });
        return;
      }
      if (!invite.canAccept) {
        setState(() {
          _loading = false;
          _error = invite.isExpired
              ? AppConstant.halfFumbleInviteExpired
              : AppConstant.halfFumbleInviteUnavailable;
        });
        return;
      }

      final publicInviter = await ref
          .read(fumbleCodeRepositoryProvider)
          .loadPublicProfile(invite.inviterUserId);

      await ref
          .read(halfFumbleRepositoryProvider)
          .markPendingAcceptance(widget.invitationId);
      if (!mounted) return;
      setState(() {
        _invitation = invite;
        _publicInviter = publicInviter;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppConstant.somethingWrong;
      });
    }
  }

  Future<void> _accept() async {
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile == null) {
      showAppToast(AppConstant.authPleaseLogIn, isError: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authServiceProvider).reloadUser();
      if (!ref.read(authServiceProvider).isEmailVerified) {
        showAppToast(AppConstant.verifyEmailBody, isError: true);
        return;
      }
      await ref.read(halfFumbleRepositoryProvider).acceptInvitation(
            acceptor: profile,
            invitationId: widget.invitationId,
            rawToken: widget.token?.trim().isEmpty == true
                ? null
                : widget.token,
          );
      await ref.read(inviteLinkServiceProvider).clearPendingInvite();
      ref.invalidate(incomingInvitationsProvider);
      ref.invalidate(halfFumblesProvider);
      ref.invalidate(connectionsProvider);
      if (!mounted) return;
      showAppToast(AppConstant.halfFumbleAccepted);
      pop();
    } on HalfFumbleException catch (e) {
      showAppToast(e.message, isError: true);
    } catch (_) {
      showAppToast(AppConstant.somethingWrong, isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decline() async {
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(halfFumbleRepositoryProvider).declineInvitation(
            acceptor: profile,
            invitationId: widget.invitationId,
            rawToken: widget.token?.trim().isEmpty == true
                ? null
                : widget.token,
          );
      await ref.read(inviteLinkServiceProvider).clearPendingInvite();
      ref.invalidate(incomingInvitationsProvider);
      if (!mounted) return;
      showAppToast(AppConstant.halfFumbleDeclined);
      pop();
    } on HalfFumbleException catch (e) {
      showAppToast(e.message, isError: true);
    } catch (_) {
      showAppToast(AppConstant.somethingWrong, isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invite = _invitation;
    final public = _publicInviter;
    final name = public?.name.trim().isNotEmpty == true
        ? public!.name.trim()
        : (invite?.inviterName ?? '');
    final moment = invite?.meetingDate ?? invite?.createdAt ?? DateTime.now();
    final dateLabel = DateFormat('d MMMM yyyy').format(moment);
    final timeLabel = DateFormat('HH:mm').format(moment);
    final place = invite?.meetingLocation?.trim();
    final locationLabel =
        (place != null && place.isNotEmpty) ? place : AppConstant.fumbleLocationNotSet;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.brand,
          brandTitle: true,
          showBack: true,
          onBack: _busy ? null : pop,
        ),
        body: _loading
            ? const AppLoader()
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _error!.toText(
                            textAlign: TextAlign.center,
                            color: AppColors.softGray,
                            fontSize: 15,
                          ),
                          20.height,
                          if (_error == AppConstant.verifyEmailBody)
                            PrimaryButton(
                              buttonName: 'Resend verification email',
                              onPressed: () async {
                                await ref
                                    .read(authServiceProvider)
                                    .sendEmailVerification();
                                showAppToast('Verification email sent');
                              },
                            ),
                          12.height,
                          PrimaryButton(
                            buttonName: 'Try again',
                            filled: false,
                            onPressed: _load,
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              ProfileCardHeader(
                                name: name,
                                eyebrow:
                                    AppConstant.halfFumbleStatusLabel.toUpperCase(),
                                photoUrl: public?.photoUrl ??
                                    invite?.inviterPhotoUrl,
                                bio: public?.bio,
                                phone: public?.sharePhone == true
                                    ? public?.phone
                                    : null,
                                hideBioWhenEmpty: true,
                                showEmail: false,
                                showContact: true,
                                showActions: public?.phone?.trim().isNotEmpty ==
                                    true,
                                emptyPhoneLabel: 'No phone number',
                                topSpacing: 8,
                              ),
                              24.height,
                              FumblePreviewMomentCard(
                                dateLabel: dateLabel,
                                timeLabel: timeLabel,
                                locationLabel: locationLabel,
                                locationPlaceholder:
                                    place == null || place.isEmpty,
                              ),
                              if (invite?.personalNote?.trim().isNotEmpty ==
                                  true) ...[
                                16.height,
                                invite!.personalNote!.toText(
                                  fontSize: 14,
                                  color: AppColors.tertiaryText,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              40.height,
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(24, 8, 24, 24.h),
                        child: Column(
                          children: [
                            PrimaryButton(
                              buttonName: AppConstant.acceptFumble,
                              isLoading: _busy,
                              radius: AppStyle.radiusMd,
                              onPressed: _busy ? null : _accept,
                            ),
                            12.height,
                            PrimaryButton(
                              buttonName: AppConstant.cancel,
                              filled: false,
                              radius: AppStyle.radiusMd,
                              onPressed: _busy ? null : _decline,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
