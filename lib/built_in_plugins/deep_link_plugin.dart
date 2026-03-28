import 'dart:convert';

import 'package:flutter/material.dart';
import '../core/deep_link_store.dart';
import '../core/dev_toolkit_plugin.dart';
import '../core/share_utils.dart';
import 'widgets/deep_link_tab.dart';

class DeepLinkPlugin extends DevToolkitPlugin {
  @override
  String get name => 'Deep Links';

  @override
  IconData get icon => Icons.link;

  @override
  void onInit() {}

  @override
  Widget buildTab(BuildContext context) => const DeepLinkTab();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Export Deep Link History',
        icon: const Icon(Icons.share),
        onPressed: () {
          final entries = DeepLinkStore.entries;
          if (entries.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No deep links to export')),
            );
            return;
          }
          final text = const JsonEncoder.withIndent('  ')
              .convert(entries.map((e) => e.toJson()).toList());
          ExportUtil.exportData(text: text, title: 'Deep Link History');
        },
      ),
      IconButton(
        tooltip: 'Clear Deep Link History',
        icon: const Icon(Icons.delete),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Clear Deep Link History?'),
                  content: const Text(
                    'This will permanently delete all recorded deep links.',
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
          if (confirmed ?? false) DeepLinkStore.clear();
        },
      ),
    ];
  }
}
