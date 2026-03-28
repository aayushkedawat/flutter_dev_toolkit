import '../interceptors/network/network_log.dart';

class NetworkLogStore {
  static final List<NetworkLog> _logs = [];
  static int _maxLogs = 500;

  /// Called by [FlutterDevToolkit.init] to apply [DevToolkitConfig.maxNetworkLogs].
  static void configure({required int maxLogs}) {
    _maxLogs = maxLogs;
  }

  static void add(NetworkLog log) {
    _logs.add(log);
    if (_logs.length > _maxLogs) _logs.removeAt(0);
  }

  static List<NetworkLog> get logs => List.unmodifiable(_logs);

  static void clear() => _logs.clear();
}
