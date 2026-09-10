import 'package:dio/dio.dart';
import '../../core/logger_interface.dart';
import '../../core/network_log_store.dart';
import '../../flutter_dev_toolkit.dart';
import 'network_log.dart';
import 'network_mock_store.dart';

/// Records every request/response/error passing through a `Dio` instance
/// into [NetworkLogStore], and honors [NetworkMockStore] rules before a
/// request reaches the network.
///
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(DioNetworkInterceptor());
/// ```
class DioNetworkInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final url = options.uri.toString();
    final mockRule = NetworkMockStore.match(options.method, url);

    if (mockRule != null) {
      void resolve() {
        NetworkLogStore.add(
          NetworkLog(
            method: options.method,
            url: url,
            duration: mockRule.delay,
            requestHeaders: options.headers,
            requestBody: options.data,
            statusCode: mockRule.statusCode,
            responseBody: mockRule.responseBody,
            isError: mockRule.statusCode >= 400,
            isMocked: true,
          ),
        );
        // resolve() rather than next() skips the real request entirely —
        // this interceptor's own onResponse never runs for it, so the log
        // above is the only one written for this call.
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: mockRule.statusCode,
            data: mockRule.responseBody,
          ),
        );
      }

      if (mockRule.delay > Duration.zero) {
        Future.delayed(mockRule.delay, resolve);
      } else {
        resolve();
      }
      return;
    }

    options.extra['startTime'] = DateTime.now();
    return handler.next(options);
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
      requestHeaders: response.requestOptions.headers,
      requestBody: response.requestOptions.data,
      statusCode: response.statusCode,
      responseBody: response.data,
    );

    FlutterDevToolkit.logger.log(log.toString());
    NetworkLogStore.add(log);
    return handler.next(response);
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
      requestHeaders: err.requestOptions.headers,
      requestBody: err.requestOptions.data,
      statusCode: err.response?.statusCode,
      responseBody: err.response?.data,
      isError: true,
    );

    FlutterDevToolkit.logger.log(log.toString(), level: LogLevel.error);
    NetworkLogStore.add(log);
    return handler.next(err);
  }
}
