import 'package:flutter/foundation.dart';

/// One FPS/memory reading, taken roughly once a second by `PerformanceTab`.
class PerformanceSample {
  /// When this sample was taken.
  final DateTime at;

  /// Frames per second at the time of sampling.
  final double fps;

  /// Null wherever `currentMemoryMb` can't read it (e.g. web).
  final int? memoryMb;

  /// Creates a performance sample.
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

  /// Bumped on every [record] and [clear], so the Performance tab's
  /// sparkline can redraw.
  static final ValueNotifier<int> version = ValueNotifier(0);

  /// The retained samples, oldest first, capped at [maxSamples].
  static List<PerformanceSample> get samples => List.unmodifiable(_samples);

  /// Appends a sample, dropping the oldest once the window holds more than
  /// [maxSamples].
  static void record({required double fps, int? memoryMb}) {
    _samples.add(
      PerformanceSample(at: DateTime.now(), fps: fps, memoryMb: memoryMb),
    );
    if (_samples.length > maxSamples) _samples.removeAt(0);
    version.value++;
  }

  /// Discards every retained sample.
  static void clear() {
    _samples.clear();
    version.value++;
  }
}
