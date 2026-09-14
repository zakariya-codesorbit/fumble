import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_initializer.dart';
import 'app.dart';
import 'utils/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppColors.statusBar);

  // Firebase must be ready before auth redirects; await briefly.
  await AppInitializer.initialize();

  runApp(const FlumbleApp());
}
