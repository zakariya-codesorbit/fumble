import 'package:flutter/widgets.dart';

/// Dismisses the on-screen keyboard / clears text-field focus.
void unfocusKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}
