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

class ConnectionTile extends StatelessWidget {
  const ConnectionTile({super.key, required this.connection});

  final Connection connection;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'MMM d, yyyy · h:mm a',
    ).format(connection.fumbledAt);
    final subtitle = connection.hasBio ? connection.bio! : null;
    final email = connection.email.trim();
    final badge = _syncBadge(connection.syncStatus);
    return Container(
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
