import 'package:flutter/material.dart';

abstract class DevToolkitPlugin {
  String get name;
  IconData get icon;

  /// Called once when toolkit is initialized
  void onInit();

  /// Called when app resumes from background
  void onResume() {}

  /// Called when app pauses (optional)
  void onPause() {}

  /// Main UI tab
  Widget buildTab(BuildContext context);

  Widget? buildConfig(BuildContext context) => null;
}
