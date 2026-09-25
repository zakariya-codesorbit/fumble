import 'dart:typed_data';

import 'package:dicebear_offline/dicebear_offline.dart';
import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';

class DicebearAvatarScreen extends StatefulWidget {
  const DicebearAvatarScreen({super.key});

  @override
  State<DicebearAvatarScreen> createState() => _DicebearAvatarScreenState();
}

class _DicebearAvatarScreenState extends State<DicebearAvatarScreen> {
  Uint8List? _payload;

  void _onAvatarChanged(Uint8List payload) {
    final current = _payload;
    if (current != null &&
        current.length == payload.length &&
        _bytesEqual(current, payload)) {
      return;
    }
    setState(() => _payload = payload);
  }

  bool _bytesEqual(Uint8List a, Uint8List b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _useAvatar() {
    final payload = _payload;
    if (payload == null) return;
    Navigator.pop(context, DicebearCodec.decode(payload));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: AppConstant.dicebearAvatar,
        showBack: true,
        actions: [
          TextButton(
            onPressed: _payload == null ? null : _useAvatar,
            child: const Text(AppConstant.save),
          ),
        ],
      ),
      body: EditorScreen(
        onAvatarChanged: _onAvatarChanged,
      ),
    );
  }
}
