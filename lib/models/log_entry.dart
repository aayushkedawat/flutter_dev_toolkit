import '../core/logger_interface.dart';
import 'log_tag.dart';

/// One recorded log line, as stored by a [LoggerInterface] implementation
/// and rendered by the Logs tab.
class LogEntry {
  /// The logged text.
  final String message;

  /// Severity used for the Logs tab's color coding and level filter.
  final LogLevel level;

  /// When this entry was logged. Defaults to [DateTime.now] if omitted.
  final DateTime timestamp;

  /// Categories this entry belongs to, used by the Logs tab's tag filter.
  final Set<LogTag> tags;

  /// Creates a log entry. [level] defaults to [LogLevel.debug] and
  /// [timestamp] to now if not supplied.
  LogEntry({
    required this.message,
    this.level = LogLevel.debug,
    DateTime? timestamp,
    this.tags = const {},
  }) : timestamp = timestamp ?? DateTime.now();
}
