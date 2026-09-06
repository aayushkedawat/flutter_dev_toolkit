class AppStateEntry {
  final String source; // bloc type or provider name
  final dynamic value;

  /// The state this source held before [value]. Null when the adapter's
  /// framework cannot report a previous state, or for the first change.
  final dynamic previousState;

  final DateTime timestamp;

  AppStateEntry({
    required this.source,
    required this.value,
    required this.timestamp,
    this.previousState,
  });
}
