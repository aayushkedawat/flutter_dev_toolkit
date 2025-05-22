import 'package:flutter/widgets.dart';
import '../flutter_dev_toolkit.dart';

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
    );
  }

  static void dispose() {
    WidgetsBinding.instance.removeObserver(_instance);
  }
}
