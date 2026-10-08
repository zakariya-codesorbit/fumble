import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/data/db/local_prefs.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/services/fumble/fumble_qr.dart';
import 'package:fumble/services/location/fumble_location_service.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/qr/fumble_aura.dart';
import 'package:fumble/view/widgets/qr/fumble_qr_code.dart';

/// Home — animated share QR. Tap opens the scanner.
class FumbleScreen extends ConsumerStatefulWidget {
  const FumbleScreen({super.key});

  @override
  ConsumerState<FumbleScreen> createState() => _FumbleScreenState();
}

class _FumbleScreenState extends ConsumerState<FumbleScreen> {
  UserProfile? _cached;
  var _cacheLoaded = false;
  var _locationBootstrapped = false;

  @override
  void initState() {
    super.initState();
    _loadCache();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapLocation());
    });
  }

  Future<void> _loadCache() async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    final profile = await LocalPrefs.loadUserProfile();
    if (!mounted) return;
    setState(() {
      _cacheLoaded = true;
      if (profile != null && profile.uid == uid) _cached = profile;
    });
  }

  /// Ask for location if needed and publish coords for peers who scan this QR.
  Future<void> _bootstrapLocation() async {
    if (!mounted || _locationBootstrapped) return;
    _locationBootstrapped = true;
    await _publishLocation(promptIfDenied: true);
  }

  Future<void> _publishLocation({required bool promptIfDenied}) async {
    if (!mounted) return;
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;

    final place = await FumbleLocationService.capture(
      context,
      promptIfDenied: promptIfDenied,
    );
    if (!mounted) return;
    try {
      await ref
          .read(fumbleCodeRepositoryProvider)
          .publishPublicMeetingPlace(uid: uid, location: place);
    } catch (_) {
      // Non-blocking — fumble still works without published location.
    }
  }

  void _openScanner() {
    ref.read(fumbleNotifierProvider.notifier).startFumble();
  }

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(currentUserProfileProvider).valueOrNull;
    final shareOverride = ref.watch(shareVisibilityProvider);

    ref.listen(currentUserProfileProvider, (_, next) {
      final profile = next.valueOrNull;
      if (profile == null || !mounted) return;
      setState(() => _cached = profile);
      final override = ref.read(shareVisibilityProvider);
      if (override != null &&
          profile.sharePhone == override.sharePhone &&
          profile.shareEmail == override.shareEmail) {
        ref.read(shareVisibilityProvider.notifier).state = null;
      }
    });

    var profile = live ?? _cached;
    if (profile != null && shareOverride != null) {
      profile = profile.copyWith(
        sharePhone: shareOverride.sharePhone,
        shareEmail: shareOverride.shareEmail,
      );
    }
    final payload = _payloadFor(profile);
    final qrKey = profile == null
        ? null
        : ValueKey(
            'qr_${profile.sharePhone}_${profile.shareEmail}_'
            '${profile.publicPhone ?? ''}_${profile.publicEmail}',
          );

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final topGap = constraints.maxHeight < 640 ? 16.0 : 48.0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topGap),
                  AppConstant.readyTo.toText(
                    fontSize: 42,
                    fontWeight: AppStyle.w400,
                    lineHeight: 1.2,
                  ),
                  AppConstant.fumbleQuestion.toText(
                    color: AppColors.gold,
                    fontSize: 42,
                    fontWeight: AppStyle.w400,
                    lineHeight: 1.2,
                  ),
                  16.height,
                  AppConstant.tapTheQr.toText(
                    fontSize: 18,
                    color: AppColors.softGray,
                  ),
                  2.height,
                  AppConstant.readyToScan.toText(
                    fontSize: 18,
                    color: AppColors.softGray,
                  ),
                  Expanded(
                    child: payload == null
                        ? Center(
                            child: !_cacheLoaded && live == null
                                ? const AppLoader()
                                : AppConstant.completeProfile.toText(
                                    color: AppColors.softGray,
                                    fontSize: 14,
                                    textAlign: TextAlign.center,
                                  ),
                          )
                        : LayoutBuilder(
                            builder: (context, qrConstraints) {
                              final size = math
                                  .min(
                                    qrConstraints.maxWidth * 1.05,
                                    qrConstraints.maxHeight * 0.92,
                                  )
                                  .clamp(180.0, 520.0)
                                  .toDouble();
                              return Center(
                                child: FumbleAura(
                                  size: size,
                                  phase: FumbleAuraPhase.sharing,
                                  onTap: _openScanner,
                                  child: FumbleQrCode(
                                    key: qrKey,
                                    data: payload,
                                    // Larger modules on screen → faster phone-to-phone scans.
                                    size: size * 0.68,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ).paddingSymmetric(horizontal: 28.w);
            },
          ),
        ),
      ),
    );
  }

  String? _payloadFor(UserProfile? profile) {
    if (profile == null) return null;
    final name = profile.name.trim();
    if (profile.uid.isEmpty || name.isEmpty) return null;
    return FumbleQr.build(
      userId: profile.uid,
      name: name,
      bio: profile.bio,
      phone: profile.publicPhone,
      email: profile.shareEmail ? profile.email : null,
    );
  }
}
