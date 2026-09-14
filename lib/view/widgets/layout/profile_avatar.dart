import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/services/storage/profile_photo_service.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.localFile,
    this.name,
    this.size = 64,
    this.onTap,
  });

  /// Network URL or base64 JPEG string (Firestore-backed, no Storage).
  final String? photoUrl;
  final File? localFile;
  final String? name;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initial = (name != null && name!.trim().isNotEmpty)
        ? name!.trim().characters.first.toUpperCase()
        : '?';

    Widget child;
    if (localFile != null) {
      child = Image.file(localFile!, fit: BoxFit.cover);
    } else if (ProfilePhotoService.isNetworkUrl(photoUrl)) {
      child = CachedNetworkImage(
        imageUrl: photoUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _Initial(initial: initial, size: size),
        errorWidget: (context, url, error) =>
            _Initial(initial: initial, size: size),
      );
    } else {
      final bytes = ProfilePhotoService.decodeBase64(photoUrl);
      if (bytes != null) {
        child = Image.memory(
          Uint8List.fromList(bytes),
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      } else {
        child = _Initial(initial: initial, size: size);
      }
    }

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceElevated,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );

    if (onTap == null) return avatar;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          avatar,
          Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 2),
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: size * 0.14,
              color: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.initial, required this.size});
  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.gold,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
