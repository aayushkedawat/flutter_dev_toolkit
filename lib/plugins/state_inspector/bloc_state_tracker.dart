import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// One recorded Bloc/Cubit state transition.
class BlocStateEntry {
  /// The bloc/cubit's runtime type name.
  final String blocType;

  /// The new state.
  final dynamic currentState;

  /// The state before this change.
  final dynamic previousState;

  /// When this change was recorded.
  final DateTime timestamp;

  /// Creates a transition record, timestamped now.
  BlocStateEntry(this.blocType, this.currentState, [this.previousState])
    : timestamp = DateTime.now();
}

/// A `BlocObserver` that records every Bloc/Cubit state change for the App
/// State Inspector. Set `Bloc.observer = DevBlocObserver()` before creating
/// any Bloc/Cubit.
class DevBlocObserver extends BlocObserver {
  /// Maximum transitions retained in memory. Oldest entries are dropped first,
  /// matching the behaviour of the other toolkit stores.
  static const int maxEntries = 500;

  static final List<BlocStateEntry> _entries = [];

  /// Bumped on every recorded change so the inspector can rebuild live.
  static final ValueNotifier<int> version = ValueNotifier(0);

  /// Recorded transitions, oldest first, capped at [maxEntries].
  static List<BlocStateEntry> get entries => List.unmodifiable(_entries);

  /// Records the transition, then chains to the superclass.
  @override
  void onChange(BlocBase bloc, Change change) {
    _entries.add(
      BlocStateEntry(
        bloc.runtimeType.toString(),
        change.nextState,
        change.currentState,
      ),
    );
    if (_entries.length > maxEntries) _entries.removeAt(0);
    version.value++;
    super.onChange(bloc, change);
  }

  /// Discards every recorded transition.
  static void clear() {
    _entries.clear();
    version.value++;
  }
}
