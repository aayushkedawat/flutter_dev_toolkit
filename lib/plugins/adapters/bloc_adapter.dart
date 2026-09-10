import 'package:flutter/foundation.dart';

import '../state_inspector/app_state_adapter.dart';
import '../state_inspector/app_state_entry.dart';
import '../state_inspector/bloc_state_tracker.dart';

/// Feeds `flutter_bloc`/`bloc` state changes into the App State Inspector,
/// via [DevBlocObserver]. Set `Bloc.observer = DevBlocObserver()` before
/// creating any Bloc/Cubit, then pass a [BlocAdapter] to
/// `AppStateInspectorPlugin`.
class BlocAdapter extends AppStateAdapter {
  @override
  String get name => 'Bloc';

  @override
  Listenable? get revision => DevBlocObserver.version;

  @override
  List<AppStateEntry> get entries =>
      DevBlocObserver.entries
          .map(
            (e) => AppStateEntry(
              source: e.blocType,
              value: e.currentState,
              previousState: e.previousState,
              timestamp: e.timestamp,
            ),
          )
          .toList();
}
