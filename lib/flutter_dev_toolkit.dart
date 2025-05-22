library flutter_dev_toolkit;

export 'core/dev_toolkit_config.dart';
export 'core/logger_interface.dart';
export 'core/default_logger.dart';

import 'package:flutter/widgets.dart';

import 'core/dev_toolkit_config.dart';
import 'core/logger_interface.dart';
import 'interceptors/interceptor_registry.dart';

import 'core/dev_toolkit_plugin.dart';
import 'core/plugin_registry.dart';

class FlutterDevToolkit with WidgetsBindingObserver {
  static late LoggerInterface logger;
  static final List<DevToolkitPlugin> _plugins = [];
  static late DevToolkitConfig config;

  static void init({required DevToolkitConfig config}) {
    FlutterDevToolkit.config = config;
    logger = config.logger;
    logger.log('Initializing FlutterDevToolkit...');
    InterceptorRegistry.register(config);
    WidgetsBinding.instance.addObserver(_self);
    PluginRegistry.registerBuiltIns();
    for (var plugin in _plugins) {
      plugin.onInit();
    }
    logger.log('FlutterDevToolkit initialized');
  }

  static final _self = FlutterDevToolkit._();

  FlutterDevToolkit._();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    for (final plugin in _plugins) {
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

  static void registerPlugin(DevToolkitPlugin plugin) {
    _plugins.add(plugin);
  }

  static List<DevToolkitPlugin> get plugins => List.unmodifiable(_plugins);
}
