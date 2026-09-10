import 'package:flutter/material.dart';
import '../models/crash_entry.dart';

/// In-memory buffer of captured crashes, feeding the Crashes tab.
///
/// Populated by the `FlutterError.onError`/`PlatformDispatcher.onError`
/// hooks installed at `FlutterDevToolkit.init`; hard-capped at 200 entries.
class CrashLogStore {
  static final List<CrashEntry> _entries = [];

  /// Bumped on every [add] and [clear] so the Crashes tab can rebuild.
  static final ValueNotifier<int> version = ValueNotifier(0);

  /// Records a crash, dropping the oldest entry once the store holds more
  /// than 200.
  static void add(CrashEntry entry) {
    _entries.add(entry);
    if (_entries.length > 200) _entries.removeAt(0);
    version.value++;
  }

  /// All captured crashes, oldest first.
  static List<CrashEntry> get entries => List.unmodifiable(_entries);

  /// Discards every captured crash.
  static void clear() {
    _entries.clear();
    version.value++;
  }
}
