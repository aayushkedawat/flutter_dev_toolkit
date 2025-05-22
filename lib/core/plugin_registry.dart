import 'package:flutter_dev_toolkit/flutter_dev_toolkit.dart';
import '../built_in_plugins/device_info_plugin.dart';

import 'dev_toolkit_plugin.dart';

class PluginRegistry {
  static final List<DevToolkitPlugin> _builtInPlugins = [DeviceInfoPlugin()];

  static void registerBuiltIns({List<Type> exclude = const []}) {
    for (final plugin in _builtInPlugins) {
      if (!exclude.contains(plugin.runtimeType)) {
        FlutterDevToolkit.registerPlugin(plugin);
      }
    }
  }
}
