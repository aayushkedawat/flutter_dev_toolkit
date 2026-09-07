import 'package:flutter/foundation.dart';

import 'network_mock_rule.dart';

/// Mock rules configured from the Network plugin's config panel. Checked by
/// both [HttpInterceptor] and [DioNetworkInterceptor] before a request would
/// otherwise reach the network; the first enabled match wins.
class NetworkMockStore {
  static final List<NetworkMockRule> _rules = [];
  static final ValueNotifier<int> version = ValueNotifier(0);

  static List<NetworkMockRule> get rules => List.unmodifiable(_rules);

  static NetworkMockRule? match(String method, String url) {
    for (final rule in _rules) {
      if (rule.matches(method, url)) return rule;
    }
    return null;
  }

  static void add(NetworkMockRule rule) {
    _rules.add(rule);
    version.value++;
  }

  static void updateAt(int index, NetworkMockRule rule) {
    _rules[index] = rule;
    version.value++;
  }

  static void removeAt(int index) {
    _rules.removeAt(index);
    version.value++;
  }

  static void clear() {
    _rules.clear();
    version.value++;
  }
}
