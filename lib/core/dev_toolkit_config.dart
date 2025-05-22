import 'logger_interface.dart';

class DevToolkitConfig {
  final LoggerInterface logger;
  final bool enableNetworkInterceptor;
  final bool enableRouteInterceptor;
  final bool enableLifecycleInterceptor;

  final List<Type> disableBuiltInPlugins;

  DevToolkitConfig({
    required this.logger,
    this.enableNetworkInterceptor = false,
    this.enableRouteInterceptor = false,
    this.enableLifecycleInterceptor = false,

    required this.disableBuiltInPlugins,
  });
}
