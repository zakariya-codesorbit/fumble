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
  const ConnectionTile({
    super.key,
    required this.connection,
    required this.ownerUid,
    this.onTap,
    this.onDeleteTap,
  });

  final Connection connection;
  final String ownerUid;
  final VoidCallback? onTap;
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
      // Keep placeholder in UI.
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
    return AppConstant.fumbleLocationNotSet;
  }

  String _statusLabel(Connection connection) {
    final displayName = connection.firstName.isNotEmpty
        ? connection.firstName
        : connection.name;
    final raw = connection.youInitiated(widget.ownerUid)
        ? AppConstant.youFumbled(displayName)
        : AppConstant.fumbledYou(displayName);
    return raw.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final connection = widget.connection;
    final date = DateFormat('d MMMM yyyy').format(connection.fumbledAt);
    final time = DateFormat('HH:mm').format(connection.fumbledAt);
    final note = connection.note?.trim() ?? '';
    final canDelete = widget.onDeleteTap != null;
    final place = _fumbleLocationText(connection);
    final placeUnset = place == AppConstant.fumbleLocationNotSet;
    final status = _statusLabel(connection);

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
            onTap: _offset < 0 ? _close : widget.onTap,
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
                              connection.name.toText(
                                fontSize: 16,
                                fontWeight: AppStyle.w600,
                                maxLine: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              4.height,
                              status.toText(
                                fontSize: 11,
                                fontWeight: AppStyle.w600,
                                color: AppColors.gold,
                                letterSpacing: 0.8,
                                maxLine: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        8.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            date.toText(
                              fontSize: 12,
                              fontWeight: AppStyle.w500,
                              color: AppColors.tertiaryText,
                            ),
                            2.height,
                            time.toText(
                              fontSize: 12,
                              fontWeight: AppStyle.w500,
                              color: AppColors.tertiaryText,
                            ),
                          ],
                        ),
                      ],
                    ),
                    10.height,
                    Row(
                      children: [
                        Icon(
                          AppIcons.location,
                          size: 14,
                          color: AppColors.gold,
                        ),
                        6.width,
                        Expanded(
                          child: place.toText(
                            fontSize: 12,
                            fontWeight: AppStyle.w500,
                            color: placeUnset
                                ? AppColors.softGrayDim
                                : AppColors.softGray,
                            maxLine: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (note.isNotEmpty) ...[
                      12.height,
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                      ),
                      10.height,
                      note.toText(
                        fontSize: 13,
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
