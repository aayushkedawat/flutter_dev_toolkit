import '../interceptors/network/network_log.dart';

class NetworkLogStore {
  static final List<NetworkLog> _logs = [];

  static void add(NetworkLog log) {
    _logs.add(log);
    if (_logs.length > 500) _logs.removeAt(0); // limit
  }

  static List<NetworkLog> get logs => List.unmodifiable(_logs);

  static void clear() => _logs.clear();
}
