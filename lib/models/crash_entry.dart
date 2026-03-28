class CrashEntry {
  final String message;
  final String stackTrace;
  final DateTime timestamp;

  /// True when the error was caught by [PlatformDispatcher.onError] (i.e. an
  /// unhandled async error that would normally terminate the isolate).
  final bool isFatal;

  CrashEntry({
    required this.message,
    required this.stackTrace,
    this.isFatal = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'message': message,
    'stackTrace': stackTrace,
    'timestamp': timestamp.toIso8601String(),
    'isFatal': isFatal,
  };
}
