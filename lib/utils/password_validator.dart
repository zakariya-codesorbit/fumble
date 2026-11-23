import 'package:fumble/utils/constant.dart';

/// Recommended signup password rules:
/// - at least 8 characters
/// - uppercase + lowercase
/// - at least one number
/// - at least one special character
abstract final class PasswordValidator {
  PasswordValidator._();

  static final _upper = RegExp(r'[A-Z]');
  static final _lower = RegExp(r'[a-z]');
  static final _digit = RegExp(r'[0-9]');
  static final _symbol = RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`]''');

  static const minLength = 8;

  static bool hasMinLength(String value) => value.length >= minLength;
  static bool hasUppercase(String value) => _upper.hasMatch(value);
  static bool hasLowercase(String value) => _lower.hasMatch(value);
  static bool hasLetterCase(String value) =>
      hasUppercase(value) && hasLowercase(value);
  static bool hasNumber(String value) => _digit.hasMatch(value);
  static bool hasSymbol(String value) => _symbol.hasMatch(value);

  /// Login / existing-account check — non-empty only.
  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstant.passwordRequired;
    }
    return null;
  }

  /// Signup / create-password rules.
  static String? validateStrong(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstant.passwordRequired;
    }
    if (!hasMinLength(value)) {
      return AppConstant.passwordTooShort;
    }
    if (!hasUppercase(value)) {
      return AppConstant.passwordNeedsUppercase;
    }
    if (!hasLowercase(value)) {
      return AppConstant.passwordNeedsLowercase;
    }
    if (!hasNumber(value)) {
      return AppConstant.passwordNeedsNumber;
    }
    if (!hasSymbol(value)) {
      return AppConstant.passwordNeedsSymbol;
    }
    return null;
  }

  static String? validateConfirm(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppConstant.confirmPasswordRequired;
    }
    if (value != password) {
      return AppConstant.passwordMismatch;
    }
    return null;
  }
}
