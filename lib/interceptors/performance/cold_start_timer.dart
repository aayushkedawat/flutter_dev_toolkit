import 'package:flutter/widgets.dart';

import '../../core/logger_interface.dart';
import '../../flutter_dev_toolkit.dart';

/// Measures how long the app took to render its first frame.
///
/// [start] is called at the top of [FlutterDevToolkit.init]; the timer stops on
/// the first post-frame callback. The result is therefore "time from toolkit
/// init to first frame", which is as close to a cold start as a package can
/// observe without platform hooks — it excludes engine boot and Dart VM
/// startup that happen before `main()` runs.
class ColdStartTimer {
  static final Stopwatch _stopwatch = Stopwatch();

  static Duration? _coldStart;

  /// Null until the first frame has rendered.
  static Duration? get coldStart => _coldStart;

  /// Bumped once the measurement lands, so the Performance tab can refresh.
  static final ValueNotifier<int> version = ValueNotifier(0);

  static void start() {
    if (_stopwatch.isRunning || _coldStart != null) return;

    _stopwatch
      ..reset()
      ..start();

    WidgetsBinding.instance.addPostFrameCallback((_) => _stop());
  }

  static void _stop() {
    if (!_stopwatch.isRunning) return;

    _stopwatch.stop();
    _coldStart = _stopwatch.elapsed;
    version.value++;

    FlutterDevToolkit.logger.log(
      '🚀 First frame rendered ${_coldStart!.inMilliseconds}ms after init',
      level: LogLevel.info,
    );
  }

  @visibleForTesting
  static void reset() {
    _stopwatch
      ..stop()
      ..reset();
    _coldStart = null;
    version.value++;
  }
}
