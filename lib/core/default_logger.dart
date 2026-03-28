import 'package:flutter/material.dart';

import '../models/log_tag.dart';
import 'logger_interface.dart';
import '../models/log_entry.dart';

class DefaultLogger implements LoggerInterface {
  DefaultLogger({this.maxEntries = 2000});

  final int maxEntries;

  static final ValueNotifier<int> logVersion = ValueNotifier(0);

  /// Incremented each time an error-level entry is added. Never decremented,
  /// so the FAB badge always reflects the total error count for the session.
  static final ValueNotifier<int> errorCount = ValueNotifier(0);

  final List<LogEntry> _entries = [];

  @override
  List<LogEntry> get logEntries => List.unmodifiable(_entries);

  @override
  void log(
    String message, {
    LogLevel level = LogLevel.debug,
    Set<LogTag> tags = const {},
  }) {
    final entry = LogEntry(message: message, level: level, tags: tags);
    _entries.add(entry);
    if (_entries.length > maxEntries) _entries.removeAt(0);
    logVersion.value++;
    if (level == LogLevel.error) errorCount.value++;
  }

  @override
  void clear() {
    _entries.clear();
    logVersion.value++;
  }
}
