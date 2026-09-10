/// Always `false` on web — there is no Android to detect.
bool get isAndroid => false;

/// Always `false` on web — there is no iOS to detect.
bool get isIOS => false;

/// Always `'web'`, since `dart:io`'s `Platform.operatingSystem` isn't
/// available there.
String get operatingSystem => 'web';

/// Always empty on web — no OS version to report.
String get operatingSystemVersion => '';
