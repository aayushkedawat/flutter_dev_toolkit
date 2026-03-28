import 'package:flutter/material.dart';
import '../models/deep_link_entry.dart';

class DeepLinkStore {
  static final List<DeepLinkEntry> _entries = [];
  static final ValueNotifier<int> version = ValueNotifier(0);

  static void add(DeepLinkEntry entry) {
    _entries.add(entry);
    if (_entries.length > 200) _entries.removeAt(0);
    version.value++;
  }

  static List<DeepLinkEntry> get entries => List.unmodifiable(_entries);

  static void clear() {
    _entries.clear();
    version.value++;
  }
}
