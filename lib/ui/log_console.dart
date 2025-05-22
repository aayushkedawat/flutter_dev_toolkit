import 'package:flutter/material.dart';

import '../flutter_dev_toolkit.dart';
import '../core/dev_toolkit_plugin.dart';
import 'widgets/actions_tab.dart';
import 'widgets/logs_tab.dart';
import 'widgets/network_tab.dart';

import 'widgets/routes_tab.dart';

class DevConsole extends StatefulWidget {
  const DevConsole({super.key});

  @override
  State<DevConsole> createState() => _DevConsoleState();
}

class _DevConsoleState extends State<DevConsole> {
  bool _showConfig = false;
  DevToolkitPlugin? _activePlugin;

  @override
  Widget build(BuildContext context) {
    final baseTabs = [
      Tab(icon: Icon(Icons.list), text: 'Logs'),
      if (FlutterDevToolkit.config.enableNetworkInterceptor)
        Tab(icon: Icon(Icons.network_check), text: 'Network'),
      if (FlutterDevToolkit.config.enableRouteInterceptor)
        Tab(icon: Icon(Icons.map), text: 'Routes'),
      Tab(icon: Icon(Icons.settings), text: 'Actions'),
    ];

    final pluginTabs =
        FlutterDevToolkit.plugins.map((plugin) {
          return Tab(icon: Icon(plugin.icon), text: plugin.name);
        }).toList();

    final allTabs = [...baseTabs, ...pluginTabs];

    final baseViews = [
      LogsTab(),
      if (FlutterDevToolkit.config.enableNetworkInterceptor) NetworkTab(),

      if (FlutterDevToolkit.config.enableRouteInterceptor) RoutesTab(),

      ActionsTab(),
    ];

    final pluginViews =
        FlutterDevToolkit.plugins.map((p) => p.buildTab(context)).toList();
    final allViews = [...baseViews, ...pluginViews];

    return MaterialApp(
      color: Colors.black,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: DefaultTabController(
          length: allTabs.length,
          child: Builder(
            builder: (context) {
              final controller = DefaultTabController.of(context);
              controller.addListener(() {
                final selected = controller.index;
                if (selected >= baseTabs.length) {
                  setState(() {
                    _activePlugin =
                        FlutterDevToolkit.plugins[selected - baseTabs.length];
                    _showConfig = false;
                  });
                } else {
                  setState(() {
                    _activePlugin = null;
                    _showConfig = false;
                  });
                }
              });

              return Column(
                children: [
                  Container(
                    color: Colors.black87,
                    child: TabBar(tabs: allTabs, isScrollable: true),
                  ),
                  if (_activePlugin?.buildConfig(context) != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white),
                          onPressed: () {
                            setState(() => _showConfig = !_showConfig);
                          },
                        ),
                      ],
                    ),
                  if (_showConfig && _activePlugin != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black45,
                      child: _activePlugin!.buildConfig(context),
                    ),
                  const Divider(height: 1),
                  Expanded(child: TabBarView(children: allViews)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
