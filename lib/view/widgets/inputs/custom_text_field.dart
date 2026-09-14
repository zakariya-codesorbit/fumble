import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.obscureText = false,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
    this.autofillHints,
    this.isReadOnly = false,
    this.maxLine = 1,
    this.inputFormatter = 200,
    this.focusNode,
    this.onTap,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final bool obscureText;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final bool isReadOnly;
  final int maxLine;
  final int inputFormatter;
  final FocusNode? focusNode;
  final VoidCallback? onTap;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword || widget.obscureText;
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isPassword && oldWidget.obscureText != widget.obscureText) {
      _obscure = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          widget.label!.toText(
            color: AppColors.gold,
            fontSize: 12,
            fontWeight: AppStyle.w600,
            letterSpacing: 1.2,
          ),
          8.height,
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscure,
          readOnly: widget.isReadOnly,
          maxLines: widget.maxLine,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          cursorColor: AppColors.gold,
          style: TextStyle(
            fontSize: 16,
            fontWeight: AppStyle.w400,
            color: AppColors.white,
            fontFamilyFallback: AppStyle.fontFamilyFallback,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(widget.inputFormatter),
          ],
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            hintText: widget.hintText,
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
            suffixIcon: widget.suffixIcon ??
                (widget.isPassword
                    ? IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? AppIcons.visibilityOn
                              : AppIcons.visibilityOff,
                          color: AppColors.softGray,
                        ),
                      )
                    : null),
          ),
        ),
      ],
    );
  }
}

class BaseEmailField extends StatelessWidget {
  const BaseEmailField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: AppConstant.emailLabel,
      hintText: AppConstant.emailHint,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      onSubmitted: onSubmitted,
      validator: (value) {
        if (value == null || value.isBlank) {
          return AppConstant.emailRequired;
        }
        if (!value.isValidEmail) return AppConstant.emailInvalid;
        return null;
      },
    );
  }
}

class BasePasswordField extends StatelessWidget {
  const BasePasswordField({
    super.key,
    required this.controller,
    this.hintText,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const [AutofillHints.password],
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? hintText;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: AppConstant.passwordLabel,
      hintText: hintText ?? AppConstant.passwordHint,
      isPassword: true,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppConstant.passwordRequired;
        }
        if (value.length < 6) return AppConstant.passwordTooShort;
        return null;
      },
    );
  }
}
