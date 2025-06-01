import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dev_toolkit/built_in_plugins/widgets/log_tile_widget.dart';

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
                  ...stack.reversed.map((route) {
                    final entered = RouteInterceptor.entryTimestamps[route];
                    final duration =
                        entered != null
                            ? DateTime.now().difference(entered).inSeconds
                            : null;
                    final args = RouteInterceptor.routeArguments[route];

                    return Column(
                      children: [
                        LogTileWidget(
                          prefix: Icon(Icons.route),
                          subTitle:
                              'Time: ${duration ?? '?'}s | Args: ${args ?? 'None'}',
                          title: route,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: route));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copied: $route')),
                            );
                          },
                        ),
                        Divider(),
                      ],
                    );
                  }),
                  // const Divider(),
                  const Text(
                    '📜 Route History',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...history.map((entry) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LogTileWidget(
                          suffix: IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: entry));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Copied: $entry')),
                              );
                            },
                            icon: Icon(Icons.copy),
                          ),
                          //     'Time: ${duration ?? '?'}s | Args: ${args ?? 'None'}',
                          title: entry,
                        ),
                        Divider(),
                      ],
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
