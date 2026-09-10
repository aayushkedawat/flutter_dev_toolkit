import 'package:flutter/material.dart';
import '../models/deep_link_entry.dart';

/// In-memory buffer of recorded deep links, feeding the Deep Links tab.
///
/// Populated via `DevToolkitDeepLinkObserver.onLinkReceived`; hard-capped at
/// 200 entries.
class DeepLinkStore {
  static final List<DeepLinkEntry> _entries = [];

  /// Bumped on every [add] and [clear] so the Deep Links tab can rebuild.
  static final ValueNotifier<int> version = ValueNotifier(0);

  /// Records a deep link, dropping the oldest entry once the store holds
  /// more than 200.
  static void add(DeepLinkEntry entry) {
    _entries.add(entry);
    if (_entries.length > 200) _entries.removeAt(0);
    version.value++;
  }

  /// All recorded deep links, oldest first.
  static List<DeepLinkEntry> get entries => List.unmodifiable(_entries);

  /// Discards every recorded deep link.
  static void clear() {
    _entries.clear();
    version.value++;
  }
}
