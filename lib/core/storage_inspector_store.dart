import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One `SharedPreferences` entry. [value] is whatever `SharedPreferences`
/// returned for the key: `bool`, `int`, `double`, `String`, or
/// `List<String>`.
class StorageEntry {
  /// The `SharedPreferences` key.
  final String key;

  /// The stored value, or `null` if the key holds no value.
  final Object? value;

  /// Creates a storage entry.
  const StorageEntry({required this.key, required this.value});
}

/// A cached, editable view of the app's `SharedPreferences`, backing the
/// Storage tab.
///
/// `SharedPreferences` has no change notifications of its own, so this holds
/// a snapshot that is refreshed explicitly — on first tab open, after every
/// write made through this store, and via the tab's own refresh button —
/// rather than reacting live to writes the host app makes directly through
/// `SharedPreferences` while the tab happens to be open.
class StorageInspectorStore {
  static List<StorageEntry> _entries = [];
  static bool _loaded = false;

  /// Bumped on every [refresh], [setValue], [remove], and [clearAll] so the
  /// Storage tab can rebuild.
  static final ValueNotifier<int> version = ValueNotifier(0);

  /// The last-loaded snapshot, sorted by key.
  static List<StorageEntry> get entries => List.unmodifiable(_entries);

  /// Whether [refresh] has been called at least once.
  static bool get isLoaded => _loaded;

  /// Reloads [entries] from `SharedPreferences`.
  static Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList()..sort();
    _entries = [
      for (final key in keys) StorageEntry(key: key, value: prefs.get(key)),
    ];
    _loaded = true;
    version.value++;
  }

  /// Writes [value] for [key], dispatching to the matching typed setter —
  /// `SharedPreferences` has no untyped `set`. Throws [ArgumentError] for any
  /// type it doesn't support.
  static Future<void> setValue(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (value) {
      case bool v:
        await prefs.setBool(key, v);
      case int v:
        await prefs.setInt(key, v);
      case double v:
        await prefs.setDouble(key, v);
      case String v:
        await prefs.setString(key, v);
      case List<String> v:
        await prefs.setStringList(key, v);
      default:
        throw ArgumentError(
          'Unsupported SharedPreferences value type: ${value.runtimeType}',
        );
    }
    await refresh();
  }

  /// Deletes [key], then refreshes [entries].
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await refresh();
  }

  /// Deletes every `SharedPreferences` entry, then refreshes [entries].
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await refresh();
  }
}
