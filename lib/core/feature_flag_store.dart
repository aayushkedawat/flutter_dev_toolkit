import 'package:flutter/foundation.dart';

/// How a [FeatureFlag]'s value should be presented and edited in the Flags
/// tab.
enum FeatureFlagType {
  boolean,
  string,

  /// Backed by `num`, so a value may come back as either `int` or `double`
  /// depending on what was typed into the editor — read it as `num` and
  /// convert (`.toInt()`, `.toDouble()`) rather than assuming one or the
  /// other.
  number,

  /// One of a fixed set of values, given as [FeatureFlag.options].
  options,
}

/// A single runtime-toggleable value, registered by the host app and flipped
/// from the Flags tab without a rebuild.
///
/// Listen to [notifier] directly wherever the app needs to react to changes:
///
/// ```dart
/// final flag = FeatureFlagStore.register(FeatureFlag(
///   key: 'new_checkout_flow',
///   label: 'New Checkout Flow',
///   type: FeatureFlagType.boolean,
///   defaultValue: false,
/// ));
///
/// ValueListenableBuilder(
///   valueListenable: flag.notifier,
///   builder: (_, enabled, __) => (enabled as bool) ? NewCheckout() : OldCheckout(),
/// );
/// ```
class FeatureFlag {
  FeatureFlag({
    required this.key,
    required this.label,
    required this.type,
    required Object defaultValue,
    this.options,
  }) : defaultValue = defaultValue,
       notifier = ValueNotifier<Object>(defaultValue) {
    assert(
      type != FeatureFlagType.options ||
          (options != null && options!.isNotEmpty),
      'FeatureFlagType.options requires a non-empty options list',
    );
  }

  /// Stable identifier. Also what the app looks the flag up by via
  /// [FeatureFlagStore.get].
  final String key;

  /// Shown in the Flags tab in place of [key].
  final String label;

  final FeatureFlagType type;

  /// Restored by [reset] and by the tab's "reset all" action.
  final Object defaultValue;

  /// Required, and must be non-empty, when [type] is [FeatureFlagType.options].
  final List<Object>? options;

  final ValueNotifier<Object> notifier;

  Object get value => notifier.value;
  set value(Object v) => notifier.value = v;

  void reset() => notifier.value = defaultValue;
}

/// Registry of feature flags the host app has registered, backing the Flags
/// tab.
class FeatureFlagStore {
  static final Map<String, FeatureFlag> _flags = {};

  /// Bumped when a flag is registered, so the tab picks up new flags added
  /// after it first opened. Per-flag value changes are notified through that
  /// flag's own [FeatureFlag.notifier] instead — listening here for every
  /// value change would rebuild the whole list on every keystroke.
  static final ValueNotifier<int> version = ValueNotifier(0);

  static List<FeatureFlag> get flags => List.unmodifiable(_flags.values);

  /// Registers [flag]. If a flag with the same key is already registered, the
  /// existing one — and whatever value it currently holds — is kept and
  /// returned instead, so re-registering on hot reload doesn't reset a value
  /// someone just toggled.
  static FeatureFlag register(FeatureFlag flag) {
    final existing = _flags[flag.key];
    if (existing != null) return existing;
    _flags[flag.key] = flag;
    version.value++;
    return flag;
  }

  static FeatureFlag? get(String key) => _flags[key];

  static void resetAll() {
    for (final flag in _flags.values) {
      flag.reset();
    }
  }

  @visibleForTesting
  static void clear() {
    _flags.clear();
    version.value++;
  }
}
