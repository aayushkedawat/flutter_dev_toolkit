import 'package:flutter/scheduler.dart';
import '../../core/logger_interface.dart';
import '../../flutter_dev_toolkit.dart';

class FrameDropDetector {
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    FlutterDevToolkit.logger.log('FrameDropDetector initialized');
  }

  static void _onFrameTimings(List<FrameTiming> timings) {
    for (var timing in timings) {
      final totalTime = timing.totalSpan.inMilliseconds;

      if (totalTime > 16) {
        FlutterDevToolkit.logger.log(
          '⚠️ Frame took ${totalTime}ms (dropped frames)',
          level: LogLevel.warning,
        );
      }
    }
  }
}
