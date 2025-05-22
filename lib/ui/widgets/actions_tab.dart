import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/network_log_store.dart';
import '../../flutter_dev_toolkit.dart';
import '../../interceptors/route_interceptor.dart';

class ActionsTab extends StatefulWidget {
  const ActionsTab({super.key});

  @override
  State<ActionsTab> createState() => _ActionsTabState();
}

class _ActionsTabState extends State<ActionsTab> {
  bool routeEnabled = true;
  bool networkEnabled = true;
  bool lifecycleEnabled = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text(
          '🔧 Dev Toolkit Actions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),

        ElevatedButton.icon(
          icon: const Icon(Icons.clear_all),
          label: const Text('Clear All Logs'),
          onPressed: () {
            if (FlutterDevToolkit.logger is DefaultLogger) {
              (FlutterDevToolkit.logger as DefaultLogger).clear();
            }
            NetworkLogStore.clear();

            FlutterDevToolkit.logger.log('🧹 Cleared all logs.');
          },
        ),

        ElevatedButton.icon(
          icon: const Icon(Icons.file_upload),
          label: const Text('Export All Logs'),
          onPressed: _exportAll,
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  void _exportAll() {
    final logs = <String>[];

    for (var entry in FlutterDevToolkit.logger.logEntries) {
      logs.add('[${entry.timestamp}] [${entry.level.name}] ${entry.message}');
    }
    if (FlutterDevToolkit.config.enableNetworkInterceptor) {
      for (var net in NetworkLogStore.logs) {
        logs.add(
          '[NETWORK] ${net.method} ${net.url} → ${net.statusCode} in ${net.duration.inMilliseconds}ms',
        );
      }
    }
    if (FlutterDevToolkit.config.enableRouteInterceptor) {
      for (var route in RouteInterceptor.routeHistory) {
        logs.add('[ROUTE] $route');
      }
    }
    final combined = logs.join('\n');
    ShareParams shareParams = ShareParams(
      text: combined,
      subject: 'Dev Toolkit Export',
    );
    SharePlus.instance.share(shareParams);
  }
}
