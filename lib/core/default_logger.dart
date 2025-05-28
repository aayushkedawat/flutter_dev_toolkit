import 'package:flutter/material.dart';

import '../models/log_tag.dart';
import 'logger_interface.dart';
import '../models/log_entry.dart';

class DefaultLogger implements LoggerInterface {
  DefaultLogger();

  static final ValueNotifier<int> logVersion = ValueNotifier(0);
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
    if (_entries.length > 2000) _entries.removeAt(0);
    logVersion.value++;
  }

  @override
  @override
  void clear() {
    _entries.clear();
    logVersion.value++;
  }
}
