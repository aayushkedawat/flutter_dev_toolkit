import 'logger_interface.dart';

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;

  LogEntry(this.message, this.level, this.timestamp);
}
