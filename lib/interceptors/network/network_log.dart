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

  NetworkLog({
    required this.method,
    required this.url,
    this.requestHeaders,
    this.requestBody,
    this.statusCode,
    this.responseBody,
    required this.duration,
    this.isError = false,
  });

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

  dynamic _parseIfJson(String? input) {
    if (input == null) return null;

    try {
      return json.decode(input);
    } catch (_) {
      return input; // return as-is if not valid JSON
    }
  }
}
