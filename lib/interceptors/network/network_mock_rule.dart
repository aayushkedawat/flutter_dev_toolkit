/// A rule that short-circuits a matching request with a canned response
/// instead of letting it reach the network.
///
/// Matching is deliberately simple — a case-insensitive substring match on
/// the URL, optionally narrowed to one HTTP method — rather than a full
/// pattern language. The first enabled rule that matches wins.
class NetworkMockRule {
  /// Creates a mock rule. Only [urlContains] is required — every other
  /// field defaults to a plain `200 OK` with an empty body.
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

  /// Status code the mocked response reports.
  final int statusCode;

  /// Body the mocked response returns.
  final String responseBody;

  /// Artificial delay before the mocked response resolves, simulating
  /// network latency.
  final Duration delay;

  /// Whether this rule is checked at all. A disabled rule never matches,
  /// letting the config panel toggle a rule off without deleting it.
  final bool enabled;

  /// Whether this rule applies to a request with [requestMethod] and [url].
  bool matches(String requestMethod, String url) {
    if (!enabled || urlContains.isEmpty) return false;
    if (method != null &&
        method!.toUpperCase() != requestMethod.toUpperCase()) {
      return false;
    }
    return url.toLowerCase().contains(urlContains.toLowerCase());
  }

  /// Returns a copy with the given fields replaced. Pass `method: null`
  /// explicitly to clear it — omitting it keeps the current value, thanks to
  /// the internal [_unset] sentinel.
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
