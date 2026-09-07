class DeepLinkEntry {
  final String uri;
  final Map<String, String> queryParams;
  final String? pathFragment;
  final DateTime receivedAt;
  final String? source;

  DeepLinkEntry({required this.uri, DateTime? receivedAt, this.source})
    : receivedAt = receivedAt ?? DateTime.now(),
      queryParams = Uri.tryParse(uri)?.queryParameters ?? const {},
      pathFragment =
          Uri.tryParse(uri)?.fragment.isNotEmpty == true
              ? Uri.tryParse(uri)?.fragment
              : null;

  Map<String, dynamic> toJson() => {
    'uri': uri,
    'queryParams': queryParams,
    'pathFragment': pathFragment,
    'receivedAt': receivedAt.toIso8601String(),
    if (source != null) 'source': source,
  };
}
