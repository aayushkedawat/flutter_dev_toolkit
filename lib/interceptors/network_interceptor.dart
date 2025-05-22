import '../flutter_dev_toolkit.dart';

class NetworkInterceptor {
  static void init() {
    FlutterDevToolkit.logger.log(
      'NetworkInterceptor ready. Use HttpInterceptor or DioNetworkInterceptor manually.',
    );
  }
}
