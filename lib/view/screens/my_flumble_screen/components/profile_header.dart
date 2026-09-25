import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/inputs/custom_text_field.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.heading,
    this.localFile,
    this.svg,
    this.editingName = false,
    this.nameController,
    this.onNameTap,
    this.onNameChanged,
    this.onNameTapOutside,
    this.onPhotoTap,
  });

  final String name;
  final String? photoUrl;
  final String heading;
  final File? localFile;
  final String? svg;
  final bool editingName;
  final TextEditingController? nameController;
  final VoidCallback? onNameTap;
  final ValueChanged<String>? onNameChanged;
  final VoidCallback? onNameTapOutside;
  final VoidCallback? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        20.height,
        ProfileAvatar(
          photoUrl: photoUrl,
          localFile: localFile,
          svg: svg,
          name: name,
          size: 128,
          onTap: onPhotoTap,
        ),
        18.height,
        if (editingName && nameController != null)
          CustomTextField(
            controller: nameController!,
            hintText: name,
            onChanged: onNameChanged,
            onTapOutside: onNameTapOutside,
            autofocus: true,
          )
        else
          name
              .toText(
                fontSize: 28,
                fontWeight: AppStyle.w700,
                textAlign: TextAlign.center,
              )
              .onPress(onNameTap ?? () {}),
      ],
    );
  }
}
