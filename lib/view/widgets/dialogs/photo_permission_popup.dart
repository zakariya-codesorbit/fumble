import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/setting_screen/components/setting_actions.dart';

/// Returns true when the camera or photo library can be used.
/// A denied permission opens a settings popup instead of a toast.
Future<bool> ensurePhotoSourcePermission(
  BuildContext context, {
  required bool camera,
}) async {
  if (!camera && !Platform.isIOS) return true;

  final permission = camera ? Permission.camera : Permission.photos;
  var status = await permission.status;
  if (!status.isGranted && !status.isLimited) {
    status = await permission.request();
  }
  if (status.isGranted || status.isLimited) return true;
  if (!context.mounted) return false;
  await showPhotoPermissionPopup(context, camera: camera);
  return false;
}

Future<void> showPhotoPermissionPopup(
  BuildContext context, {
  required bool camera,
}) {
  return SettingActions.showConfirmSheet(
    context: context,
    title: AppConstant.photoPermissionTitle,
    description: camera
        ? AppConstant.cameraPermissionSettings
        : AppConstant.galleryPermissionSettings,
    primaryCta: AppConstant.openSettings,
    destructive: false,
    onPrimaryTap: openAppSettings,
  );
}

bool isPhotoPermissionError(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('denied') ||
      text.contains('permission') ||
      text.contains('restricted');
}
