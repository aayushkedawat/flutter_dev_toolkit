import 'package:flutter/widgets.dart';
import '../core/logger_interface.dart';
import '../flutter_dev_toolkit.dart';

/// Tracks navigation history and the current route stack, feeding the
/// Routes tab. Register [instance] as a `MaterialApp.navigatorObservers`
/// entry.
class RouteInterceptor extends RouteObserver<PageRoute<dynamic>> {
  static final RouteInterceptor _instance = RouteInterceptor._();

  /// Routes currently on the navigator stack, oldest first. Tracked as records
  /// rather than a name→time map so that pushing the same route twice (A → B →
  /// A) keeps two independent entries.
  static final List<_OpenRoute> _openRoutes = [];

  static final List<String> _routeHistory = [];

  /// Route arguments by route name, from the most recent push/replace of
  /// that name.
  static final Map<String, dynamic> routeArguments = {};

  /// Bumped on every navigation event and [clear], so the Routes tab can
  /// rebuild.
  static final ValueNotifier<int> routeVersion = ValueNotifier(0);

  RouteInterceptor._();

  /// The singleton observer instance to pass to
  /// `MaterialApp.navigatorObservers`.
  static RouteObserver<PageRoute<dynamic>> get instance => _instance;

  /// Logs a one-time initialization notice. Called once by
  /// `FlutterDevToolkit.init`.
  static void init() {
    FlutterDevToolkit.logger.log('RouteInterceptor initialized');
  }

  /// Names of routes currently on the navigator stack, oldest first. A name
  /// appears once per time it's on the stack, so A → B → A lists `[A, B, A]`.
  static List<String> get routeStack =>
      List.unmodifiable(_openRoutes.map((r) => r.name));

  /// A running log of push/pop/replace events, newest-appended, capped at
  /// 1000 entries.
  static List<String> get routeHistory => List.unmodifiable(_routeHistory);

  /// Entry time per route name. If the same route is on the stack more than
  /// once, the most recent entry wins.
  static Map<String, DateTime> get entryTimestamps =>
      Map.unmodifiable({for (final r in _openRoutes) r.name: r.enteredAt});

  void _log(String action, Route<dynamic>? route) {
    final name = route?.settings.name ?? 'Unnamed';
    final args = route?.settings.arguments;

    if (args != null) {
      routeArguments[name] = args;
    }

    FlutterDevToolkit.logger.log(
      '$action → $name${args != null ? ' | args: $args' : ''}',
    );
    routeVersion.value++;
    _logHistory(action, name, args);
  }

  static void _logHistory(String action, String routeName, [Object? args]) {
    final time = DateTime.now().toIso8601String();
    final argStr = args != null ? ' | args: $args' : '';
    _routeHistory.add('[$action] $routeName$argStr @ $time');

    if (_routeHistory.length > 1000) {
      _routeHistory.removeAt(0);
    }
  }

  void _trackEntry(PageRoute route) {
    final name = route.settings.name ?? 'Unnamed';
    _openRoutes.add(_OpenRoute(name, DateTime.now()));
  }

  void _trackExit(PageRoute route) {
    final name = route.settings.name ?? 'Unnamed';

    // Pop the most recent entry for this name. Removing the first match would
    // reorder the stack when a route appears on it more than once.
    final index = _openRoutes.lastIndexWhere((r) => r.name == name);
    if (index == -1) return;

    final entry = _openRoutes.removeAt(index);
    final duration = DateTime.now().difference(entry.enteredAt);
    FlutterDevToolkit.logger.log(
      'Exited $name after ${_formatDuration(duration)}',
      level: LogLevel.debug,
    );
  }

  /// Sub-second navigations are common, and reporting them as "0s" hides them.
  static String _formatDuration(Duration duration) =>
      duration.inSeconds >= 1
          ? '${duration.inSeconds}s'
          : '${duration.inMilliseconds}ms';

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

  /// Clears the recorded history. Routes still on the navigator stack are left
  /// alone — they are live state, not history, and dropping them would break
  /// duration tracking for screens the user still has open.
  static void clear() {
    _routeHistory.clear();
    routeArguments.clear();
    routeVersion.value++;
  }
}

class _OpenRoute {
  final String name;
  final DateTime enteredAt;

  _OpenRoute(this.name, this.enteredAt);
}
