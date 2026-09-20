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
    this.initialDialCode = '+1',
    this.initialCountryCode = 'US',
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String initialDialCode;
  final String initialCountryCode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

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
    String fallbackDialCode = '+1',
    String fallbackCountryCode = 'US',
  }) {
    final raw = stored?.trim() ?? '';
    if (raw.isEmpty) {
      return (
        dialCode: fallbackDialCode,
        countryCode: fallbackCountryCode,
        national: '',
      );
    }
    if (!raw.startsWith('+')) {
      return (
        dialCode: fallbackDialCode,
        countryCode: fallbackCountryCode,
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
          countryCode: match['code'] ?? fallbackCountryCode,
          national: digits.substring(len),
        );
      }
    }
    return (
      dialCode: fallbackDialCode,
      countryCode: fallbackCountryCode,
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
    _dialCode = widget.initialDialCode;
    _countryCode = widget.initialCountryCode;
  }

  @override
  void didUpdateWidget(PhoneCountryField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDialCode != widget.initialDialCode ||
        oldWidget.initialCountryCode != widget.initialCountryCode) {
      _dialCode = widget.initialDialCode;
      _countryCode = widget.initialCountryCode;
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
                favorite: const ['US', 'GB', 'IN', 'AE', 'CA'],
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
                  if (value == null || value.isBlank) {
                    return AppConstant.phoneRequired;
                  }
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
