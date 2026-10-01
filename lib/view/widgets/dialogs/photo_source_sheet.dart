import 'package:flutter/material.dart';

import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/photo_action_tile.dart';
import 'package:fumble/view/widgets/dialogs/app_bottom_sheet.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';

enum PhotoSourceChoice { camera, gallery, avatar, remove }

Future<PhotoSourceChoice?> showPhotoSourceSheet(
  BuildContext context, {
  bool showRemove = false,
}) {
  return showAppBottomSheet<PhotoSourceChoice>(
    context: context,
    title: AppConstant.changePhoto,
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhotoActionTile(
            icon: AppIcons.camera,
            label: AppConstant.takePhoto,
            onTap: () => Navigator.pop(sheetContext, PhotoSourceChoice.camera),
          ),
          PhotoActionTile(
            icon: AppIcons.photoLibrary,
            label: AppConstant.chooseFromLibrary,
            onTap: () => Navigator.pop(sheetContext, PhotoSourceChoice.gallery),
          ),
          PhotoActionTile(
            icon: Icons.face_retouching_natural_outlined,
            label: AppConstant.avatars,
            onTap: () => Navigator.pop(sheetContext, PhotoSourceChoice.avatar),
          ),
          if (showRemove)
            PhotoActionTile(
              icon: AppIcons.deleteOutline,
              label: AppConstant.removePhoto,
              destructive: true,
              onTap: () =>
                  Navigator.pop(sheetContext, PhotoSourceChoice.remove),
            ),
          8.height,
        ],
      );
    },
  );
}
