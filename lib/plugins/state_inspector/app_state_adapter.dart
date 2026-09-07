import 'package:flutter/foundation.dart';

import 'app_state_entry.dart';

abstract class AppStateAdapter {
  String get name; // e.g., "Bloc", "Riverpod"
  List<AppStateEntry> get entries;

  /// Notified whenever [entries] changes, so the inspector can rebuild as
  /// state flows in. Return null if the underlying source cannot signal
  /// updates — the tab then only refreshes when it is rebuilt for other
  /// reasons.
  Listenable? get revision => null;
}
