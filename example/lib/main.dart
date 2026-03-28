import 'package:flutter/material.dart';
import 'package:flutter_dev_toolkit/core/default_logger.dart';
import 'package:flutter_dev_toolkit/core/dev_toolkit_config.dart';
import 'package:flutter_dev_toolkit/flutter_dev_toolkit.dart';
import 'package:flutter_dev_toolkit/interceptors/route_interceptor.dart';
import 'package:flutter_dev_toolkit/ui/log_overlay.dart';

import 'details_page.dart';
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterDevToolkit.init(
    config: DevToolkitConfig(
      logger: DefaultLogger(),

      // Overlay is hidden in release builds by default.
      // Set to true only for internal/beta releases.
      enableInRelease: false,

      // Optional: tune in-memory retention limits.
      maxLogEntries: 2000,
      maxNetworkLogs: 500,

      // Comment out any panel you don't need:
      disableBuiltInPlugins: const [
        // BuiltInPluginType.logs,
        // BuiltInPluginType.network,
        // BuiltInPluginType.routes,
        // BuiltInPluginType.deviceInfo,
        // BuiltInPluginType.crashes,
        // BuiltInPluginType.performance,
        // BuiltInPluginType.deepLinks,
      ],
    ),
  );

  // FlutterError.onError and PlatformDispatcher.onError are wired
  // automatically by the toolkit — no manual setup needed.

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
          // Floating overlay — drag to reposition, red badge shows error count.
          const DevOverlay(),
        ],
      ),
    );
  }
}
