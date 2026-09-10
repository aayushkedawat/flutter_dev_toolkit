/// One deep link recorded via `DevToolkitDeepLinkObserver.onLinkReceived`,
/// with its URI already parsed into query parameters and a path fragment.
class DeepLinkEntry {
  /// The raw URI string as received.
  final String uri;

  /// [uri]'s query parameters, parsed eagerly. Empty if [uri] fails to parse
  /// or carries none.
  final Map<String, String> queryParams;

  /// [uri]'s fragment (the part after `#`), or `null` if absent or [uri]
  /// fails to parse.
  final String? pathFragment;

  /// When this link was received. Defaults to [DateTime.now] if omitted.
  final DateTime receivedAt;

  /// Free-form label for where the link came from (e.g. `'push'`,
  /// `'universal_link'`), shown in the detail view when present.
  final String? source;

  /// Creates a deep link entry, parsing [uri] into [queryParams] and
  /// [pathFragment].
  DeepLinkEntry({required this.uri, DateTime? receivedAt, this.source})
    : receivedAt = receivedAt ?? DateTime.now(),
      queryParams = Uri.tryParse(uri)?.queryParameters ?? const {},
      pathFragment =
          Uri.tryParse(uri)?.fragment.isNotEmpty == true
              ? Uri.tryParse(uri)?.fragment
              : null;

  /// Serializes this entry for export (e.g. copy-as-JSON in the detail view).
  Map<String, dynamic> toJson() => {
    'uri': uri,
    'queryParams': queryParams,
    'pathFragment': pathFragment,
    'receivedAt': receivedAt.toIso8601String(),
    if (source != null) 'source': source,
  };
}
