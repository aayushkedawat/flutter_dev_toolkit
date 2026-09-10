import 'dart:io';

/// Whether the app is running on Android.
bool get isAndroid => Platform.isAndroid;

/// Whether the app is running on iOS.
bool get isIOS => Platform.isIOS;

/// The host operating system's name (e.g. `'android'`, `'ios'`).
String get operatingSystem => Platform.operatingSystem;

/// The host operating system's version string.
String get operatingSystemVersion => Platform.operatingSystemVersion;
