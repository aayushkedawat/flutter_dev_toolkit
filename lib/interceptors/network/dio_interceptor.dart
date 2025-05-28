import 'package:dio/dio.dart';
import '../../core/logger_interface.dart';
import '../../core/network_log_store.dart';
import '../../flutter_dev_toolkit.dart';
import 'network_log.dart';

class DioNetworkInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now();
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['startTime'] as DateTime?;
    final duration =
        startTime != null
            ? DateTime.now().difference(startTime)
            : Duration.zero;

    final log = NetworkLog(
      method: response.requestOptions.method,
      url: response.requestOptions.uri.toString(),
      duration: duration,
      requestHeaders: response.requestOptions.headers as Map<String, String>?,
      requestBody: response.requestOptions.data,
      statusCode: response.statusCode,
      responseBody: response.data,
    );

    FlutterDevToolkit.logger.log(log.toString());
    NetworkLogStore.add(log);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra['startTime'] as DateTime?;
    final duration =
        startTime != null
            ? DateTime.now().difference(startTime)
            : Duration.zero;

    final log = NetworkLog(
      method: err.requestOptions.method,
      url: err.requestOptions.uri.toString(),
      duration: duration,
      requestHeaders: err.requestOptions.headers as Map<String, String>?,
      requestBody: err.requestOptions.data,
      statusCode: err.response?.statusCode,
      responseBody: err.response?.data,
      isError: true,
    );

    FlutterDevToolkit.logger.log(log.toString(), level: LogLevel.error);
    NetworkLogStore.add(log);
    super.onError(err, handler);
  }
}
