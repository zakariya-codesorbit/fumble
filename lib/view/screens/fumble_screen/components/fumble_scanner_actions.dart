import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/state/providers/app_providers.dart';

abstract final class FumbleScannerActions {
  FumbleScannerActions._();

  static void close() => pop();

  static Future<bool> openSettings(WidgetRef ref) {
    return ref.read(scannerNotifierProvider.notifier).openSettings();
  }

  static Future<void> requestCameraPermission(WidgetRef ref) {
    return ref.read(scannerNotifierProvider.notifier).requestCameraPermission();
  }

  static Future<void> refreshCameraPermission(WidgetRef ref) {
    return ref.read(scannerNotifierProvider.notifier).refreshCameraPermission();
  }

  static Future<void> onDetect({
    required WidgetRef ref,
    required BarcodeCapture capture,
  }) {
    return ref.read(scannerNotifierProvider.notifier).onDetect(capture);
  }
}
