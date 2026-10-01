import 'package:flutter/material.dart';

import '../../../../utils/app_assets.dart';
import '../../../../utils/colors.dart';
import '../../../widgets/extention/int_extension.dart';
import '../../../widgets/extention/string_extension.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.location,
    this.onTap,
    this.placeholder = false,
    this.editor,
  });

  final String location;
  final VoidCallback? onTap;
  final bool placeholder;
  final Widget? editor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.navBar,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.goldMuted.withAlpha(30)),
        ),
        child: Row(
          children: [
            Icon(
              AppIcons.location,
              size: 20,
              color: placeholder
                  ? AppColors.softGrayDim
                  : AppColors.secondaryText,
            ),
            10.width,
            Expanded(
              child: editor ??
                  location.toText(
                    color: placeholder
                        ? AppColors.softGrayDim
                        : AppColors.secondaryText,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
