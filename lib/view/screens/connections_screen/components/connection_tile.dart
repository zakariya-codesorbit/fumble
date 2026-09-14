import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fumble/data/models/connection.dart';
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
    final date = DateFormat('MMM d, yyyy · h:mm a').format(connection.fumbledAt);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyle.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
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
                ),
                if (connection.email.isNotEmpty) ...[
                  2.height,
                  connection.email.toText(
                    fontSize: 12,
                    fontWeight: AppStyle.w500,
                    color: AppColors.gold,
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
        ],
      ),
    );
  }
}
