import 'dart:convert';

class NetworkLog {
  final String method;
  final String url;
  final Map<String, dynamic>? requestHeaders;
  final Map<String, dynamic>? requestBody;
  final int? statusCode;
  final dynamic responseBody;
  final Duration duration;
  final bool isError;
  final DateTime startedAt;

  NetworkLog({
    required this.method,
    required this.url,
    this.requestHeaders,
    this.requestBody,
    this.statusCode,
    this.responseBody,
    required this.duration,
    this.isError = false,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'url': url,
      'requestHeaders': requestHeaders,
      'requestBody': requestBody,
      'statusCode': statusCode,
      'responseBody': _parseIfJson(responseBody),
      'duration': duration.inMilliseconds,
      'isError': isError,
    };
  }

  /// Serializes this log as an HAR (HTTP Archive 1.2) entry map.
  /// Pass a list of these to [NetworkLog.toHarDocument] to get a full HAR file.
  Map<String, dynamic> toHarEntry() {
    final uri = Uri.tryParse(url);
    final queryString =
        uri?.queryParameters.entries
            .map((e) => {'name': e.key, 'value': e.value})
            .toList() ??
        [];

    final reqHeaders =
        requestHeaders?.entries
            .map((e) => {'name': e.key, 'value': e.value.toString()})
            .toList() ??
        [];

    return {
      'startedDateTime': startedAt.toUtc().toIso8601String(),
      'time': duration.inMilliseconds,
      'request': {
        'method': method,
        'url': url,
        'httpVersion': 'HTTP/1.1',
        'headers': reqHeaders,
        'queryString': queryString,
        'postData':
            requestBody != null
                ? {
                  'mimeType': 'application/json',
                  'text': json.encode(requestBody),
                }
                : null,
        'headersSize': -1,
        'bodySize': -1,
      },
      'response': {
        'status': statusCode ?? 0,
        'statusText': _statusText(statusCode),
        'httpVersion': 'HTTP/1.1',
        'headers': <Map<String, String>>[],
        'content': {
          'size': -1,
          'mimeType': 'application/json',
          'text':
              responseBody is String
                  ? responseBody
                  : json.encode(responseBody),
        },
        'redirectURL': '',
        'headersSize': -1,
        'bodySize': -1,
      },
      'cache': <String, dynamic>{},
      'timings': {'send': 0, 'wait': duration.inMilliseconds, 'receive': 0},
    };
  }

  /// Wraps a list of [NetworkLog] entries into a complete HAR document string.
  static String toHarDocument(List<NetworkLog> logs) {
    final har = {
      'log': {
        'version': '1.2',
        'creator': {'name': 'Flutter Dev Toolkit', 'version': '1.4.0'},
        'entries': logs.map((l) => l.toHarEntry()).toList(),
      },
    };
    return const JsonEncoder.withIndent('  ').convert(har);
  }

  dynamic _parseIfJson(String? input) {
    if (input == null) return null;
    try {
      return json.decode(input);
    } catch (_) {
      return input;
    }
  }

  String _statusText(int? code) {
    if (code == null) return '';
    const texts = {
      200: 'OK', 201: 'Created', 204: 'No Content', 301: 'Moved Permanently',
      302: 'Found', 304: 'Not Modified', 400: 'Bad Request',
      401: 'Unauthorized', 403: 'Forbidden', 404: 'Not Found',
      405: 'Method Not Allowed', 408: 'Request Timeout',
      422: 'Unprocessable Entity', 429: 'Too Many Requests',
      500: 'Internal Server Error', 502: 'Bad Gateway',
      503: 'Service Unavailable', 504: 'Gateway Timeout',
    };
    return texts[code] ?? '';
  }
}
