import 'package:flutter_dev_toolkit/models/built_in_plugin_type.dart';

import '../core/dev_toolkit_config.dart';

import '../flutter_dev_toolkit.dart';
import 'network_interceptor.dart';
import 'route_interceptor.dart';

class InterceptorRegistry {
  static void register(DevToolkitConfig config) {
    if (!FlutterDevToolkit.config.disableBuiltInPlugins.contains(
      BuiltInPluginType.routes,
    )) {
      RouteInterceptor.init();
    }

    if (!FlutterDevToolkit.config.disableBuiltInPlugins.contains(
      BuiltInPluginType.network,
    )) {
      NetworkInterceptor.init();
    }
  }
}
