import '../core/dev_toolkit_config.dart';
import '../flutter_dev_toolkit.dart';

import 'network_interceptor.dart';
import 'route_interceptor.dart';
import 'lifecycle_interceptor.dart';

class InterceptorRegistry {
  static void register(DevToolkitConfig config) {
    if (config.enableRouteInterceptor) {
      RouteInterceptor.init();
    }

    if (config.enableLifecycleInterceptor) {
      LifecycleInterceptor.init();
    }
    if (config.enableNetworkInterceptor) {
      NetworkInterceptor.init();
    }
  }
}
