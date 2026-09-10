/// One captured crash: a Flutter framework error or an unhandled async
/// error, recorded by the Crashes tab's error hooks.
class CrashEntry {
  /// The exception's string representation.
  final String message;

  /// The captured stack trace, as text.
  final String stackTrace;

  /// When the error was captured. Defaults to [DateTime.now] if omitted.
  final DateTime timestamp;

  /// True when the error was caught by `PlatformDispatcher.onError` (i.e. an
  /// unhandled async error that would normally terminate the isolate).
  final bool isFatal;

  /// Creates a crash entry. [timestamp] defaults to now if not supplied.
  CrashEntry({
    required this.message,
    required this.stackTrace,
    this.isFatal = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Serializes this entry for export (e.g. copy-as-JSON in the Crashes tab).
  Map<String, dynamic> toJson() => {
    'message': message,
    'stackTrace': stackTrace,
    'timestamp': timestamp.toIso8601String(),
    'isFatal': isFatal,
  };
}
