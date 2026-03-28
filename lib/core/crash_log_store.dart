import 'package:flutter/material.dart';
import '../models/crash_entry.dart';

class CrashLogStore {
  static final List<CrashEntry> _entries = [];
  static final ValueNotifier<int> version = ValueNotifier(0);

  static void add(CrashEntry entry) {
    _entries.add(entry);
    if (_entries.length > 200) _entries.removeAt(0);
    version.value++;
  }

  static List<CrashEntry> get entries => List.unmodifiable(_entries);

  static void clear() {
    _entries.clear();
    version.value++;
  }
}
