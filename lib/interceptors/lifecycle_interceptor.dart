import 'package:flutter/widgets.dart';
import '../core/logger_interface.dart';
import '../flutter_dev_toolkit.dart';
import '../models/log_tag.dart';

/// Logs `AppLifecycleState` transitions (resumed, paused, …) to the Logs
/// tab, tagged [LogTag.lifecycle].
class LifecycleInterceptor with WidgetsBindingObserver {
  static final LifecycleInterceptor _instance = LifecycleInterceptor._();

  LifecycleInterceptor._();

  /// Starts observing lifecycle changes. Called once by
  /// `FlutterDevToolkit.init`.
  static void init() {
    WidgetsBinding.instance.addObserver(_instance);
    FlutterDevToolkit.logger.log('LifecycleInterceptor initialized');
  }

  /// Logs the new lifecycle state.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    FlutterDevToolkit.logger.log(
      'App Lifecycle → ${state.name.toUpperCase()}',
      level: LogLevel.info,
      tags: {LogTag.lifecycle},
    );
  }

  /// Stops observing lifecycle changes.
  static void dispose() {
    WidgetsBinding.instance.removeObserver(_instance);
  }
}
