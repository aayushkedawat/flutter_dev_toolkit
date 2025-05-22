class NetworkLog {
  final String method;
  final String url;
  final Map<String, String>? requestHeaders;
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
}
