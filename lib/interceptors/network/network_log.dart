import 'dart:convert';

/// One captured network call, recorded by `HttpInterceptor` or
/// `DioNetworkInterceptor` and rendered by the Network tab.
class NetworkLog {
  /// The HTTP method (`'GET'`, `'POST'`, …).
  final String method;

  /// The request URL, as a string.
  final String url;

  /// The outgoing request's headers, if any were captured.
  final Map<String, dynamic>? requestHeaders;

  /// The outgoing body, in whatever shape the client handed over: Dio gives a
  /// Map, a List or FormData, while the http client gives an encoded String.
  /// Typing this as a Map made any http request with a body throw.
  final dynamic requestBody;

  /// The response's HTTP status code, or `null`/negative for a call that
  /// never got one (e.g. it threw before a response arrived).
  final int? statusCode;

  /// The response body, in whatever shape the client handed over — a
  /// decoded `Map`/`List` from Dio, or a raw `String` from the http client.
  final dynamic responseBody;

  /// How long the call took, end to end.
  final Duration duration;

  /// True for a non-2xx response or a call that threw.
  final bool isError;

  /// When the call was made. Defaults to [DateTime.now] if omitted.
  final DateTime startedAt;

  /// True when this call was short-circuited by a mock rule instead of
  /// reaching the network.
  final bool isMocked;

  /// Creates a network log entry.
  NetworkLog({
    required this.method,
    required this.url,
    this.requestHeaders,
    this.requestBody,
    this.statusCode,
    this.responseBody,
    required this.duration,
    this.isError = false,
    this.isMocked = false,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  /// The response's status class: 2 for any 2xx, 4 for any 4xx, and so on.
  ///
  /// Null when the call never got a usable status — either no response at all,
  /// or the sentinel `HttpInterceptor` records when the request threw.
  int? get statusGroup {
    final code = statusCode;
    if (code == null || code < 100) return null;
    return code ~/ 100;
  }

  /// Serializes this call for export (e.g. copy-as-JSON in the Network tab).
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
      'isMocked': isMocked,
    };
  }

  /// Renders this call as a runnable `curl` command.
  ///
  /// Header values and the body are single-quote escaped, so the output can be
  /// pasted into a POSIX shell as-is.
  String toCurl() {
    final parts = <String>['curl'];

    if (method.toUpperCase() != 'GET') {
      parts.add('-X ${method.toUpperCase()}');
    }

    requestHeaders?.forEach((key, value) {
      parts.add("-H '${_shellEscape('$key: $value')}'");
    });

    if (requestBody != null) {
      final body =
          requestBody is String
              ? requestBody as String
              : json.encode(requestBody);
      parts.add("--data '${_shellEscape(body)}'");
    }

    parts.add("'${_shellEscape(url)}'");

    return parts.join(' ');
  }

  /// Ends the quoted run, adds an escaped quote, and reopens it — the standard
  /// way to get a literal `'` inside a single-quoted shell string.
  static String _shellEscape(String value) => value.replaceAll("'", r"'\''");

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
              responseBody is String ? responseBody : json.encode(responseBody),
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

  /// Decodes [input] when it is a JSON string, and passes anything else
  /// through untouched. Dio hands back already-decoded Maps and Lists, so this
  /// must not assume a String.
  dynamic _parseIfJson(dynamic input) {
    if (input is! String) return input;
    try {
      return json.decode(input);
    } catch (_) {
      return input;
    }
  }

  String _statusText(int? code) {
    if (code == null) return '';
    const texts = {
      200: 'OK',
      201: 'Created',
      204: 'No Content',
      301: 'Moved Permanently',
      302: 'Found',
      304: 'Not Modified',
      400: 'Bad Request',
      401: 'Unauthorized',
      403: 'Forbidden',
      404: 'Not Found',
      405: 'Method Not Allowed',
      408: 'Request Timeout',
      422: 'Unprocessable Entity',
      429: 'Too Many Requests',
      500: 'Internal Server Error',
      502: 'Bad Gateway',
      503: 'Service Unavailable',
      504: 'Gateway Timeout',
    };
    return texts[code] ?? '';
  }
}
