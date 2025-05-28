import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../interceptors/route_interceptor.dart';

class RoutePluginView extends StatefulWidget {
  const RoutePluginView({super.key});

  @override
  State<RoutePluginView> createState() => _RoutePluginViewState();
}

class _RoutePluginViewState extends State<RoutePluginView> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: RouteInterceptor.routeVersion,

      builder: (context, value, child) {
        final stack =
            RouteInterceptor.routeStack
                .where((r) => r.toLowerCase().contains(_filter.toLowerCase()))
                .toList();

        final history =
            RouteInterceptor.routeHistory
                .where((r) => r.toLowerCase().contains(_filter.toLowerCase()))
                .toList()
                .reversed
                .toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                style: TextStyle(color: Colors.black),
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
                  const SizedBox(height: 6),
                  ...stack.map((route) {
                    final entered = RouteInterceptor.entryTimestamps[route];
                    final duration =
                        entered != null
                            ? DateTime.now().difference(entered).inSeconds
                            : null;
                    final args = RouteInterceptor.routeArguments[route];

                    return ListTile(
                      title: Text(route),
                      subtitle: Text(
                        'Time: ${duration ?? '?'}s | Args: ${args ?? 'None'}',
                      ),
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: route));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied: $route')),
                        );
                      },
                    );
                  }),
                  const Divider(),
                  const Text(
                    '📜 Route History',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  ...history.map((entry) {
                    return GestureDetector(
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: entry));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied route history entry'),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          entry,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
