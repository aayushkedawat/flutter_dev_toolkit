import 'package:flutter/foundation.dart';

import 'network_mock_rule.dart';

/// Mock rules configured from the Network plugin's config panel. Checked by
/// both `HttpInterceptor` and `DioNetworkInterceptor` before a request would
/// otherwise reach the network; the first enabled match wins.
class NetworkMockStore {
  static final List<NetworkMockRule> _rules = [];

  /// Bumped on every rule change so the config panel can rebuild.
  static final ValueNotifier<int> version = ValueNotifier(0);

  /// All configured rules, in the order they're checked.
  static List<NetworkMockRule> get rules => List.unmodifiable(_rules);

  /// The first enabled rule matching [method] and [url], or `null` if none
  /// does.
  static NetworkMockRule? match(String method, String url) {
    for (final rule in _rules) {
      if (rule.matches(method, url)) return rule;
    }
    return null;
  }

  /// Appends a new rule.
  static void add(NetworkMockRule rule) {
    _rules.add(rule);
    version.value++;
  }

  /// Replaces the rule at [index].
  static void updateAt(int index, NetworkMockRule rule) {
    _rules[index] = rule;
    version.value++;
  }

  /// Removes the rule at [index].
  static void removeAt(int index) {
    _rules.removeAt(index);
    version.value++;
  }

  /// Removes every rule.
  static void clear() {
    _rules.clear();
    version.value++;
  }
}
