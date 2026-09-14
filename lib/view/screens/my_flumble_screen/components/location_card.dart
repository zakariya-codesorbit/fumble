import 'package:flutter/material.dart';

import '../../../../utils/app_assets.dart';
import '../../../../utils/colors.dart';
import '../../../widgets/extention/int_extension.dart';
import '../../../widgets/extention/string_extension.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.location,
    required this.onEdit,
    this.placeholder = false,
  });

  final String location;
  final VoidCallback onEdit;
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: location.toText(
              color: placeholder
                  ? AppColors.softGrayDim
                  : AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(AppIcons.edit, size: 18, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
