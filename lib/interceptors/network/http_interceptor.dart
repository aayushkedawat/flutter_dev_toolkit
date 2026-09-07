import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../core/logger_interface.dart';
import '../../core/network_log_store.dart';
import '../../flutter_dev_toolkit.dart';
import 'network_log.dart';
import 'network_mock_store.dart';

class HttpInterceptor extends http.BaseClient {
  final http.Client _inner;

  HttpInterceptor([http.Client? client]) : _inner = client ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    final method = request.method;
    final url = request.url.toString();

    dynamic requestBody;
    if (request is http.Request && request.body.isNotEmpty) {
      requestBody = request.body;
    }

    final mockRule = NetworkMockStore.match(method, url);
    if (mockRule != null) {
      if (mockRule.delay > Duration.zero) {
        await Future.delayed(mockRule.delay);
      }
      stopwatch.stop();

      NetworkLogStore.add(
        NetworkLog(
          method: method,
          url: url,
          duration: stopwatch.elapsed,
          requestHeaders: request.headers,
          requestBody: requestBody,
          statusCode: mockRule.statusCode,
          responseBody: mockRule.responseBody,
          isError: mockRule.statusCode >= 400,
          isMocked: true,
        ),
      );

      final bodyBytes = utf8.encode(mockRule.responseBody);
      return http.StreamedResponse(
        Stream.fromIterable([bodyBytes]),
        mockRule.statusCode,
        contentLength: bodyBytes.length,
        request: request,
        headers: const {'content-type': 'application/json'},
      );
    }

    http.StreamedResponse originalResponse;
    try {
      originalResponse = await _inner.send(request);
    } catch (e) {
      stopwatch.stop(); // Ensure timer stops here too

      final errorLog = NetworkLog(
        method: method,
        url: url,
        duration: stopwatch.elapsed,
        requestHeaders: request.headers,
        requestBody: requestBody,
        statusCode: -1, // Use -1 or a custom code to indicate failure
        responseBody: 'Exception: $e',
        isError: true,
      );

      FlutterDevToolkit.logger.log(
        '[NETWORK] ❌ ERROR $method $url\n  Exception: $e',
        level: LogLevel.error,
      );
      NetworkLogStore.add(errorLog);
      rethrow;
    } finally {
      stopwatch.stop();
    }

    final responseBytes = await originalResponse.stream.toBytes();
    final responseBody = String.fromCharCodes(responseBytes);

    final log = NetworkLog(
      method: method,
      url: url,
      duration: stopwatch.elapsed,
      requestHeaders: request.headers,
      requestBody: requestBody,
      statusCode: originalResponse.statusCode,
      responseBody: responseBody,
      isError: originalResponse.statusCode >= 400,
    );

    NetworkLogStore.add(log);

    return http.StreamedResponse(
      Stream.fromIterable([responseBytes]),
      originalResponse.statusCode,
      contentLength: originalResponse.contentLength,
      request: originalResponse.request,
      headers: originalResponse.headers,
      isRedirect: originalResponse.isRedirect,
      persistentConnection: originalResponse.persistentConnection,
      reasonPhrase: originalResponse.reasonPhrase,
    );
  }
}
