import 'package:flutter/widgets.dart';
import 'package:flutter_dev_toolkit/interceptors/lifecycle_interceptor.dart';

import 'core/dev_toolkit_config.dart';
import 'core/dev_toolkit_plugin.dart';
import 'core/logger_interface.dart';
import 'core/plugin_registry.dart';
import 'interceptors/interceptor_registry.dart';

class FlutterDevToolkit with WidgetsBindingObserver {
  static late LoggerInterface logger;
  static late DevToolkitConfig config;

  // Plugin storage
  static final List<DevToolkitPlugin> _builtInPlugins = [];
  static final List<DevToolkitPlugin> _customPlugins = [];

  static final ValueNotifier<DevToolkitPlugin?> activePluginNotifier =
      ValueNotifier(null);

  static DevToolkitPlugin? get activePlugin => activePluginNotifier.value;

  static void setActivePlugin(DevToolkitPlugin? plugin) {
    activePluginNotifier.value = plugin;
  }

  static void init({required DevToolkitConfig config}) {
    FlutterDevToolkit.config = config;
    logger = config.logger;
    logger.log('[DEBUG] Initializing FlutterDevToolkit...');

    InterceptorRegistry.register(config);
    WidgetsBinding.instance.addObserver(_self);
    LifecycleInterceptor.init();
    PluginRegistry.registerBuiltInPlugins(); // Populates _builtInPlugins

    // Call plugin onInit hooks
    for (var plugin in plugins) {
      plugin.onInit();
    }

    logger.log('[DEBUG] FlutterDevToolkit initialized');
  }

  static void registerPlugin(DevToolkitPlugin plugin) {
    _customPlugins.add(plugin);
  }

  static List<DevToolkitPlugin> get plugins => [
    ..._builtInPlugins,
    ..._customPlugins,
  ];

  static final _self = FlutterDevToolkit._();
  FlutterDevToolkit._();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    for (final plugin in plugins) {
      switch (state) {
        case AppLifecycleState.resumed:
          plugin.onResume();
          break;
        case AppLifecycleState.paused:
          plugin.onPause();
          break;
        default:
          break;
      }
    }
  }

  static void addBuiltInPlugin(DevToolkitPlugin plugin) {
    _builtInPlugins.add(plugin);
  }
}
