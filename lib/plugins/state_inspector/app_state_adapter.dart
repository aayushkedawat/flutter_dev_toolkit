import 'app_state_entry.dart';

abstract class AppStateAdapter {
  String get name; // e.g., "Bloc", "Riverpod"
  List<AppStateEntry> get entries;
}
