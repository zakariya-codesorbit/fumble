import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/connection.dart';
import 'package:fumble/data/models/playground_adventure.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';
import 'package:fumble/view/widgets/media/ai_test_video_player.dart';

class FumblePlaygroundDetailArgs {
  const FumblePlaygroundDetailArgs({required this.adventureId});

  final String adventureId;
}

class FumblePlaygroundDetailScreen extends ConsumerStatefulWidget {
  const FumblePlaygroundDetailScreen({super.key, required this.adventureId});

  final String adventureId;

  @override
  ConsumerState<FumblePlaygroundDetailScreen> createState() =>
      _FumblePlaygroundDetailScreenState();
}

class _FumblePlaygroundDetailScreenState
    extends ConsumerState<FumblePlaygroundDetailScreen> {
  String? _selectedPeerUid;

  void _comingSoon() => showAppToast(AppConstant.aiComingSoon);

  @override
  Widget build(BuildContext context) {
    final adventure =
        PlaygroundAdventures.byId(widget.adventureId) ??
        PlaygroundAdventures.all.first;
    final connections =
        ref.watch(connectionsProvider).valueOrNull ?? const <Connection>[];
    Connection? selected;
    for (final c in connections) {
      if (c.peerUid == _selectedPeerUid) {
        selected = c;
        break;
      }
    }

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: adventure.title,
          showBack: true,
          onBack: pop,
          centerTitle: true,
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
          children: [
            AppConstant.whoAreYouFumblingWith.toText(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: AppStyle.w700,
              letterSpacing: 1.2,
              textAlign: TextAlign.start,
            ),
            14.height,
            _FumblePickerRow(
              connections: connections,
              selectedPeerUid: _selectedPeerUid,
              onSelect: (peerUid) => setState(() => _selectedPeerUid = peerUid),
            ),
            28.height,
            Center(child: _SelectedFumbleAvatar(connection: selected)),
            12.height,
            AppConstant.pickAFumbleAbove.toText(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: AppStyle.w700,
              textAlign: TextAlign.center,
            ),
            20.height,
            PrimaryButton(
              buttonName: AppConstant.generateAdventure,
              onPressed: _comingSoon,
              textSize: 14,
            ),
            24.height,
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.primary, width: 1.2),
              ),
              clipBehavior: Clip.antiAlias,
              padding: EdgeInsets.all(10.w),
              child: const AiTestVideoPlayer(aspectRatio: 3 / 4),
            ),
            16.height,
            _ShareWithFumbleButton(onTap: _comingSoon),
          ],
        ),
      ),
    );
  }
}

class _FumblePickerRow extends StatelessWidget {
  const _FumblePickerRow({
    required this.connections,
    required this.selectedPeerUid,
    required this.onSelect,
  });

  final List<Connection> connections;
  final String? selectedPeerUid;
  final ValueChanged<String> onSelect;

  static const _minSlots = 5;

  @override
  Widget build(BuildContext context) {
    final slotCount = connections.length >= _minSlots
        ? connections.length
        : _minSlots;

    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: slotCount,
        separatorBuilder: (_, _) => 8.width,
        itemBuilder: (context, index) {
          if (index < connections.length) {
            final connection = connections[index];
            final selected = connection.peerUid == selectedPeerUid;
            return _FumblePickCard(
              name: connection.firstName.isNotEmpty
                  ? connection.firstName
                  : connection.name,
              photoUrl: connection.photoUrl,
              selected: selected,
              onTap: () => onSelect(connection.peerUid),
            );
          }
          return const _FumblePickCard.empty();
        },
      ),
    );
  }
}

class _FumblePickCard extends StatelessWidget {
  const _FumblePickCard({
    required this.name,
    this.photoUrl,
    this.selected = false,
    this.onTap,
  }) : empty = false;

  const _FumblePickCard.empty()
    : name = '',
      photoUrl = null,
      selected = false,
      onTap = null,
      empty = true;

  final String name;
  final String? photoUrl;
  final bool selected;
  final VoidCallback? onTap;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.clear,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 81.w,
          padding: EdgeInsets.fromLTRB(2.w, 10.h, 2.w, 8.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              if (empty)
                Container(
                  width: 54.w,
                  height: 54.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.2),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    AppIcons.person,
                    color: AppColors.primary,
                    size: 24,
                  ),
                )
              else
                ProfileAvatar(photoUrl: photoUrl, name: name, size: 54.w),
              8.height,
              if (!empty)
                name.toText(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: AppStyle.w600,
                  textAlign: TextAlign.center,
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedFumbleAvatar extends StatelessWidget {
  const _SelectedFumbleAvatar({this.connection});

  final Connection? connection;

  @override
  Widget build(BuildContext context) {
    const size = 110.0;
    return CustomPaint(
      foregroundPainter: _DottedCirclePainter(
        color: AppColors.primary,
        strokeWidth: 1.6,
        dashWidth: 3,
        dashGap: 3,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: connection == null
              ? Container(
                  width: size - 10,
                  height: size - 10,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    AppIcons.person,
                    color: AppColors.primary,
                    size: 42,
                  ),
                )
              : ProfileAvatar(
                  photoUrl: connection!.photoUrl,
                  name: connection!.name,
                  size: size - 10,
                ),
        ),
      ),
    );
  }
}

class _ShareWithFumbleButton extends StatelessWidget {
  const _ShareWithFumbleButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.clear,
      borderRadius: BorderRadius.circular(AppStyle.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyle.radiusPill),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyle.radiusPill),
            border: Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(AppIcons.share, size: 18, color: AppColors.primary),
              8.width,
              AppConstant.shareWithAFumble.toText(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: AppStyle.w700,
                letterSpacing: 0.6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  _DottedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final rect =
        Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final path = Path()..addOval(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}
