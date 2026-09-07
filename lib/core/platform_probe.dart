library;

/// A tiny slice of `dart:io`'s `Platform`, resolved at compile time so the
/// package works on web. `Platform.isAndroid`, `.operatingSystem` and
/// friends throw `UnsupportedError` at runtime there — verified by compiling
/// this exact code with `dart compile js` and running the output — so this
/// has to be a conditional export resolved before `dart:io` is ever touched,
/// not a runtime `kIsWeb` branch guarding the same throwing call.
export 'platform_probe_stub.dart' if (dart.library.io) 'platform_probe_io.dart';
