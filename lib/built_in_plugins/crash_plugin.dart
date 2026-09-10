import 'dart:convert';

import 'package:flutter/material.dart';
import '../core/crash_log_store.dart';
import '../core/dev_toolkit_plugin.dart';
import '../core/share_utils.dart';
import 'widgets/crash_tab.dart';

/// The Crashes tab: captured Flutter and async errors, with export and
/// clear actions. Backed by [CrashLogStore].
class CrashPlugin extends DevToolkitPlugin {
  @override
  String get name => 'Crashes';

  @override
  IconData get icon => Icons.bug_report;

  @override
  void onInit() {}

  @override
  Widget buildTab(BuildContext context) => const CrashTab();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Export Crash Logs',
        icon: const Icon(Icons.share),
        onPressed: () {
          final entries = CrashLogStore.entries;
          if (entries.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No crash logs to export')),
            );
            return;
          }
          final text = const JsonEncoder.withIndent(
            '  ',
          ).convert(entries.map((e) => e.toJson()).toList());
          ExportUtil.exportData(text: text, title: 'Crash Logs');
        },
      ),
      IconButton(
        tooltip: 'Clear Crash Logs',
        icon: const Icon(Icons.delete),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Clear Crash Logs?'),
                  content: const Text(
                    'This will permanently delete all recorded crashes.',
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                    ElevatedButton(
                      child: const Text('Clear'),
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ],
                ),
          );
          if (confirmed ?? false) CrashLogStore.clear();
        },
      ),
    ];
  }
}
