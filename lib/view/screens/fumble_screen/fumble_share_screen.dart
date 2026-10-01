import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/db/local_prefs.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/navigation/back_icon_button.dart';
import '../../../services/fumble/fumble_qr.dart';
import '../../widgets/qr/fumble_aura.dart';
import '../../widgets/qr/fumble_qr_code.dart';

/// Share screen — galaxy Aura + scannable QR only.
class FumbleShareScreen extends ConsumerStatefulWidget {
  const FumbleShareScreen({super.key});

  @override
  ConsumerState<FumbleShareScreen> createState() => _FumbleShareScreenState();
}

class _FumbleShareScreenState extends ConsumerState<FumbleShareScreen> {
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
        appBar: AppAppBar(
          leading: BackIconButton(icon: AppIcons.close, onTap: pop),
        ),
        body: payload == null
            ? Center(
                child: !_cacheLoaded && live == null
                    ? const AppLoader()
                    : AppConstant.completeProfile.toText(
                        color: AppColors.softGray,
                        fontSize: 14,
                        textAlign: TextAlign.center,
                      ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final size = (constraints.maxWidth * 1.0)
                            .clamp(260.0, 360.0)
                            .toDouble();
                        return Center(
                          child: FumbleAura(
                            size: size,
                            phase: FumbleAuraPhase.sharing,
                            child: FumbleQrCode(
                              data: payload,
                              size: size * 0.32 + 30,
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    Center(
                      child: TextButton(
                        onPressed: pop,
                        child: AppConstant.tapToCancel.toText(
                          color: AppColors.softGray,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
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
