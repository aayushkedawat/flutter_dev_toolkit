import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/dev_toolkit_plugin.dart';
import '../core/feature_flag_store.dart';
import '../core/share_utils.dart';
import 'widgets/feature_flags_tab.dart';

class FeatureFlagsPlugin extends DevToolkitPlugin {
  @override
  String get name => 'Flags';

  @override
  IconData get icon => Icons.flag_outlined;

  @override
  void onInit() {}

  @override
  Widget buildTab(BuildContext context) => const FeatureFlagsTab();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Export Flags',
        icon: const Icon(Icons.share),
        onPressed: () {
          final flags = FeatureFlagStore.flags;
          if (flags.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No feature flags to export')),
            );
            return;
          }
          final text = const JsonEncoder.withIndent(
            '  ',
          ).convert({for (final f in flags) f.key: f.value});
          ExportUtil.exportData(text: text, title: 'Feature Flags');
        },
      ),
      IconButton(
        tooltip: 'Reset All to Defaults',
        icon: const Icon(Icons.restart_alt),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Reset All Flags?'),
                  content: const Text(
                    'This will reset every flag to its default value.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
          );
          if (confirmed ?? false) FeatureFlagStore.resetAll();
        },
      ),
    ];
  }
}
