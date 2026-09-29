import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/services/fumble/flumble_qr.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/navigation/back_icon_button.dart';
import 'package:fumble/view/widgets/qr/flumble_aura.dart';
import 'package:fumble/view/widgets/qr/flumble_qr_code.dart';

/// Device A — share Flumble Aura (galaxy frame + scannable QR).
class FlumbleShareScreen extends ConsumerStatefulWidget {
  const FlumbleShareScreen({super.key});

  static const Duration sessionLength = Duration(seconds: 60);

  @override
  ConsumerState<FlumbleShareScreen> createState() => _FlumbleShareScreenState();
}

class _FlumbleShareScreenState extends ConsumerState<FlumbleShareScreen> {
  Timer? _timer;
  var _remaining = FlumbleShareScreen.sessionLength;
  var _expired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    final code =
        ref.read(currentUserProfileProvider).asData?.value?.flumbleCode;
    if (code == null || code.isEmpty) {
      setState(() => _expired = true);
      return;
    }
    setState(() {
      _expired = false;
      _remaining = FlumbleShareScreen.sessionLength;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 1) {
        _timer?.cancel();
        setState(() => _expired = true);
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  double get _progress =>
      _remaining.inMilliseconds /
      FlumbleShareScreen.sessionLength.inMilliseconds;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider).asData?.value;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.shareMyFumble,
          brandTitle: true,
          leading: BackIconButton(icon: AppIcons.close, onTap: pop),
        ),
        body: profile == null || profile.flumbleCode.isEmpty
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
                    8.height,
                    if (!_expired)
                      AppConstant.nowShareable.toText(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: AppStyle.w600,
                        textAlign: TextAlign.center,
                      ),
                    const Spacer(),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final size = (constraints.maxWidth * 0.9)
                            .clamp(260.0, 360.0)
                            .toDouble();
                        final qrSize = size * 0.42;
                        final payload = FlumbleQr.build(profile.flumbleCode);
                        return FlumbleAura(
                          size: size,
                          phase: _expired
                              ? FlumbleAuraPhase.expired
                              : FlumbleAuraPhase.sharing,
                          child: _expired
                              ? null
                              : ClipOval(
                                  child: ColoredBox(
                                    color: AppColors.gold,
                                    child: FlumbleQrCode(
                                      data: payload,
                                      size: qrSize,
                                    ),
                                  ),
                                ),
                        );
                      },
                    ),
                    24.height,
                    (_expired
                            ? AppConstant.fumbleExpired
                            : AppConstant.readyToFumble)
                        .toText(
                      color: AppColors.gold,
                      fontSize: 22,
                      fontWeight: AppStyle.w600,
                      textAlign: TextAlign.center,
                    ),
                    8.height,
                    (_expired
                            ? AppConstant.shareMyFumble
                            : AppConstant.holdYourFumble)
                        .toText(
                      color: AppColors.softGray,
                      fontSize: 14,
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    if (!_expired) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceElevated,
                          color: AppColors.gold,
                        ),
                      ),
                      10.height,
                      '${AppConstant.sharingStatus} ${_remaining.inSeconds}s'
                          .toText(
                        color: AppColors.softGrayDim,
                        fontSize: 12,
                      ),
                      16.height,
                      TextButton(
                        onPressed: pop,
                        child: AppConstant.tapToCancel.toText(
                          color: AppColors.softGray,
                          fontSize: 15,
                        ),
                      ),
                    ] else
                      PrimaryButton(
                        buttonName: AppConstant.shareMyFumble,
                        onPressed: _start,
                      ),
                    28.height,
                  ],
                ),
              ),
      ),
    );
  }
}
