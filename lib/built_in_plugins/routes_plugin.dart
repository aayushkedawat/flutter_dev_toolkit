import 'package:flutter/material.dart';

import 'package:flutter_dev_toolkit/core/share_utils.dart';

import '../../core/dev_toolkit_plugin.dart';
import '../../flutter_dev_toolkit.dart';
import '../../interceptors/route_interceptor.dart';
import 'widgets/routes_tab.dart';

class RoutePlugin extends DevToolkitPlugin {
  @override
  String get name => 'Routes';

  @override
  IconData get icon => Icons.route;

  @override
  void onInit() {
    RouteInterceptor.init();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.share),
        tooltip: 'Export',
        onPressed: () => _export(context),
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        tooltip: 'Clear',
        onPressed: () => _clear(context),
      ),
    ];
  }

  void _export(BuildContext context) {
    final data = _generateText();
    FlutterDevToolkit.logger.log('📤 Exported Route Info:\n$data');
    ExportUtil.exportData(text: data, title: 'Route Info Export');
  }

  void _clear(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Clear Route Info?'),
            content: const Text('This will clear history and stack.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Clear'),
              ),
            ],
          ),
    );

    if (confirm ?? false) {
      RouteInterceptor.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cleared route info')));
        (context as Element).markNeedsBuild();
      }
    }
  }

  String _generateText() {
    final buffer = StringBuffer();

    buffer.writeln('📍 Current Stack:');
    for (final route in RouteInterceptor.routeStack) {
      final entered = RouteInterceptor.entryTimestamps[route];
      final args = RouteInterceptor.routeArguments[route];
      final duration =
          entered != null
              ? DateTime.now().difference(entered).inSeconds
              : 'unknown';
      buffer.writeln('- $route | Duration: ${duration}s | Args: $args');
    }

    buffer.writeln('\n📜 Route History:');
    for (final entry in RouteInterceptor.routeHistory) {
      buffer.writeln('- $entry');
    }

    return buffer.toString();
  }

  @override
  Widget buildTab(BuildContext context) => const RoutePluginView();
}
