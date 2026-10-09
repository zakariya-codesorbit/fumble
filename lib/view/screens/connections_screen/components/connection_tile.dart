import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fumble/data/models/connection.dart';
import 'package:fumble/services/location/fumble_location_service.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

class ConnectionTile extends StatefulWidget {
  const ConnectionTile({super.key, required this.connection, this.onDeleteTap});

  final Connection connection;
  final VoidCallback? onDeleteTap;

  @override
  State<ConnectionTile> createState() => _ConnectionTileState();
}

class _ConnectionTileState extends State<ConnectionTile> {
  static const _actionWidth = 72.0;
  double _offset = 0;
  String? _placeLabel;
  var _placeLoading = false;

  @override
  void initState() {
    super.initState();
    _resolvePlace();
  }

  @override
  void didUpdateWidget(covariant ConnectionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.connection;
    final next = widget.connection;
    if (old.fumblePlace != next.fumblePlace ||
        old.fumbleLocation?.latitude != next.fumbleLocation?.latitude ||
        old.fumbleLocation?.longitude != next.fumbleLocation?.longitude) {
      _placeLabel = null;
      _resolvePlace();
    }
  }

  Future<void> _resolvePlace() async {
    final saved = widget.connection.fumblePlace?.trim();
    if (saved != null && saved.isNotEmpty) {
      _placeLabel = saved;
      return;
    }
    final loc = widget.connection.fumbleLocation;
    if (loc == null || _placeLoading) return;
    _placeLoading = true;
    try {
      final label = await FumbleLocationService.placeLabel(loc);
      if (!mounted || label == null) return;
      setState(() => _placeLabel = label);
    } catch (_) {
      // Keep coords fallback in UI.
    } finally {
      _placeLoading = false;
    }
  }

  void _close() {
    if (_offset == 0) return;
    setState(() => _offset = 0);
  }

  String _fumbleLocationText(Connection connection) {
    final saved = connection.fumblePlace?.trim();
    if (saved != null && saved.isNotEmpty) return saved;
    if (_placeLabel != null && _placeLabel!.trim().isNotEmpty) {
      return _placeLabel!.trim();
    }
    final loc = connection.fumbleLocation;
    if (loc == null) return '—';
    return '${loc.latitude.toStringAsFixed(2)}°, ${loc.longitude.toStringAsFixed(2)}°';
  }

  @override
  Widget build(BuildContext context) {
    final connection = widget.connection;
    final date = DateFormat('MMM d, yyyy').format(connection.fumbledAt);
    final time = DateFormat('h:mm a').format(connection.fumbledAt);
    final note = connection.note?.trim() ?? '';
    final badge = _syncBadge(connection.syncStatus);
    final canDelete = widget.onDeleteTap != null;
    final place = _fumbleLocationText(connection);

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
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
                      _offset = (_offset + details.delta.dx).clamp(
                        -_actionWidth,
                        0.0,
                      );
                    });
                  }
                : null,
            onHorizontalDragEnd: canDelete
                ? (details) {
                    final open =
                        _offset < -_actionWidth / 2 ||
                        (details.primaryVelocity ?? 0) < -400;
                    setState(() => _offset = open ? -_actionWidth : 0);
                  }
                : null,
            onTap: _offset < 0 ? _close : null,
            child: Transform.translate(
              offset: Offset(_offset, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileAvatar(
                          photoUrl: connection.photoUrl,
                          name: connection.name,
                          size: 45.w,
                        ),
                        10.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: connection.name.toText(
                                      fontSize: 16,
                                      fontWeight: AppStyle.w600,
                                      maxLine: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (badge != null) ...[
                                    8.width,
                                    _SyncBadge(badge: badge),
                                  ],
                                ],
                              ),
                              4.height,
                              _MetaRow(
                                leading: AppConstant.metAtCoffeeBar,
                                trailing: date,
                              ),
                              4.height,
                              _MetaRow(
                                leading: place,
                                trailing: time,
                                showLocationIcon: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (note.isNotEmpty) ...[
                      6.height,
                      note.toText(
                        fontSize: 12,
                        fontWeight: AppStyle.w400,
                        color: AppColors.tertiaryText,
                        maxLine: 3,
                        overflow: TextOverflow.ellipsis,
                        lineHeight: 1.35,
                      ),
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.leading,
    required this.trailing,
    this.showLocationIcon = false,
  });

  final String leading;
  final String trailing;
  final bool showLocationIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showLocationIcon) ...[
          Icon(AppIcons.location, size: 14, color: AppColors.tertiaryText),
          4.width,
        ],
        Expanded(
          child: leading.toText(
            fontSize: 12,
            fontWeight: AppStyle.w500,
            color: AppColors.tertiaryText,
            maxLine: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        8.width,
        trailing.toText(
          fontSize: 12,
          fontWeight: AppStyle.w500,
          color: AppColors.tertiaryText,
        ),
      ],
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
