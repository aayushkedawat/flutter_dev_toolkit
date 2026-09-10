import '../models/built_in_plugin_type.dart';
import 'dev_console_theme.dart';
import 'logger_interface.dart';

/// Configuration passed to `FlutterDevToolkit.init`, controlling which
/// built-in plugins run, retention limits, and the console's starting look.
class DevToolkitConfig {
  /// Where `FlutterDevToolkit.logger.log` calls end up. Pass `DefaultLogger`
  /// for the built-in in-memory buffer, or a custom [LoggerInterface] to
  /// forward entries elsewhere (e.g. to a remote log service) as well.
  final LoggerInterface logger;

  /// Built-in plugin types to leave out of the console. Built-in plugins are
  /// opt-out, so an empty list (the default) registers all of them.
  final List<BuiltInPluginType> disableBuiltInPlugins;

  /// Whether the toolkit overlay and plugins should be active in release builds.
  /// Defaults to false — the overlay is suppressed in release mode unless
  /// explicitly opted in. Always set to false before publishing to production.
  final bool enableInRelease;

  /// Maximum number of log entries retained in memory. Oldest entries are
  /// dropped when the limit is exceeded. Defaults to 2000.
  final int maxLogEntries;

  /// Maximum number of network log entries retained in memory. Defaults to 500.
  final int maxNetworkLogs;

  /// Whether every dropped frame is also written to the Logs tab. Off by
  /// default — jank frames are common during scrolling and would drown out
  /// everything else. The Performance tab shows the counts either way.
  final bool logFrameDrops;

  /// The console's starting theme. Users can flip it at runtime from the
  /// console app bar; this only sets what it opens with.
  final DevConsoleTheme theme;

  /// Creates a config. Only [logger] is required — every other field has a
  /// default matching the toolkit's out-of-the-box behavior.
  const DevToolkitConfig({
    required this.logger,
    this.disableBuiltInPlugins = const [],
    this.enableInRelease = false,
    this.maxLogEntries = 2000,
    this.maxNetworkLogs = 500,
    this.logFrameDrops = false,
    this.theme = DevConsoleTheme.dark,
  });
}
