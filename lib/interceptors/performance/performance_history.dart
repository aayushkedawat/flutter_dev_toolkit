import 'package:flutter/foundation.dart';

/// One FPS/memory reading, taken roughly once a second by [PerformanceTab].
class PerformanceSample {
  final DateTime at;
  final double fps;

  /// Null wherever [currentMemoryMb] can't read it (e.g. web).
  final int? memoryMb;

  const PerformanceSample({required this.at, required this.fps, this.memoryMb});
}

/// A rolling window of recent performance samples, so the Performance tab can
/// show a trend instead of only an instantaneous snapshot — whether a dip is
/// constant or only happens during a scroll, whether memory is flat or
/// climbing, are both invisible in a single-number readout.
class PerformanceHistory {
  /// Samples are taken about once a second, so this is roughly how many
  /// seconds of history are kept.
  static const int maxSamples = 60;

  static final List<PerformanceSample> _samples = [];
  static final ValueNotifier<int> version = ValueNotifier(0);

  static List<PerformanceSample> get samples => List.unmodifiable(_samples);

  static void record({required double fps, int? memoryMb}) {
    _samples.add(
      PerformanceSample(at: DateTime.now(), fps: fps, memoryMb: memoryMb),
    );
    if (_samples.length > maxSamples) _samples.removeAt(0);
    version.value++;
  }

  static void clear() {
    _samples.clear();
    version.value++;
  }
}
