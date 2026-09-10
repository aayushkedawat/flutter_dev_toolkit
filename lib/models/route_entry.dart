/// One entry in a navigation history, recorded by `RouteInterceptor`.
class RouteEntry {
  /// The route's name, as passed to `Navigator.pushNamed` or set via
  /// `RouteSettings.name`.
  final String name;

  /// When this route was entered.
  final DateTime entryTime;

  /// How long the route stayed on top of the stack, or `null` while it is
  /// still the current route.
  final Duration? duration;

  /// Creates a route history entry.
  RouteEntry({required this.name, required this.entryTime, this.duration});

  /// Serializes this entry for export from the Routes tab.
  Map<String, dynamic> toJson() => {
    'name': name,
    'entryTime': entryTime.toIso8601String(),
    'duration': duration?.inMilliseconds,
  };
}
