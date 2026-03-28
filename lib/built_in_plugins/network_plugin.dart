import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dev_toolkit/core/share_utils.dart';
import 'package:flutter_dev_toolkit/interceptors/network_interceptor.dart';
import '../../core/dev_toolkit_plugin.dart';
import '../core/network_log_store.dart';
import '../../interceptors/network/network_log.dart';
import 'widgets/network_tab.dart';

class NetworkPlugin extends DevToolkitPlugin {
  @override
  String get name => 'Network';

  @override
  IconData get icon => Icons.network_check;

  @override
  void onInit() {
    NetworkInterceptor.init();
  }

  @override
  Widget buildTab(BuildContext context) => const NetworkTab();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      PopupMenuButton<_ExportFormat>(
        icon: const Icon(Icons.share),
        tooltip: 'Export Network Logs',
        onSelected: (format) {
          final logs = NetworkLogStore.logs.toList();
          if (logs.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No network logs to export')),
            );
            return;
          }
          switch (format) {
            case _ExportFormat.json:
              final text = jsonEncode(logs.map((e) => e.toJson()).toList());
              ExportUtil.exportData(text: text, title: 'Network Logs (JSON)');
            case _ExportFormat.har:
              final text = NetworkLog.toHarDocument(logs);
              ExportUtil.exportData(text: text, title: 'Network Logs (HAR)');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Exported as ${format == _ExportFormat.har ? "HAR" : "JSON"}',
              ),
            ),
          );
        },
        itemBuilder:
            (_) => const [
              PopupMenuItem(
                value: _ExportFormat.json,
                child: Text('Export as JSON'),
              ),
              PopupMenuItem(
                value: _ExportFormat.har,
                child: Text('Export as HAR'),
              ),
            ],
      ),
      IconButton(
        tooltip: 'Clear Network Logs',
        icon: const Icon(Icons.delete),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Clear Network Logs?'),
                  content: const Text(
                    'This will permanently delete all captured requests.',
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
          if (confirmed ?? false) NetworkLogStore.clear();
        },
      ),
    ];
  }
}

enum _ExportFormat { json, har }
