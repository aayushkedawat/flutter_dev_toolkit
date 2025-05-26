import '../state_inspector/app_state_adapter.dart';
import '../state_inspector/app_state_entry.dart';
import '../state_inspector/bloc_state_tracker.dart';

class BlocAdapter extends AppStateAdapter {
  @override
  String get name => 'Bloc';

  @override
  List<AppStateEntry> get entries =>
      DevBlocObserver.entries
          .map(
            (e) => AppStateEntry(
              source: e.blocType,
              value: e.currentState,
              timestamp: e.timestamp,
            ),
          )
          .toList();
}
