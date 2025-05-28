class RouteEntry {
  final String name;
  final DateTime entryTime;
  final Duration? duration;

  RouteEntry({required this.name, required this.entryTime, this.duration});

  Map<String, dynamic> toJson() => {
    'name': name,
    'entryTime': entryTime.toIso8601String(),
    'duration': duration?.inMilliseconds,
  };
}
