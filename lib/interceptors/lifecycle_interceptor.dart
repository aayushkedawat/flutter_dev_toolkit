import 'package:flutter/widgets.dart';
import '../core/logger_interface.dart';
import '../flutter_dev_toolkit.dart';
import '../models/log_tag.dart';

class LifecycleInterceptor with WidgetsBindingObserver {
  static final LifecycleInterceptor _instance = LifecycleInterceptor._();

  LifecycleInterceptor._();

  static void init() {
    WidgetsBinding.instance.addObserver(_instance);
    FlutterDevToolkit.logger.log('LifecycleInterceptor initialized');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    FlutterDevToolkit.logger.log(
      'App Lifecycle → ${state.name.toUpperCase()}',
      level: LogLevel.info,
      tags: {LogTag.lifecycle},
    );
  }

  static void dispose() {
    WidgetsBinding.instance.removeObserver(_instance);
  }
}
