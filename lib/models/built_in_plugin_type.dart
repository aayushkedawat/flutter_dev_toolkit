/// A toolkit-provided plugin that ships built in, as opposed to one an app
/// registers itself via `FlutterDevToolkit.registerPlugin`.
///
/// Pass a list of these to `DevToolkitConfig.disableBuiltInPlugins` to leave
/// specific tabs out of the console; every value not listed is registered.
enum BuiltInPluginType {
  /// The Logs tab, backed by `DefaultLogger`.
  logs,

  /// The Network tab, backed by `NetworkLogStore` and the http/Dio
  /// interceptors.
  network,

  /// The Routes tab, backed by `RouteInterceptor`.
  routes,

  /// The Device Info tab, backed by `device_info_plus`.
  deviceInfo,

  /// The Crashes tab, backed by `CrashLogStore`.
  crashes,

  /// The Performance tab: FPS, memory, and jank frame tracking.
  performance,

  /// The Deep Links tab, backed by `DeepLinkStore`.
  deepLinks,

  /// The Storage tab: view and edit `SharedPreferences` entries.
  storage,

  /// The Flags tab: view and flip app-registered feature flags.
  featureFlags,
}
