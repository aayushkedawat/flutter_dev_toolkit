import 'package:flutter_dev_toolkit/core/log_entry.dart';

enum LogLevel { debug, info, warning, error }

abstract class LoggerInterface {
  void log(String message, {LogLevel level = LogLevel.debug});
  List<LogEntry> get logEntries => const [];
  void clear() {}
}
