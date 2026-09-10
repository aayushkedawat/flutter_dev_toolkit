import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dev_toolkit/interceptors/lifecycle_interceptor.dart';

import 'core/crash_log_store.dart';
import 'core/dev_console_theme.dart';
import 'core/default_logger.dart';
import 'core/dev_toolkit_config.dart';
import 'core/dev_toolkit_plugin.dart';
import 'core/logger_interface.dart';
import 'core/network_log_store.dart';
import 'core/plugin_registry.dart';
import 'interceptors/interceptor_registry.dart';
import 'interceptors/performance/cold_start_timer.dart';
import 'models/crash_entry.dart';
import 'models/log_entry.dart';
import 'models/log_tag.dart';

/// The toolkit's entry point and singleton facade: `init()` wires up every
/// interceptor and built-in plugin, and static members here are how the rest
/// of the toolkit (and a consumer app) reach the active logger, config, and
/// plugin list.
class FlutterDevToolkit with WidgetsBindingObserver {
  /// Where `FlutterDevToolkit.logger.log(...)` calls go. Set by [init] from
  /// `DevToolkitConfig.logger` — a no-op logger if the toolkit is disabled in
  /// release mode.
  static late LoggerInterface logger;

  /// The config passed to [init].
  static late DevToolkitConfig config;

  /// False when the toolkit was skipped due to [DevToolkitConfig.enableInRelease]
  /// being false in a release build. `DevOverlay` checks this before rendering.
  static bool _enabled = true;

  /// Whether the toolkit is active. False only when skipped in a release
  /// build per [DevToolkitConfig.enableInRelease].
  static bool get isEnabled => _enabled;

  // Plugin storage
  static final List<DevToolkitPlugin> _builtInPlugins = [];
  static final List<DevToolkitPlugin> _customPlugins = [];

  /// The plugin whose tab is currently selected in the console, or `null`
  /// when the console is closed or on a non-plugin tab.
  static final ValueNotifier<DevToolkitPlugin?> activePluginNotifier =
      ValueNotifier(null);

  /// Shorthand for `activePluginNotifier.value`.
  static DevToolkitPlugin? get activePlugin => activePluginNotifier.value;

  /// Sets [activePlugin], notifying [activePluginNotifier]'s listeners.
  static void setActivePlugin(DevToolkitPlugin? plugin) {
    activePluginNotifier.value = plugin;
  }

  /// Initializes the toolkit: installs the logger, crash hooks, and
  /// interceptors, then registers every built-in plugin not disabled via
  /// [config]. Call this once, before `runApp()`.
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

    // init() is normally called before runApp(), so the binding may not exist
    // yet. Everything below touches WidgetsBinding.instance, which throws
    // until this runs. It is idempotent.
    WidgetsFlutterBinding.ensureInitialized();
    ColdStartTimer.start();

    _enabled = true;
    logger = config.logger;

    // Apply store limits from config
    final activeLogger = logger;
    if (activeLogger is DefaultLogger) {
      activeLogger.configure(maxEntries: config.maxLogEntries);
    }
    NetworkLogStore.configure(maxLogs: config.maxNetworkLogs);
    DevConsoleThemeController.theme.value = config.theme;

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

  /// Registers a custom, consumer-defined plugin. Call this after [init],
  /// since built-in plugins are registered there.
  static void registerPlugin(DevToolkitPlugin plugin) {
    _customPlugins.add(plugin);
  }

  /// Every registered plugin, built-in ones first, in the order the console
  /// renders their tabs.
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

  /// Registers a built-in plugin. Called by `PluginRegistry` during [init];
  /// not meant to be called directly by a consumer app — use [registerPlugin]
  /// for that.
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
