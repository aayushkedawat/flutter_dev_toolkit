import 'package:flutter/material.dart';

import '../flutter_dev_toolkit.dart';
import '../core/dev_toolkit_plugin.dart';
import 'dev_toolkit_tab_sync.dart';

class DevConsole extends StatefulWidget {
  const DevConsole({super.key});

  @override
  State<DevConsole> createState() => _DevConsoleState();
}

class _DevConsoleState extends State<DevConsole> {
  bool _showConfig = false;

  @override
  Widget build(BuildContext context) {
    final plugins = FlutterDevToolkit.plugins;
    final tabs =
        plugins.map((p) => Tab(icon: Icon(p.icon), text: p.name)).toList();
    final views = plugins.map((p) => p.buildTab(context)).toList();

    return MaterialApp(
      color: Colors.black,
      theme: ThemeData.dark(),
      home: DefaultTabController(
        length: plugins.length,
        child: DevToolkitTabControllerSync(
          baseTabCount: 0,
          child: Builder(
            builder: (context) {
              return ValueListenableBuilder<DevToolkitPlugin?>(
                valueListenable: FlutterDevToolkit.activePluginNotifier,
                builder: (_, plugin, __) {
                  return Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(
                      title: Text(plugin?.name ?? 'Dev Toolkit'),
                      backgroundColor: Colors.black87,
                      actions: plugin?.buildActions(context),
                      centerTitle: false,
                      bottom: TabBar(isScrollable: true, tabs: tabs),
                    ),
                    body: Column(
                      children: [
                        if (plugin?.buildConfig(context) != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() => _showConfig = !_showConfig);
                                },
                              ),
                            ],
                          ),
                        if (_showConfig && plugin != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black45,
                            child: plugin.buildConfig(context),
                          ),
                        const Divider(height: 1),
                        Expanded(child: TabBarView(children: views)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
