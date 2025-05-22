import 'package:flutter/widgets.dart';
import '../flutter_dev_toolkit.dart';

class RouteInterceptor extends RouteObserver<PageRoute<dynamic>> {
  static final RouteInterceptor _instance = RouteInterceptor._();
  static final Map<String, DateTime> _entryTimestamps = {};
  static final List<String> _routeStack = [];

  RouteInterceptor._();

  static RouteObserver<PageRoute<dynamic>> get instance => _instance;

  static void init() {
    FlutterDevToolkit.logger.log('RouteInterceptor initialized');
  }

  static final List<String> _routeHistory = [];

  void _logHistory(String action, String routeName) {
    _routeHistory.add(
      '[$action] $routeName @ ${DateTime.now().toIso8601String()}',
    );
    if (_routeHistory.length > 1000) _routeHistory.removeAt(0);
  }

  void _log(String action, Route<dynamic>? route) {
    if (!FlutterDevToolkit.config.enableRouteInterceptor) return;
    final name = route?.settings.name ?? 'Unnamed';
    final args = route?.settings.arguments;
    final argsStr = args != null ? ' | args: ${args.toString()}' : '';

    FlutterDevToolkit.logger.log('$action → $name$argsStr');
    _logHistory(action, name);
  }

  static List<String> get routeHistory => List.unmodifiable(_routeHistory);

  void _trackEntry(PageRoute route) {
    final name = route.settings.name ?? 'Unnamed';
    _entryTimestamps[name] = DateTime.now();
    _routeStack.add(name);
  }

  void _trackExit(PageRoute route) {
    final name = route.settings.name ?? 'Unnamed';
    final entryTime = _entryTimestamps.remove(name);
    _routeStack.remove(name);

    if (entryTime != null) {
      final duration = DateTime.now().difference(entryTime);
      FlutterDevToolkit.logger.log(
        'Exited $name after ${duration.inSeconds}s',
        level: LogLevel.info,
      );
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PageRoute) {
      _trackEntry(route);
      _log('PUSHED', route);
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (route is PageRoute) {
      _trackExit(route);
      _log('POPPED', route);
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute is PageRoute) {
      _trackExit(oldRoute);
      _log('REPLACED (old)', oldRoute);
    }
    if (newRoute is PageRoute) {
      _trackEntry(newRoute);
      _log('REPLACED (new)', newRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  /// Exposes current route stack
  static List<String> get currentStack => List.unmodifiable(_routeStack);
  static Map<String, DateTime> get entryTimestamps =>
      Map.unmodifiable(_entryTimestamps);
}
