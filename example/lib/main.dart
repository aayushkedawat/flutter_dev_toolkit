import 'package:flutter/material.dart';
import 'package:flutter_dev_toolkit/core/dev_toolkit_config.dart';
import 'package:flutter_dev_toolkit/flutter_dev_toolkit.dart';
import 'package:flutter_dev_toolkit/interceptors/route_interceptor.dart';
import 'package:flutter_dev_toolkit/core/default_logger.dart';

import 'package:flutter_dev_toolkit/ui/log_overlay.dart';

import 'details_page.dart';
import 'example_flags.dart';
import 'home_page.dart';

void main() {
  // Referencing these forces their lazy top-level initializers — which call
  // FeatureFlagStore.register — to run now, so both flags show up in the
  // Flags tab immediately rather than only after something reads one of them.
  debugPrint(
    'Registered example flags: ${showPromoBannerFlag.key}, ${accentColorFlag.key}',
  );

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

  // init() installs its own FlutterError.onError and PlatformDispatcher.onError
  // handlers that feed the Crashes tab. If you install your own afterwards you
  // must chain to the previous handler — replacing it outright silently stops
  // the toolkit from recording crashes.
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    // Your own crash reporting (Crashlytics, Sentry, …) goes here.
    debugPrint('Flutter Error: ${details.exception}');
    previousOnError?.call(details);
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
