import '../core/logger_interface.dart';
import 'log_tag.dart';

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;
  final Set<LogTag> tags;

  LogEntry({
    required this.message,
    this.level = LogLevel.debug,
    DateTime? timestamp,
    this.tags = const {},
  }) : timestamp = timestamp ?? DateTime.now();
}
