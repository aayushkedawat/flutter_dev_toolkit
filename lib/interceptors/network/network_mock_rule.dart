/// A rule that short-circuits a matching request with a canned response
/// instead of letting it reach the network.
///
/// Matching is deliberately simple — a case-insensitive substring match on
/// the URL, optionally narrowed to one HTTP method — rather than a full
/// pattern language. The first enabled rule that matches wins.
class NetworkMockRule {
  NetworkMockRule({
    required this.urlContains,
    this.method,
    this.statusCode = 200,
    this.responseBody = '',
    this.delay = Duration.zero,
    this.enabled = true,
  });

  /// Case-insensitive substring the request URL must contain. An empty
  /// string never matches — that would otherwise mock every request.
  final String urlContains;

  /// Null matches any method.
  final String? method;

  final int statusCode;
  final String responseBody;
  final Duration delay;
  final bool enabled;

  bool matches(String requestMethod, String url) {
    if (!enabled || urlContains.isEmpty) return false;
    if (method != null &&
        method!.toUpperCase() != requestMethod.toUpperCase()) {
      return false;
    }
    return url.toLowerCase().contains(urlContains.toLowerCase());
  }

  NetworkMockRule copyWith({
    String? urlContains,
    Object? method = _unset,
    int? statusCode,
    String? responseBody,
    Duration? delay,
    bool? enabled,
  }) {
    return NetworkMockRule(
      urlContains: urlContains ?? this.urlContains,
      method: identical(method, _unset) ? this.method : method as String?,
      statusCode: statusCode ?? this.statusCode,
      responseBody: responseBody ?? this.responseBody,
      delay: delay ?? this.delay,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// Sentinel distinguishing "leave [NetworkMockRule.method] alone" from
/// "explicitly set it to null" in [NetworkMockRule.copyWith].
const _unset = Object();
