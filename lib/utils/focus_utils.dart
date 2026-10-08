import 'package:flutter/widgets.dart';

/// Dismisses the on-screen keyboard / clears text-field focus.
Future<void> unfocusKeyboard() async {
  return FocusManager.instance.primaryFocus?.unfocus();
}
