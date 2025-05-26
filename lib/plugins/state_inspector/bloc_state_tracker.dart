import 'package:bloc/bloc.dart';

class BlocStateEntry {
  final String blocType;
  final dynamic currentState;
  final dynamic previousState;
  final DateTime timestamp;

  BlocStateEntry(this.blocType, this.currentState, [this.previousState])
    : timestamp = DateTime.now();
}

class DevBlocObserver extends BlocObserver {
  static final List<BlocStateEntry> _entries = [];

  static List<BlocStateEntry> get entries => List.unmodifiable(_entries);

  @override
  void onChange(BlocBase bloc, Change change) {
    _entries.add(BlocStateEntry(bloc.runtimeType.toString(), change.nextState));
    super.onChange(bloc, change);
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
  }
}
