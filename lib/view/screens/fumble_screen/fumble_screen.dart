import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/data/db/local_prefs.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/services/fumble/fumble_qr.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/colors.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCache();
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

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(currentUserProfileProvider).valueOrNull;
    final profile = live ?? _cached;
    final payload = _payloadFor(profile);

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final topGap = constraints.maxHeight < 640 ? 24.0 : 48.0;
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
                  const Spacer(),
                  if (payload == null)
                    Center(
                      child: !_cacheLoaded && live == null
                          ? const AppLoader()
                          : AppConstant.completeProfile.toText(
                              color: AppColors.softGray,
                              fontSize: 14,
                              textAlign: TextAlign.center,
                            ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, qrConstraints) {
                        final size = (qrConstraints.maxWidth * 1.05)
                            .clamp(340.0, 480.0)
                            .toDouble();
                        return Center(
                          child: FumbleAura(
                            size: size,
                            phase: FumbleAuraPhase.sharing,
                            onTap: () => ref
                                .read(fumbleNotifierProvider.notifier)
                                .startFumble(),
                            child: FumbleQrCode(
                              data: payload,
                              size: size * 0.56,
                            ),
                          ),
                        );
                      },
                    ),
                  const Spacer(flex: 2),
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
      phone: profile.phone,
      email: profile.email,
    );
  }
}
