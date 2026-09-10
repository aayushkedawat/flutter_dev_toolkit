import '../flutter_dev_toolkit.dart';

/// Announces that network interception is available. Unlike the other
/// built-in interceptors, capturing calls isn't automatic — wrap a client in
/// `HttpInterceptor` or add `DioNetworkInterceptor()` to a `Dio` instance
/// yourself, since there is no single client to attach to globally.
class NetworkInterceptor {
  /// Logs a one-time notice that network interception is ready. Called once
  /// by `FlutterDevToolkit.init`.
  static void init() {
    FlutterDevToolkit.logger.log(
      'NetworkInterceptor ready. Use HttpInterceptor or DioNetworkInterceptor manually.',
    );
  }
}
