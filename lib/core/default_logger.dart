import 'package:flutter/material.dart';

import '../models/log_tag.dart';
import 'logger_interface.dart';
import '../models/log_entry.dart';

/// The toolkit's built-in [LoggerInterface] implementation: an in-memory,
/// capped log buffer feeding the Logs tab.
class DefaultLogger implements LoggerInterface {
  /// [maxEntries] caps how many entries are retained in memory. When it is
  /// omitted the cap is taken from `DevToolkitConfig.maxLogEntries` at
  /// `FlutterDevToolkit.init` time; passing it explicitly always wins.
  DefaultLogger({int? maxEntries})
    : _explicitMaxEntries = maxEntries,
      _maxEntries = maxEntries ?? defaultMaxEntries;

  /// Retention cap used when neither the constructor nor the config sets one.
  static const int defaultMaxEntries = 2000;

  final int? _explicitMaxEntries;
  int _maxEntries;

  /// The current retention cap.
  int get maxEntries => _maxEntries;

  /// Called by `FlutterDevToolkit.init` to apply
  /// `DevToolkitConfig.maxLogEntries`. A cap passed to the constructor takes
  /// precedence, so a consumer who configured the logger directly keeps it.
  void configure({required int maxEntries}) {
    if (_explicitMaxEntries != null) return;
    _maxEntries = maxEntries;
    _trim();
  }

  static final ValueNotifier<int> logVersion = ValueNotifier(0);

  /// Incremented each time an error-level entry is added. Never decremented,
  /// so the FAB badge always reflects the total error count for the session.
  static final ValueNotifier<int> errorCount = ValueNotifier(0);

  final List<LogEntry> _entries = [];

  /// All retained entries, oldest first.
  @override
  List<LogEntry> get logEntries => List.unmodifiable(_entries);

  /// Appends a log entry, trimming the oldest one if [maxEntries] is now
  /// exceeded.
  @override
  void log(
    String message, {
    LogLevel level = LogLevel.debug,
    Set<LogTag> tags = const {},
  }) {
    final entry = LogEntry(message: message, level: level, tags: tags);
    _entries.add(entry);
    _trim();
    logVersion.value++;
    if (level == LogLevel.error) errorCount.value++;
  }

  /// Discards every retained entry.
  @override
  void clear() {
    _entries.clear();
    logVersion.value++;
  }

  void _trim() {
    while (_entries.length > _maxEntries) {
      _entries.removeAt(0);
    }
  }
}
