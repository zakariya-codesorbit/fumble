import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/dialogs/app_bottom_sheet.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';

/// Share a Half Fumble invite via SMS, WhatsApp, and/or the system share sheet.
abstract final class HalfFumbleInviteShare {
  HalfFumbleInviteShare._();

  static String message({
    required String invitedEmail,
    required String storeUrl,
    required String appLink,
  }) {
    return AppConstant.halfFumbleShareMessage(
      invitedEmail: invitedEmail,
      storeUrl: storeUrl,
      appLink: appLink,
    );
  }

  static String digitsOnly(String raw) =>
      raw.replaceAll(RegExp(r'\D'), '');

  /// Opens the device Messages app with [phone] and prefilled [body].
  static Future<bool> sendSms({
    required String phone,
    required String body,
  }) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return false;
    // iOS expects `sms:number&body=…`; Android uses `sms:number?body=…`.
    final sep = Platform.isIOS ? '&' : '?';
    final uri = Uri.parse(
      'sms:$trimmed$sep${'body=${Uri.encodeComponent(body)}'}',
    );
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri);
  }

  /// Opens WhatsApp chat with [phone] and prefilled [body].
  static Future<bool> sendWhatsApp({
    required String phone,
    required String body,
  }) async {
    final digits = digitsOnly(phone);
    if (digits.isEmpty) return false;
    final uri = Uri.parse(
      'https://wa.me/$digits?text=${Uri.encodeComponent(body)}',
    );
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> shareSystem({
    required String body,
    String subject = AppConstant.addSomeone,
  }) {
    return SharePlus.instance.share(
      ShareParams(text: body, subject: subject),
    );
  }

  /// After creating/resending an invite: show channel options based on numbers.
  ///
  /// - Phone → Text Message
  /// - WhatsApp → WhatsApp
  /// - Always → Share (system sheet)
  ///
  /// If only system share is available, opens it directly.
  static Future<void> present({
    required BuildContext context,
    required String invitedEmail,
    required String storeUrl,
    required String appLink,
    String? phone,
    String? whatsApp,
  }) async {
    final body = message(
      invitedEmail: invitedEmail,
      storeUrl: storeUrl,
      appLink: appLink,
    );
    final smsPhone = phone?.trim() ?? '';
    final waPhone = (whatsApp?.trim().isNotEmpty == true)
        ? whatsApp!.trim()
        : '';
    final canSms = smsPhone.isNotEmpty;
    final canWa = waPhone.isNotEmpty;

    if (!canSms && !canWa) {
      await shareSystem(body: body);
      return;
    }

    if (!context.mounted) return;
    await showAppBottomSheet<void>(
      context: context,
      title: AppConstant.halfFumbleShareTitle,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canSms)
              _ShareTile(
                icon: AppIcons.phone,
                iconColor: AppColors.gold,
                label: AppConstant.halfFumbleShareSms,
                subtitle: smsPhone,
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final ok = await sendSms(phone: smsPhone, body: body);
                  if (!ok) {
                    showAppToast(
                      AppConstant.halfFumbleShareSmsFailed,
                      isError: true,
                    );
                  }
                },
              ),
            if (canWa)
              _ShareTile(
                icon: AppIcons.chat,
                iconColor: AppColors.whatsApp,
                label: AppConstant.halfFumbleShareWhatsApp,
                subtitle: waPhone,
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final ok = await sendWhatsApp(phone: waPhone, body: body);
                  if (!ok) {
                    showAppToast(
                      AppConstant.halfFumbleShareWhatsAppFailed,
                      isError: true,
                    );
                  }
                },
              ),
            _ShareTile(
              icon: Icons.ios_share_rounded,
              iconColor: AppColors.softGray,
              label: AppConstant.halfFumbleShareMore,
              subtitle: AppConstant.halfFumbleShareMoreSubtitle,
              onTap: () async {
                Navigator.pop(sheetContext);
                await shareSystem(body: body);
              },
            ),
            8.height,
          ],
        );
      },
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: label.toText(
        fontSize: 15,
        fontWeight: AppStyle.w600,
        color: AppColors.white,
      ),
      subtitle: subtitle.toText(
        fontSize: 12,
        color: AppColors.softGray,
        maxLine: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
