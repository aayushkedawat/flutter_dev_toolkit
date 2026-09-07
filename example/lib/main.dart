import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dev_toolkit/core/dev_toolkit_config.dart';
import 'package:flutter_dev_toolkit/flutter_dev_toolkit.dart';
import 'package:flutter_dev_toolkit/interceptors/route_interceptor.dart';
import 'package:flutter_dev_toolkit/core/default_logger.dart';
import 'package:flutter_dev_toolkit/plugins/adapters/bloc_adapter.dart';
import 'package:flutter_dev_toolkit/plugins/state_inspector/app_state_inspector_plugin.dart';
import 'package:flutter_dev_toolkit/plugins/state_inspector/bloc_state_tracker.dart';

import 'package:flutter_dev_toolkit/ui/log_overlay.dart';

import 'details_page.dart';
import 'example_flags.dart';
import 'home_page.dart';

void main() {
  // Referencing these forces their lazy top-level initializers — which call
  // FeatureFlagStore.register — to run now, so all four flags show up in the
  // Flags tab immediately rather than only after something reads one of them.
  debugPrint(
    'Registered example flags: ${showPromoBannerFlag.key}, '
    '${accentColorFlag.key}, ${welcomeMessageFlag.key}, '
    '${apiTimeoutSecondsFlag.key}',
  );

  // Must be set before any Bloc/Cubit is created, so it catches every state
  // change — including counterCubit's, constructed as a top-level final in
  // counter_cubit.dart the moment that file is first touched.
  Bloc.observer = DevBlocObserver();

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

  // App State is a custom plugin, not a built-in one, so it has to be
  // registered explicitly — it won't appear just because init() ran.
  FlutterDevToolkit.registerPlugin(AppStateInspectorPlugin([BlocAdapter()]));

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
