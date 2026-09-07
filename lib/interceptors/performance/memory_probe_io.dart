import 'dart:io';

int? currentMemoryMb() {
  try {
    return (ProcessInfo.currentRss / 1024 / 1024).round();
  } catch (_) {
    // Not every dart:io platform (e.g. some embedded targets) implements this.
    return null;
  }
}
