import 'package:flutter/material.dart';
import '../core/dev_console_theme.dart';

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

    return ValueListenableBuilder<DevConsoleTheme>(
      valueListenable: DevConsoleThemeController.theme,
      builder:
          (context, consoleTheme, _) => MaterialApp(
            color: palette.background,
            theme: consoleTheme.themeData,
            home: _buildHome(plugins, tabs, views, consoleTheme),
          ),
    );
  }

  Widget _buildHome(
    List<DevToolkitPlugin> plugins,
    List<Tab> tabs,
    List<Widget> views,
    DevConsoleTheme consoleTheme,
  ) {
    return DefaultTabController(
      length: plugins.length,
      child: DevToolkitTabControllerSync(
        baseTabCount: 0,
        child: Builder(
          builder: (context) {
            return ValueListenableBuilder<DevToolkitPlugin?>(
              valueListenable: FlutterDevToolkit.activePluginNotifier,
              builder: (_, plugin, _) {
                return Scaffold(
                  backgroundColor: palette.background,
                  appBar: AppBar(
                    title: Text(plugin?.name ?? 'Dev Toolkit'),
                    backgroundColor: palette.appBar,
                    actions: [
                      ...?plugin?.buildActions(context),
                      IconButton(
                        tooltip:
                            consoleTheme == DevConsoleTheme.dark
                                ? 'Switch to light theme'
                                : 'Switch to dark theme',
                        icon: Icon(
                          consoleTheme == DevConsoleTheme.dark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                        ),
                        onPressed: DevConsoleThemeController.toggle,
                      ),
                    ],
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
                              icon: Icon(Icons.tune, color: palette.onSurface),
                              onPressed: () {
                                setState(() => _showConfig = !_showConfig);
                              },
                            ),
                          ],
                        ),
                      if (_showConfig && plugin != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: palette.scrim,
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
    );
  }
}
