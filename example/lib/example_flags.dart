import 'package:flutter_dev_toolkit/core/feature_flag_store.dart';

/// Registered once in main() before runApp(), then read from anywhere in the
/// app. Toggle these from the toolkit's Flags tab to see them take effect
/// live, with no rebuild of the app itself.
final showPromoBannerFlag = FeatureFlagStore.register(
  FeatureFlag(
    key: 'show_promo_banner',
    label: 'Show Promo Banner',
    type: FeatureFlagType.boolean,
    defaultValue: false,
  ),
);

final accentColorFlag = FeatureFlagStore.register(
  FeatureFlag(
    key: 'accent_color',
    label: 'Accent Color',
    type: FeatureFlagType.options,
    defaultValue: 'blue',
    options: ['blue', 'purple', 'green'],
  ),
);
