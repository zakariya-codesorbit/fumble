import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/auth_screen/components/auth_actions.dart';
import 'package:fumble/view/screens/auth_screen/components/password_requirements_hint.dart';
import 'package:fumble/view/screens/auth_screen/components/top_view.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/buttons/text_button_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import 'package:fumble/view/widgets/inputs/custom_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _confirmFieldKey = GlobalKey<FormFieldState<String>>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  var _passwordDraft = '';
  var _agreedToLegal = false;
  late final TapGestureRecognizer _privacyTap;
  late final TapGestureRecognizer _termsTap;

  @override
  void initState() {
    super.initState();
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => push(AppRoutes.privacyPolicy);
    _termsTap = TapGestureRecognizer()..onTap = () => push(AppRoutes.terms);
  }

  @override
  void dispose() {
    _privacyTap.dispose();
    _termsTap.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _revalidateConfirm() {
    final field = _confirmFieldKey.currentState;
    if (field == null) return;
    if (_confirmPassword.text.isEmpty && !field.hasError) return;
    field.validate();
  }

  Future<void> _submit() async {
    if (!_agreedToLegal) {
      showAppToast(AppConstant.agreeLegalRequired, isError: true);
      return;
    }
    await AuthActions.signUp(
      ref: ref,
      formKey: _formKey,
      name: _name.text,
      email: _email.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        body: SafeArea(
          child: SingleChildScrollView(
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TopView(
                      title: AppConstant.signupTitle,
                      subtitle: AppConstant.signupSubtitle,
                    ),
                    CustomTextField(
                      controller: _name,
                      label: AppConstant.nameLabel,
                      hintText: AppConstant.nameHint,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: (value) {
                        if (value == null || value.isBlank) {
                          return AppConstant.nameRequired;
                        }
                        return null;
                      },
                    ),
                    20.height,
                    BaseEmailField(controller: _email),
                    20.height,
                    BasePasswordField(
                      controller: _password,
                      hintText: AppConstant.passwordHint,
                      requireStrongPassword: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: (value) {
                        setState(() => _passwordDraft = value);
                        _revalidateConfirm();
                      },
                    ),
                    PasswordRequirementsHint(password: _passwordDraft),
                    20.height,
                    BasePasswordField(
                      controller: _confirmPassword,
                      matchController: _password,
                      formFieldKey: _confirmFieldKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: (_) => _revalidateConfirm(),
                      onSubmitted: (_) => _submit(),
                    ),
                    20.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreedToLegal,
                            activeColor: AppColors.primary,
                            checkColor: AppColors.background,
                            side: const BorderSide(color: AppColors.textSecondary),
                            onChanged: (value) {
                              setState(() => _agreedToLegal = value ?? false);
                            },
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontFamily: AppStyle.fontFamily,
                                fontFamilyFallback: AppStyle.fontFamilyFallback,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                  text: AppConstant.agreeLegalPrefix,
                                ),
                                TextSpan(
                                  text: AppConstant.privacyPolicy,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: AppStyle.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary,
                                  ),
                                  recognizer: _privacyTap,
                                ),
                                const TextSpan(text: AppConstant.agreeLegalAnd),
                                TextSpan(
                                  text: AppConstant.termsAndConditions,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: AppStyle.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary,
                                  ),
                                  recognizer: _termsTap,
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    24.height,
                    PrimaryButton(
                      buttonName: AppConstant.signupCta,
                      onPressed: _agreedToLegal ? _submit : null,
                    ),
                    24.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppConstant.hasAccount.toText(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        TextButtonWidget(
                          buttonName: AppConstant.loginCta,
                          fontWeight: AppStyle.w600,
                          onPressed: AuthActions.goToLogin,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).paddingSymmetric(horizontal: 28.w),
          ),
        ),
      ),
    );
  }
}
