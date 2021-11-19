import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'view/login.dart';
import 'styles.dart';

const isDevicePreviewEnabled = false;

Widget renderApp() {
  return MaterialApp(
    title: 'Bunjgames',
    theme: lightTheme,
    darkTheme: darkTheme,
    home: LoginPage(),
  );
}

void main() {
  runApp(
    (!kReleaseMode && isDevicePreviewEnabled) ? DevicePreview(
      enabled: !kReleaseMode && isDevicePreviewEnabled,
      builder: (_) => renderApp(),
    ) : renderApp(),
  );
}
