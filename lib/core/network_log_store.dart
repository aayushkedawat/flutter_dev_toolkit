import 'package:flutter/foundation.dart';

import '../interceptors/network/network_log.dart';

/// In-memory buffer of captured network calls, feeding the Network tab.
///
/// Populated by `HttpInterceptor` and `DioNetworkInterceptor`; capped at
/// `DevToolkitConfig.maxNetworkLogs` (default 500).
class NetworkLogStore {
  static final List<NetworkLog> _logs = [];
  static int _maxLogs = 500;

  /// Bumped whenever the store changes, so the Network tab updates as calls
  /// come in rather than only when the user touches a filter.
  static final ValueNotifier<int> version = ValueNotifier(0);

  /// Called by `FlutterDevToolkit.init` to apply
  /// `DevToolkitConfig.maxNetworkLogs`.
  static void configure({required int maxLogs}) {
    _maxLogs = maxLogs;
  }

  /// Records a network log, dropping the oldest entry once the store holds
  /// more than the configured cap.
  static void add(NetworkLog log) {
    _logs.add(log);
    if (_logs.length > _maxLogs) _logs.removeAt(0);
    version.value++;
  }

  /// All captured network calls, oldest first.
  static List<NetworkLog> get logs => List.unmodifiable(_logs);

  /// Discards every captured network call.
  static void clear() {
    _logs.clear();
    version.value++;
  }
}
