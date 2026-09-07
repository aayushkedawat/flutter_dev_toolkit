import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../core/logger_interface.dart';
import '../../flutter_dev_toolkit.dart';

/// A single frame that missed the budget.
class JankFrame {
  final Duration build;
  final Duration raster;
  final DateTime at;

  JankFrame({required this.build, required this.raster, DateTime? at})
    : at = at ?? DateTime.now();

  Duration get total => build + raster;
}

/// The toolkit's single source of jank data.
///
/// Registered once by [InterceptorRegistry] when the Performance plugin is
/// enabled; the Performance tab reads the counters rather than installing a
/// second timings callback of its own.
class FrameDropDetector {
  /// Frames whose build + raster time exceeds this count as jank. 16 ms is the
  /// budget for 60 fps.
  static const Duration budget = Duration(milliseconds: 16);

  /// How many recent jank frames are kept for display.
  static const int maxRetained = 100;

  static bool _initialized = false;
  static int _totalFrames = 0;
  static int _jankFrameCount = 0;
  static final List<JankFrame> _jankFrames = [];

  /// Bumped when a jank frame is recorded, so the Performance tab can refresh.
  static final ValueNotifier<int> version = ValueNotifier(0);

  static int get totalFrames => _totalFrames;

  /// Total jank frames seen this session. May exceed [jankFrames] length,
  /// which is capped at [maxRetained].
  static int get jankFrameCount => _jankFrameCount;

  static List<JankFrame> get jankFrames => List.unmodifiable(_jankFrames);

  static void init() {
    if (_initialized) return;
    _initialized = true;

    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  static void _onFrameTimings(List<FrameTiming> timings) {
    var recorded = false;

    for (final timing in timings) {
      _totalFrames++;

      final build = timing.buildDuration;
      final raster = timing.rasterDuration;
      if (build + raster <= budget) continue;

      _jankFrameCount++;
      _jankFrames.add(JankFrame(build: build, raster: raster));
      if (_jankFrames.length > maxRetained) _jankFrames.removeAt(0);
      recorded = true;

      if (FlutterDevToolkit.config.logFrameDrops) {
        FlutterDevToolkit.logger.log(
          '⚠️ Frame took ${(build + raster).inMilliseconds}ms '
          '(build ${build.inMilliseconds}ms, raster ${raster.inMilliseconds}ms)',
          level: LogLevel.warning,
        );
      }
    }

    if (recorded) version.value++;
  }

  static void clear() {
    _totalFrames = 0;
    _jankFrameCount = 0;
    _jankFrames.clear();
    version.value++;
  }

  @visibleForTesting
  static void recordForTest(List<FrameTiming> timings) =>
      _onFrameTimings(timings);
}
