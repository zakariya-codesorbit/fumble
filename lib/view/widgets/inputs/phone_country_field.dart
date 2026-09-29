import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Phone input with country dial-code picker (dark-theme Flumble styling).
class PhoneCountryField extends StatefulWidget {
  const PhoneCountryField({
    super.key,
    required this.controller,
    this.initialDialCode,
    this.initialCountryCode,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? initialDialCode;
  final String? initialCountryCode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  /// Country from the device region / current locale (e.g. PK, US).
  static ({String dialCode, String countryCode}) fromDeviceLocale() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final candidates = <String>[
      if (locale.countryCode != null && locale.countryCode!.isNotEmpty)
        locale.countryCode!.toUpperCase(),
      ...WidgetsBinding.instance.platformDispatcher.locales
          .map((l) => l.countryCode?.toUpperCase())
          .whereType<String>()
          .where((c) => c.isNotEmpty),
    ];

    for (final country in candidates) {
      final match = codes.firstWhere(
        (c) => (c['code'] ?? '').toUpperCase() == country,
        orElse: () => const <String, String>{},
      );
      if (match.isNotEmpty) {
        return (
          dialCode: match['dial_code'] ?? '+1',
          countryCode: match['code'] ?? 'US',
        );
      }
    }
    return (dialCode: '+1', countryCode: 'US');
  }

  static bool isValidNational(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return value.replaceAll(RegExp(r'\D'), '').length >= 7;
  }

  static String formatFull({
    required String dialCode,
    required String national,
  }) {
    final digits = national.replaceAll(RegExp(r'\D'), '');
    final code = dialCode.startsWith('+') ? dialCode : '+$dialCode';
    return '$code$digits';
  }

  /// Best-effort split of a stored E.164-ish value into dial code + national.
  static ({String dialCode, String countryCode, String national}) parseStored(
    String? stored, {
    String? fallbackDialCode,
    String? fallbackCountryCode,
  }) {
    final device = fromDeviceLocale();
    final fbDial = fallbackDialCode ?? device.dialCode;
    final fbCountry = fallbackCountryCode ?? device.countryCode;

    final raw = stored?.trim() ?? '';
    if (raw.isEmpty) {
      return (
        dialCode: fbDial,
        countryCode: fbCountry,
        national: '',
      );
    }
    if (!raw.startsWith('+')) {
      return (
        dialCode: fbDial,
        countryCode: fbCountry,
        national: raw.replaceAll(RegExp(r'\D'), ''),
      );
    }
    final digits = raw.substring(1).replaceAll(RegExp(r'\D'), '');
    for (var len = 4; len >= 1; len--) {
      if (digits.length <= len) continue;
      final code = '+${digits.substring(0, len)}';
      final match = codes.firstWhere(
        (c) => c['dial_code'] == code,
        orElse: () => const <String, String>{},
      );
      if (match.isNotEmpty) {
        return (
          dialCode: code,
          countryCode: match['code'] ?? fbCountry,
          national: digits.substring(len),
        );
      }
    }
    return (
      dialCode: fbDial,
      countryCode: fbCountry,
      national: digits,
    );
  }

  @override
  State<PhoneCountryField> createState() => PhoneCountryFieldState();
}

class PhoneCountryFieldState extends State<PhoneCountryField> {
  late String _dialCode;
  late String _countryCode;

  String get dialCode => _dialCode;

  String get fullNumber => PhoneCountryField.formatFull(
        dialCode: _dialCode,
        national: widget.controller.text,
      );

  @override
  void initState() {
    super.initState();
    final device = PhoneCountryField.fromDeviceLocale();
    _dialCode = widget.initialDialCode ?? device.dialCode;
    _countryCode = widget.initialCountryCode ?? device.countryCode;
  }

  @override
  void didUpdateWidget(PhoneCountryField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDialCode != widget.initialDialCode ||
        oldWidget.initialCountryCode != widget.initialCountryCode) {
      final device = PhoneCountryField.fromDeviceLocale();
      _dialCode = widget.initialDialCode ?? device.dialCode;
      _countryCode = widget.initialCountryCode ?? device.countryCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppConstant.phoneLabel.toText(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: AppStyle.w600,
          letterSpacing: 1.2,
        ),
        8.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52.h,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(AppStyle.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: CountryCodePicker(
                onChanged: (code) {
                  setState(() {
                    _dialCode = code.dialCode ?? _dialCode;
                    _countryCode = code.code ?? _countryCode;
                  });
                  widget.onChanged?.call(fullNumber);
                },
                onInit: (code) {
                  if (code == null) return;
                  _dialCode = code.dialCode ?? _dialCode;
                  _countryCode = code.code ?? _countryCode;
                },
                initialSelection: _countryCode,
                showFlag: true,
                showDropDownButton: true,
                flagWidth: 22,
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: AppStyle.w500,
                  color: AppColors.white,
                  fontFamilyFallback: AppStyle.fontFamilyFallback,
                ),
                dialogTextStyle: TextStyle(
                  fontSize: 15,
                  color: AppColors.white,
                  fontFamilyFallback: AppStyle.fontFamilyFallback,
                ),
                searchStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.white,
                  fontFamilyFallback: AppStyle.fontFamilyFallback,
                ),
                searchDecoration: InputDecoration(
                  hintText: AppConstant.searchCountry,
                  hintStyle: TextStyle(
                    color: AppColors.softGray,
                    fontFamilyFallback: AppStyle.fontFamilyFallback,
                  ),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.radiusMd),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.radiusMd),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.radiusMd),
                    borderSide: const BorderSide(color: AppColors.gold),
                  ),
                ),
                dialogBackgroundColor: AppColors.surfaceElevated,
                backgroundColor: AppColors.surfaceElevated,
                barrierColor: AppColors.background.withValues(alpha: 0.72),
                boxDecoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.gold.withValues(alpha: 0.22),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.55),
                      blurRadius: 28,
                      offset: const Offset(0, -8),
                    ),
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                headerText: AppConstant.selectCountry,
                headerTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: AppStyle.w600,
                  color: AppColors.white,
                  fontFamilyFallback: AppStyle.fontFamilyFallback,
                ),
                closeIcon:
                    const Icon(Icons.close_rounded, color: AppColors.softGray),
                pickerStyle: PickerStyle.bottomSheet,
              ),
            ),
            10.width,
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                keyboardType: TextInputType.phone,
                textInputAction: widget.textInputAction,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                onFieldSubmitted: widget.onSubmitted,
                onChanged: (_) => widget.onChanged?.call(fullNumber),
                cursorColor: AppColors.gold,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: AppStyle.w400,
                  color: AppColors.white,
                  fontFamilyFallback: AppStyle.fontFamilyFallback,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                validator: (value) {
                  if (value == null || value.isBlank) return null;
                  if (!PhoneCountryField.isValidNational(value)) {
                    return AppConstant.phoneInvalid;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: AppConstant.phoneHint,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: AppStyle.w400,
                    color: AppColors.softGrayDim,
                    fontFamilyFallback: AppStyle.fontFamilyFallback,
                  ),
                  errorStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                    fontFamilyFallback: AppStyle.fontFamilyFallback,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
