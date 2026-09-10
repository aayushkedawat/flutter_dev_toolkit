import 'package:flutter_dev_toolkit/models/built_in_plugin_type.dart';

import '../core/dev_toolkit_config.dart';

import '../flutter_dev_toolkit.dart';
import 'network_interceptor.dart';
import 'performance/frame_drop_detector.dart';
import 'route_interceptor.dart';

/// Starts the toolkit's non-network interceptors (routes, lifecycle,
/// performance) that don't require the consumer to wrap a client manually.
///
/// Network interception (`HttpInterceptor`/`DioNetworkInterceptor`) is
/// always opt-in per client and isn't started here — [NetworkInterceptor]
/// just logs that it's available.
class InterceptorRegistry {
  /// Called once by `FlutterDevToolkit.init`, starting each interceptor not
  /// disabled via [config]'s `disableBuiltInPlugins`.
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

    if (!FlutterDevToolkit.config.disableBuiltInPlugins.contains(
      BuiltInPluginType.performance,
    )) {
      FrameDropDetector.init();
    }
  }
}
