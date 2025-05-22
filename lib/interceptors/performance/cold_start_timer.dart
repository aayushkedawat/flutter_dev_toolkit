import '../../flutter_dev_toolkit.dart';

class ColdStartTimer {
  static final Stopwatch _stopwatch = Stopwatch();

  static void start() {
    _stopwatch.start();
  }

  static void end() {
    _stopwatch.stop();
    final duration = _stopwatch.elapsedMilliseconds;
    FlutterDevToolkit.logger.log(
      '🚀 App cold start time: ${duration}ms',
      level: LogLevel.info,
    );
  }
}
