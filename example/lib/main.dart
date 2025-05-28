import 'package:flutter/material.dart';
import 'package:flutter_dev_toolkit/core/dev_toolkit_config.dart';
import 'package:flutter_dev_toolkit/core/logger_interface.dart';
import 'package:flutter_dev_toolkit/flutter_dev_toolkit.dart';
import 'package:flutter_dev_toolkit/interceptors/route_interceptor.dart';
import 'package:flutter_dev_toolkit/core/default_logger.dart';

import 'package:flutter_dev_toolkit/ui/log_overlay.dart';

import 'details_page.dart';
import 'home_page.dart';

void main() {
  FlutterDevToolkit.init(
    config: DevToolkitConfig(
      disableBuiltInPlugins: [
        // BuiltInPluginType.logs,
        // BuiltInPluginType.network,
        // BuiltInPluginType.routes,
        // BuiltInPluginType.deviceInfo,
      ],
      logger: DefaultLogger(),
    ),
  );

  FlutterError.onError = (details) {
    FlutterDevToolkit.logger
        .log('Flutter Error: ${details.exception}', level: LogLevel.error);
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dev Toolkit Example',
      navigatorObservers: [RouteInterceptor.instance],
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/details': (context) => const DetailsPage(),
      },
      builder: (context, child) => Stack(
        children: [
          child!,
          const DevOverlay(),
        ],
      ),
    );
  }
}
