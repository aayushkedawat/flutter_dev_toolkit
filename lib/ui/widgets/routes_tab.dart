import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../flutter_dev_toolkit.dart';
import '../../interceptors/route_interceptor.dart';

class RoutesTab extends StatefulWidget {
  const RoutesTab({super.key});

  @override
  State<RoutesTab> createState() => _RoutesTabState();
}

class _RoutesTabState extends State<RoutesTab> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final stack =
        RouteInterceptor.currentStack
            .where(
              (route) => route.toLowerCase().contains(_filter.toLowerCase()),
            )
            .toList();

    final history =
        RouteInterceptor.routeHistory.reversed
            .where(
              (entry) => entry.toLowerCase().contains(_filter.toLowerCase()),
            )
            .toList();

    final timestamps = RouteInterceptor.entryTimestamps;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Filter by route name...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) => setState(() => _filter = value),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Text(
                '📍 Current Stack',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ...stack.map((route) {
                final entered = timestamps[route];
                final duration =
                    entered != null ? DateTime.now().difference(entered) : null;
                return GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: route));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Copied: $route')));
                  },
                  child: ListTile(
                    title: Text(route),
                    subtitle: Text(
                      duration != null
                          ? 'Time active: ${duration.inSeconds}s'
                          : 'Unknown',
                    ),
                  ),
                );
              }),
              const Divider(),
              const Text(
                '📜 Route History',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ...history.map((line) {
                return GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: line));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied history entry')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      line,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Export'),
              onPressed: _exportRouteHistory,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ],
    );
  }

  void _exportRouteHistory() {
    final data = RouteInterceptor.routeHistory.join('\n');
    FlutterDevToolkit.logger.log('📤 Exported Route History:\n$data');
    ShareParams shareParams = ShareParams(
      text: data,
      subject: 'Route Timeline',
    );
    SharePlus.instance.share(shareParams);
  }
}
