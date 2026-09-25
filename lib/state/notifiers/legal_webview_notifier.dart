import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:fumble/view/screens/setting_screen/components/legal_webview_actions.dart';

class LegalWebViewState {
  const LegalWebViewState({this.isLoading = true});

  final bool isLoading;
}

class LegalWebViewNotifier
    extends AutoDisposeFamilyNotifier<LegalWebViewState, bool> {
  WebViewController? _controller;
  bool _loadScheduled = false;

  WebViewController get controller => _controller!;

  Future<void> reload() async {
    await _controller?.reload();
  }

  void _ensureController(bool isPrivacy) {
    _controller ??= WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            state = const LegalWebViewState(isLoading: true);
          },
          onPageFinished: (_) {
            state = const LegalWebViewState(isLoading: false);
          },
          onWebResourceError: (_) {
            state = const LegalWebViewState(isLoading: false);
          },
        ),
      );

    if (!_loadScheduled) {
      _loadScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller?.loadRequest(
          LegalWebViewActions.uri(isPrivacy: isPrivacy),
        );
      });
    }
  }

  @override
  LegalWebViewState build(bool isPrivacy) {
    _ensureController(isPrivacy);
    return const LegalWebViewState();
  }
}

final legalWebViewNotifierProvider = NotifierProvider.autoDispose
    .family<LegalWebViewNotifier, LegalWebViewState, bool>(
  LegalWebViewNotifier.new,
);
