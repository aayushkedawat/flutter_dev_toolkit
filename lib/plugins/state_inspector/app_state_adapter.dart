import 'package:flutter/foundation.dart';

import 'app_state_entry.dart';

/// Bridges a state-management framework's changes into the App State
/// Inspector. The toolkit ships `BlocAdapter` for `bloc`/`flutter_bloc`;
/// wire up anything else via `RecordedStateAdapter`.
abstract class AppStateAdapter {
  /// This source's label in the inspector's dropdown (e.g. `'Bloc'`,
  /// `'Riverpod'`).
  String get name;

  /// Recorded state changes, oldest first.
  List<AppStateEntry> get entries;

  /// Notified whenever [entries] changes, so the inspector can rebuild as
  /// state flows in. Return null if the underlying source cannot signal
  /// updates — the tab then only refreshes when it is rebuilt for other
  /// reasons.
  Listenable? get revision => null;
}
