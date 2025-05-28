import '../models/log_entry.dart';
import '../models/log_tag.dart';

enum LogLevel { debug, info, warning, error }

abstract class LoggerInterface {
  void log(
    String message, {
    LogLevel level = LogLevel.debug,
    Set<LogTag> tags = const {},
  });

  List<LogEntry> get logEntries => const [];

  void clear() {}
}
