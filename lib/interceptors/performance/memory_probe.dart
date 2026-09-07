library;

/// Reads the current process's resident memory in MB, or null where that
/// concept doesn't apply (web has no OS process to measure).
///
/// The real implementation touches `dart:io`, whose members throw
/// `UnsupportedError` at runtime on web (confirmed by compiling this exact
/// call with `dart compile js` and running the output — it compiles cleanly,
/// then throws the moment `ProcessInfo.currentRss` is actually read). So the
/// split has to happen at the import statement via conditional export,
/// resolved at compile time to the platform that never touches `dart:io` at
/// all on web, rather than a runtime `kIsWeb` check that still evaluates the
/// throwing call.
export 'memory_probe_stub.dart' if (dart.library.io) 'memory_probe_io.dart';
