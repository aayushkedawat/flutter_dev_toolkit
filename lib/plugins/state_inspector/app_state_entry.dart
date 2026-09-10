/// One recorded state change, shown by the App State Inspector.
class AppStateEntry {
  /// The bloc type, provider name, or other source label this change came
  /// from.
  final String source;

  /// The new state.
  final dynamic value;

  /// The state this source held before [value]. Null when the adapter's
  /// framework cannot report a previous state, or for the first change.
  final dynamic previousState;

  /// When this change was recorded.
  final DateTime timestamp;

  /// Creates a state entry.
  AppStateEntry({
    required this.source,
    required this.value,
    required this.timestamp,
    this.previousState,
  });
}
