## 1.4.0

### ✨ Features
- **Crashes plugin** — captures Flutter framework errors (`FlutterError.onError`) and unhandled async errors (`PlatformDispatcher.onError`) with full stack traces, marking the latter as fatal.
- **Performance plugin** — live FPS, resident memory (RSS), and jank-frame counters driven by `SchedulerBinding` frame callbacks and timings.
- **Deep Links plugin** — records incoming deep links via `DevToolkitDeepLinkObserver`, with URI parsing, a query-parameter inspector, and JSON export.
- **HAR 1.2 export** for captured network calls (`NetworkLog.toHarDocument`) — importable into Chrome DevTools, Postman, and Charles Proxy.
- Response-time colour badges on network entries (green < 200 ms, orange < 1 s, red ≥ 1 s) and a "clear network logs" action.
- Draggable floating action button, with a badge showing the session error count.
- `DevToolkitConfig.enableInRelease` (default `false`) suppresses the overlay in release builds and installs a no-op logger so consumer `logger` calls stay safe in production.
- `DevToolkitConfig.maxLogEntries` and `DevToolkitConfig.maxNetworkLogs` make retention limits configurable.

### 🐛 Fixes
- Fixed a compile error in `PerformanceTab`, which referenced an undefined `FrameTimingCallback` type. The package did not analyze or build before this fix.
- Fixed an invalid override: the release-mode no-op logger declared `List<dynamic> get logEntries` where `LoggerInterface` requires `List<LogEntry>`.
- `DevToolkitConfig.maxLogEntries` is now actually applied. It was previously read by nothing, so log retention was always the `DefaultLogger` default. A cap passed directly to `DefaultLogger(maxEntries:)` still wins.
- `NetworkLog.toJson()` no longer throws a `TypeError` when the response body was already decoded. Dio hands back `Map`s and `List`s, which the JSON/HAR export path assumed were `String`s.
- `DeviceInfoTab` no longer touches its `BuildContext` across an async gap without a `mounted` guard.
- Removed an unused import in `log_overlay.dart`.
- **App State Inspector now updates live.** The tab had no listener on the Bloc observer, so it only refreshed when rebuilt for some other reason — state changes appeared to stop arriving. `AppStateAdapter` gained a `revision` `Listenable` that the inspector rebuilds on.
- **The Bloc inspector now shows the previous state.** `DevBlocObserver` discarded `change.currentState`, so every entry recorded only the new state despite the UI being presented as a transition view.
- `DevBlocObserver` retained transitions without any limit — the only unbounded store in the toolkit. It is now capped at 500 entries and exposes `clear()`.
- The inspector's selected entry was tracked by list index into a newest-first list, so incoming state changes silently moved the selection to a different entry. It is now tracked by identity.
- Fixed route stack corruption when the same route appears on the stack twice (A → B → A): exit tracking removed the *first* matching entry, leaving the stack reordered as `[B, A]` and discarding the still-open route's entry time. Durations under a second now report in milliseconds instead of `0s`.
- The "clear route info" dialog promised to clear the stack, which it never did (and should not — those screens are still open). The copy now matches the behaviour.

### 📦 Housekeeping
- Removed the deprecated Actions plugin and tab (fully commented out since 1.3.0) and its stale screenshot.
- Enabled `flutter_lints`: `analysis_options.yaml` was empty, so the linter never ran. `flutter analyze` is now clean for both the package and the example app.
- Added a unit test suite covering logger retention, store caps, config wiring, and JSON/HAR export. The test file was previously empty.
- Added GitHub Actions CI running format, analyze, test, and `pub publish --dry-run` on pushes and pull requests.
- The example app no longer replaces the toolkit's `FlutterError.onError` handler, which silently disabled crash capture; it now chains to the previous handler.
- The example app now has triggers for every tab — logging at each level, a successful and a failing request, a reported Flutter error, an unhandled async error, a jank burst, and a simulated deep link — so the 1.4.0 panels can actually be exercised.

## 1.3.2

- Updated Changelog

## 1.3.1

- Updated Dependencies

## 1.3.0

### ✨ Features
- Added more information in Device Info.

### 🐛 Fixes
- UI update of logs.
- Dio Interceptor fixes.
- Added more information in Device Info.
## 1.2.0

### ✨ Features
- Introduced plugin registry with `BuiltInPluginType` enum for cleaner plugin control.
- Removed legacy flags (`enableRouteInterceptor`, `enableNetworkInterceptor`, `enableLifecycleInterceptor`).
- Built-in plugins now registered via enum-based `disableBuiltInPlugins`.
- Modular plugin architecture for Logs, Network, Routes, Device Info.
- Each plugin can define its own export and clear actions.
- Export and clear buttons now come with confirmation dialogs and clipboard/share support.
- Plugin-specific app bars with actions and optional config panels.
- Added proper lifecycle handling (`onPause`, `onResume`) in plugins.
- Active plugin state synced with tab selection on open/close.

### 🐛 Fixes
- Fixed bug where plugin state was not updated on overlay reopen.
- Fixed default tab and plugin mismatch on initial open.
- UI updates now reflect after clearing logs or routes.

### 📦 Housekeeping
- Updated README to reflect new plugin management approach.
- Deprecated old config flags in favor of enum-driven `disableBuiltInPlugins`.

## 1.1.2
- Minor Fixes

## 1.1.1
- Minor Fixes

## 1.1.0
### Added
- 🚀 New App State Inspector tab
- 🎯 Bloc state tracking via DevBlocObserver
- 💡 Pretty JSON formatting + state timestamp
- 🧠 Responsive layout (split for desktop, expansion on mobile)
- 🪄 Copy state to clipboard
- 🎛 Framework adapter system with dropdown support

## 1.0.0
- Initial release with Logs, Network, Routes, Performance
- Plugin system and built-in plugins
- Error handling and DevOverlay
