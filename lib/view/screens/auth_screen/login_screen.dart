import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/focus_utils.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/auth_screen/components/top_view.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/buttons/text_button_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/inputs/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    unfocusKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(authNotifierProvider.notifier).login(
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TopView(
                    title: AppConstant.loginTitle,
                    subtitle: AppConstant.loginSubtitle,
                  ),
                  BaseEmailField(controller: _email),
                  20.height,
                  BasePasswordField(
                    controller: _password,
                    onSubmitted: (_) => _submit(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButtonWidget(
                      buttonName: AppConstant.forgotPassword,
                      onPressed: () => push(AppRoutes.forgotPassword),
                    ),
                  ),
                  15.height,
                  PrimaryButton(
                    buttonName: AppConstant.loginCta,
                    onPressed: _submit,
                  ),
                  24.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppConstant.noAccount.toText(
                        fontSize: 14,
                        color: AppColors.softGray,
                      ),
                      TextButtonWidget(
                        buttonName: AppConstant.signupCta,
                        fontWeight: AppStyle.w600,
                        onPressed: () => replace(AppRoutes.signup),
                      ),
                    ],
                  ),
                ],
              ),
            ).paddingSymmetric(horizontal: 28.w),
          ),
        ),
      ),
    );
  }
}
