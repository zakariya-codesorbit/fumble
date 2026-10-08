import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Dismisses the on-screen keyboard and detaches the platform IME.
///
/// [FocusNode.unfocus] alone is not enough before route teardown — the
/// platform keyboard connection can linger and briefly reappear on the next
/// screen. This also force-hides the IME and waits a beat so hide can settle.
Future<void> unfocusKeyboard({bool saveAutofill = false}) async {
  FocusManager.instance.primaryFocus?.unfocus();
  try {
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  } catch (_) {
    // Channel may be unavailable in tests / early startup.
  }
  TextInput.finishAutofillContext(shouldSave: saveAutofill);
  await WidgetsBinding.instance.endOfFrame;
  await Future<void>.delayed(const Duration(milliseconds: 50));
}
