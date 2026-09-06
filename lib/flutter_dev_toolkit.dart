import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dev_toolkit/interceptors/lifecycle_interceptor.dart';

import 'core/crash_log_store.dart';
import 'core/default_logger.dart';
import 'core/dev_toolkit_config.dart';
import 'core/dev_toolkit_plugin.dart';
import 'core/logger_interface.dart';
import 'core/network_log_store.dart';
import 'core/plugin_registry.dart';
import 'interceptors/interceptor_registry.dart';
import 'models/crash_entry.dart';
import 'models/log_entry.dart';
import 'models/log_tag.dart';

class FlutterDevToolkit with WidgetsBindingObserver {
  static late LoggerInterface logger;
  static late DevToolkitConfig config;

  /// False when the toolkit was skipped due to [DevToolkitConfig.enableInRelease]
  /// being false in a release build. [DevOverlay] checks this before rendering.
  static bool _enabled = true;
  static bool get isEnabled => _enabled;

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

    // Suppress the toolkit in release builds unless the consumer explicitly
    // opts in via enableInRelease. A no-op logger is installed so that any
    // FlutterDevToolkit.logger calls don't throw in production.
    if (kReleaseMode && !config.enableInRelease) {
      _enabled = false;
      logger = _NoOpLogger();
      return;
    }

    _enabled = true;
    logger = config.logger;

    // Apply store limits from config
    final activeLogger = logger;
    if (activeLogger is DefaultLogger) {
      activeLogger.configure(maxEntries: config.maxLogEntries);
    }
    NetworkLogStore.configure(maxLogs: config.maxNetworkLogs);

    logger.log('[DEBUG] Initializing FlutterDevToolkit...');

    // Install crash/error hooks
    _installCrashHandlers();

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

  static void _installCrashHandlers() {
    // Flutter framework errors (widget build errors, assertion failures, etc.)
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      CrashLogStore.add(
        CrashEntry(
          message: details.exceptionAsString(),
          stackTrace: details.stack?.toString() ?? '(no stack trace)',
          isFatal: false,
        ),
      );
      if (logger is DefaultLogger) {
        (logger as DefaultLogger).log(
          '[CRASH] ${details.exceptionAsString()}',
          level: LogLevel.error,
        );
      }
      originalOnError?.call(details);
    };

    // Unhandled async errors (would otherwise terminate the isolate)
    PlatformDispatcher.instance.onError = (error, stack) {
      CrashLogStore.add(
        CrashEntry(
          message: error.toString(),
          stackTrace: stack.toString(),
          isFatal: true,
        ),
      );
      if (logger is DefaultLogger) {
        (logger as DefaultLogger).log('[FATAL] $error', level: LogLevel.error);
      }
      return false; // let the error propagate normally
    };
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

/// Silent logger used when the toolkit is disabled in release mode.
class _NoOpLogger implements LoggerInterface {
  @override
  void log(
    String message, {
    LogLevel level = LogLevel.debug,
    Set<LogTag> tags = const {},
  }) {}

  @override
  List<LogEntry> get logEntries => const [];

  @override
  void clear() {}
}
