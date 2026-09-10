import 'package:flutter/foundation.dart';

import 'app_state_adapter.dart';
import 'app_state_entry.dart';

/// An adapter the host app pushes state changes into.
///
/// The toolkit ships a first-class `BlocAdapter` because it already depends on
/// `bloc`. Taking on `riverpod`, `provider`, `signals` and friends as
/// dependencies just to observe them would force every consumer to resolve
/// packages they may not use, so those frameworks are wired up from the app
/// side instead — each is only a few lines, because they all expose an
/// observer or listener hook.
///
/// Riverpod:
///
/// ```dart
/// final riverpodInspector = RecordedStateAdapter(name: 'Riverpod');
///
/// class DevToolkitProviderObserver extends ProviderObserver {
///   @override
///   void didUpdateProvider(provider, previousValue, newValue, container) {
///     riverpodInspector.record(
///       provider.name ?? provider.runtimeType.toString(),
///       newValue,
///       previous: previousValue,
///     );
///   }
/// }
///
/// ProviderScope(observers: [DevToolkitProviderObserver()], child: MyApp());
/// ```
///
/// Provider / ChangeNotifier:
///
/// ```dart
/// final providerInspector = RecordedStateAdapter(name: 'Provider');
///
/// class CartModel extends ChangeNotifier {
///   CartModel() {
///     addListener(() => providerInspector.record('CartModel', items));
///   }
/// }
/// ```
///
/// Then hand the adapters to the inspector:
///
/// ```dart
/// FlutterDevToolkit.registerPlugin(
///   AppStateInspectorPlugin([BlocAdapter(), riverpodInspector]),
/// );
/// ```
class RecordedStateAdapter extends AppStateAdapter {
  /// Creates an adapter labeled [name] in the inspector's dropdown, retaining
  /// up to [maxEntries] recorded changes.
  RecordedStateAdapter({required this.name, this.maxEntries = 500})
    : assert(maxEntries > 0, 'maxEntries must be positive');

  @override
  final String name;

  /// Oldest entries are dropped once this many are held, matching the cap on
  /// the toolkit's other stores.
  final int maxEntries;

  final List<AppStateEntry> _entries = [];
  final ValueNotifier<int> _version = ValueNotifier(0);

  @override
  Listenable? get revision => _version;

  @override
  List<AppStateEntry> get entries => List.unmodifiable(_entries);

  /// Records a state change. [source] names the provider, notifier or store it
  /// came from and becomes the entry's title in the inspector.
  void record(String source, Object? value, {Object? previous}) {
    _entries.add(
      AppStateEntry(
        source: source,
        value: value,
        previousState: previous,
        timestamp: DateTime.now(),
      ),
    );
    if (_entries.length > maxEntries) _entries.removeAt(0);
    _version.value++;
  }

  /// Discards every recorded change.
  void clear() {
    _entries.clear();
    _version.value++;
  }
}
