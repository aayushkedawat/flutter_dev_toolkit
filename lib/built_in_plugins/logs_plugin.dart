import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dev_toolkit/built_in_plugins/widgets/logs_tab.dart';
import 'package:flutter_dev_toolkit/core/share_utils.dart';

import '../../core/dev_toolkit_plugin.dart';
import '../flutter_dev_toolkit.dart';

class LogsPlugin extends DevToolkitPlugin {
  @override
  String get name => 'Logs';

  @override
  IconData get icon => Icons.list;

  @override
  void onInit() {}

  @override
  Widget buildTab(BuildContext context) => const LogsTab();
  @override
  List<Widget> buildActions(BuildContext context) {
    if (FlutterDevToolkit.logger.logEntries.isEmpty) return [];

    return [
      IconButton(
        tooltip: 'Export Logs',
        icon: const Icon(Icons.share),
        onPressed: () {
          final logs = FlutterDevToolkit.logger.logEntries;
          final exportText = const JsonEncoder.withIndent('  ').convert(
            logs
                .map(
                  (e) => {
                    'message': e.message,
                    'level': e.level.name,
                    'timestamp': e.timestamp.toIso8601String(),
                  },
                )
                .toList(),
          );
          ExportUtil.exportData(
            text: exportText,
            title: 'DevToolkit Logs Export',
          );
        },
      ),
      IconButton(
        tooltip: 'Clear Logs',
        icon: const Icon(Icons.delete),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Clear Logs?'),
                  content: const Text(
                    'This will permanently delete all log entries.',
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                      child: const Text('Clear'),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
          );

          if (confirmed ?? false) {
            FlutterDevToolkit.logger.clear();
            FlutterDevToolkit.logger.log('✅ Logs cleared');
            (context as Element).markNeedsBuild();
          }
        },
      ),
    ];
  }
}
