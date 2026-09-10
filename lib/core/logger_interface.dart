import '../models/log_entry.dart';
import '../models/log_tag.dart';

/// Severity of a logged entry, used for the Logs tab's color coding and
/// level filter.
enum LogLevel {
  /// Verbose, developer-only detail.
  debug,

  /// Notable but expected events.
  info,

  /// Something unexpected that the app recovered from.
  warning,

  /// A failure worth investigating.
  error,
}

/// Where `FlutterDevToolkit.logger.log` calls are routed.
///
/// Implement this to forward log entries somewhere other than the built-in
/// in-memory buffer (e.g. a remote log service), while still feeding the
/// Logs tab by also storing them for [logEntries]. Pass an instance via
/// `DevToolkitConfig(logger: ...)`.
abstract class LoggerInterface {
  /// Records a log entry.
  void log(
    String message, {
    LogLevel level = LogLevel.debug,
    Set<LogTag> tags = const {},
  });

  /// Entries available for the Logs tab to render. Implementations that
  /// don't retain entries in memory can leave this at the default empty list.
  List<LogEntry> get logEntries => const [];

  /// Discards retained entries, if any.
  void clear() {}
}
