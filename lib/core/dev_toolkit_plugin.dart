import 'package:flutter/material.dart';

/// Base class for a console tab, whether built in or registered by a
/// consumer app via `FlutterDevToolkit.registerPlugin`.
abstract class DevToolkitPlugin {
  /// The tab's label, shown in the tab bar and as the console app bar title
  /// while this plugin is active.
  String get name;

  /// The tab's icon, shown in the tab bar.
  IconData get icon;

  /// Called once when toolkit is initialized
  void onInit();

  /// Called when app resumes from background
  void onResume() {}

  /// Called when app pauses (optional)
  void onPause() {}

  /// Main UI tab
  Widget buildTab(BuildContext context);

  /// An optional settings panel, toggled by the tune icon in the console app
  /// bar while this plugin is active. Return `null` (the default) if the
  /// plugin has nothing to configure.
  Widget? buildConfig(BuildContext context) => null;

  /// Optional actions to show in the console toolbar
  List<Widget> buildActions(BuildContext context) => [];
}
