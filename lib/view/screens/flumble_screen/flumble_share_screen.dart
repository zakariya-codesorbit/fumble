import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/services/fumble/flumble_qr.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/navigation/back_icon_button.dart';
import 'package:fumble/view/widgets/qr/flumble_aura.dart';
import 'package:fumble/view/widgets/qr/flumble_qr_code.dart';

/// Share screen — galaxy Aura + scannable QR only.
class FlumbleShareScreen extends ConsumerWidget {
  const FlumbleShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final code = profile?.flumbleCode;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          leading: BackIconButton(icon: AppIcons.close, onTap: pop),
        ),
        body: code == null || code.isEmpty
            ? Center(
                child: AppConstant.completeProfile.toText(
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
                        final size = (constraints.maxWidth * 0.9)
                            .clamp(260.0, 360.0)
                            .toDouble();
                        return Center(
                          child: FlumbleAura(
                            size: size,
                            phase: FlumbleAuraPhase.sharing,
                            child: ClipOval(
                              child: ColoredBox(
                                color: AppColors.gold,
                                child: FlumbleQrCode(
                                  data: FlumbleQr.build(code),
                                  size: size * 0.42,
                                ),
                              ),
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
}
