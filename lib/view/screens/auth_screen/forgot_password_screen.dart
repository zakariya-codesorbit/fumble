import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/focus_utils.dart';
import 'package:fumble/view/screens/auth_screen/components/top_view.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/inputs/custom_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    unfocusKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(authNotifierProvider.notifier).sendPasswordReset(
          email: _email.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TopView(
                  title: AppConstant.resetPasswordTitle,
                  subtitle: AppConstant.resetPasswordSubtitle,
                  showBack: true,
                ),
                BaseEmailField(
                  controller: _email,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                28.height,
                PrimaryButton(
                  buttonName: AppConstant.sendResetLink,
                  onPressed: _submit,
                ),
              ],
            ).paddingSymmetric(horizontal: 28.w),
          ),
        ),
      ),
    );
  }
}
