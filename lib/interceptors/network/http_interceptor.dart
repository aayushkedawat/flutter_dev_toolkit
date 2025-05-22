import 'package:http/http.dart' as http;
import '../../core/network_log_store.dart';
import '../../flutter_dev_toolkit.dart';
import 'network_log.dart';

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

    http.StreamedResponse response;
    try {
      response = await _inner.send(request);
    } catch (e) {
      FlutterDevToolkit.logger.log(
        '[NETWORK] ❌ ERROR $method $url\n  Exception: $e',
        level: LogLevel.error,
      );

      rethrow;
    } finally {
      stopwatch.stop();
    }
    final responseBody =
        await response.stream.bytesToString(); // ✅ consume stream here

    final log = NetworkLog(
      method: method,
      url: url,
      duration: stopwatch.elapsed,
      requestHeaders: request.headers,
      requestBody: requestBody,
      statusCode: response.statusCode,
      responseBody: responseBody,
      isError: response.statusCode >= 400,
    );

    FlutterDevToolkit.logger.log(
      log.toString(),
      level: log.isError ? LogLevel.error : LogLevel.info,
    );
    NetworkLogStore.add(log);
    return response;
  }
}
