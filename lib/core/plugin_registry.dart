import 'package:flutter_dev_toolkit/built_in_plugins/routes_plugin.dart';
import 'package:flutter_dev_toolkit/flutter_dev_toolkit.dart';
import '../built_in_plugins/device_info_plugin.dart';
import '../built_in_plugins/logs_plugin.dart';
import '../built_in_plugins/network_plugin.dart';

import '../models/built_in_plugin_type.dart';
import 'dev_toolkit_plugin.dart';

class PluginRegistry {
  static void registerBuiltInPlugins() {
    final disabled = FlutterDevToolkit.config.disableBuiltInPlugins;

    void tryAdd(BuiltInPluginType type, DevToolkitPlugin plugin) {
      if (!disabled.contains(type)) {
        FlutterDevToolkit.addBuiltInPlugin(plugin);
      }
    }

    tryAdd(BuiltInPluginType.logs, LogsPlugin());
    tryAdd(BuiltInPluginType.network, NetworkPlugin());
    tryAdd(BuiltInPluginType.routes, RoutePlugin());
    // tryAdd(BuiltInPluginType.actions, ActionsPlugin());
    tryAdd(BuiltInPluginType.deviceInfo, UserDeviceInfoPlugin());
  }
}
