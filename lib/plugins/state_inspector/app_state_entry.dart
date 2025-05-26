class AppStateEntry {
  final String source; // bloc type or provider name
  final dynamic value;
  final DateTime timestamp;

  AppStateEntry({
    required this.source,
    required this.value,
    required this.timestamp,
  });
}
