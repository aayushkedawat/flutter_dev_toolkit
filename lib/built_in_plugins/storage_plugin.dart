import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/dev_toolkit_plugin.dart';
import '../core/share_utils.dart';
import '../core/storage_inspector_store.dart';
import 'widgets/storage_tab.dart';

/// The Storage tab: view, add, edit, and delete `SharedPreferences` entries,
/// with export and clear-all actions. Backed by [StorageInspectorStore].
class StoragePlugin extends DevToolkitPlugin {
  @override
  String get name => 'Storage';

  @override
  IconData get icon => Icons.storage_outlined;

  @override
  void onInit() {}

  @override
  Widget buildTab(BuildContext context) => const StorageTab();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Export All Entries',
        icon: const Icon(Icons.share),
        onPressed: () {
          final entries = StorageInspectorStore.entries;
          if (entries.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No storage entries to export')),
            );
            return;
          }
          final text = const JsonEncoder.withIndent(
            '  ',
          ).convert({for (final e in entries) e.key: e.value});
          ExportUtil.exportData(text: text, title: 'SharedPreferences');
        },
      ),
      IconButton(
        tooltip: 'Clear All Entries',
        icon: const Icon(Icons.delete),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Clear All Entries?'),
                  content: const Text(
                    'This will permanently delete every SharedPreferences entry.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
          );
          if (confirmed ?? false) await StorageInspectorStore.clearAll();
        },
      ),
    ];
  }
}
