import 'logger_interface.dart';
import 'log_entry.dart';

class DefaultLogger implements LoggerInterface {
  DefaultLogger();
  final List<LogEntry> _entries = [];

  @override
  void log(String message, {LogLevel level = LogLevel.debug}) {
    _entries.add(LogEntry(message, level, DateTime.now()));
    if (_entries.length > 2000) _entries.removeAt(0); // keep it bounded
  }

  @override
  List<LogEntry> get logEntries => List.unmodifiable(_entries);
  @override
  void clear() {
    _entries.clear();
  }
}
