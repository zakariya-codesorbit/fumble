import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fumble/data/models/connection.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

class ConnectionTile extends StatefulWidget {
  const ConnectionTile({
    super.key,
    required this.connection,
    this.onDeleteTap,
  });

  final Connection connection;
  final VoidCallback? onDeleteTap;

  @override
  State<ConnectionTile> createState() => _ConnectionTileState();
}

class _ConnectionTileState extends State<ConnectionTile> {
  static const _actionWidth = 72.0;
  double _offset = 0;

  void _close() {
    if (_offset == 0) return;
    setState(() => _offset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final connection = widget.connection;
    final date = DateFormat(
      'MMM d, yyyy · h:mm a',
    ).format(connection.fumbledAt);
    final subtitle = connection.hasBio ? connection.bio! : null;
    final phone = connection.visiblePhone;
    final email = connection.visibleEmail;
    final badge = _syncBadge(connection.syncStatus);
    final canDelete = widget.onDeleteTap != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppStyle.radiusLg),
      child: Stack(
        children: [
          if (canDelete)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    _close();
                    widget.onDeleteTap?.call();
                  },
                  child: Container(
                    width: _actionWidth,
                    color: AppColors.error,
                    alignment: Alignment.center,
                    child: const Icon(
                      AppIcons.deleteOutline,
                      color: AppColors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          GestureDetector(
            onHorizontalDragUpdate: canDelete
                ? (details) {
                    setState(() {
                      _offset = (_offset + details.delta.dx)
                          .clamp(-_actionWidth, 0.0);
                    });
                  }
                : null,
            onHorizontalDragEnd: canDelete
                ? (details) {
                    final open = _offset < -_actionWidth / 2 ||
                        (details.primaryVelocity ?? 0) < -400;
                    setState(() => _offset = open ? -_actionWidth : 0);
                  }
                : null,
            onTap: _offset < 0 ? _close : null,
            child: Transform.translate(
              offset: Offset(_offset, 0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppStyle.radiusLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileAvatar(
                      photoUrl: connection.photoUrl,
                      name: connection.name,
                      size: AppStyle.connectionAvatar,
                    ),
                    12.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          connection.name.toText(
                            fontSize: 16,
                            fontWeight: AppStyle.w600,
                            maxLine: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            2.height,
                            subtitle.toText(
                              fontSize: 12,
                              fontWeight: AppStyle.w500,
                              color: AppColors.gold,
                              maxLine: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (phone != null) ...[
                            2.height,
                            phone.toText(
                              fontSize: 12,
                              fontWeight: AppStyle.w500,
                              color: AppColors.softGray,
                              maxLine: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (email.isNotEmpty) ...[
                            2.height,
                            email.toText(
                              fontSize: 12,
                              fontWeight: AppStyle.w500,
                              color: AppColors.softGray,
                              maxLine: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          4.height,
                          AppConstant.fumbledOnLabel(date).toText(
                            fontSize: 12,
                            fontWeight: AppStyle.w500,
                            color: AppColors.softGray,
                          ),
                        ],
                      ),
                    ),
                    if (badge != null) ...[
                      8.width,
                      _SyncBadge(badge: badge),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({required this.badge});

  final ({String label, IconData icon, Color color}) badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badge.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppStyle.radiusPill),
        border: Border.all(color: badge.color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badge.icon, size: 12, color: badge.color),
          4.width,
          badge.label.toText(
            fontSize: 11,
            fontWeight: AppStyle.w600,
            color: badge.color,
          ),
        ],
      ),
    );
  }
}

({String label, IconData icon, Color color})? _syncBadge(SyncStatus status) {
  return switch (status) {
    SyncStatus.synced => null,
    SyncStatus.syncing => (
      label: AppConstant.syncStatusSyncing,
      icon: AppIcons.refresh,
      color: AppColors.gold,
    ),
    SyncStatus.failed => (
      label: AppConstant.syncStatusFailed,
      icon: AppIcons.refresh,
      color: AppColors.error,
    ),
    SyncStatus.pending => (
      label: AppConstant.pendingSync,
      icon: AppIcons.refresh,
      color: AppColors.softGray,
    ),
  };
}
