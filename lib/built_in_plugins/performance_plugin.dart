import 'package:flutter/material.dart';
import '../core/dev_toolkit_plugin.dart';
import 'widgets/performance_tab.dart';

/// The Performance tab: live FPS, resident memory, jank frame counters, and
/// their rolling history sparklines.
class PerformancePlugin extends DevToolkitPlugin {
  @override
  String get name => 'Performance';

  @override
  IconData get icon => Icons.speed;

  @override
  void onInit() {}

  @override
  Widget buildTab(BuildContext context) => const PerformanceTab();
}
