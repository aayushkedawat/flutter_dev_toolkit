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
- **cURL export** — `NetworkLog.toCurl()` renders a captured call as a runnable command, with shell-escaped headers and body. Available as "Copy as cURL" on a request's detail page and "Export as cURL" for the whole list.
- **Startup timing** — the Performance tab reports time from toolkit init to first rendered frame.
- **Jank frame detail** — recent dropped frames are listed with their build and raster split, not just a counter. `DevToolkitConfig.logFrameDrops` (default `false`) additionally writes each one to the Logs tab.
- **Light and dark console themes** — `DevToolkitConfig.theme` picks the starting theme and a toggle in the console app bar switches at runtime.
- **Status filtering in the Network tab** — filter by 2xx/3xx/4xx/5xx or failed, alongside the existing method filter, with a match count.
- **Tag filtering in the Logs tab** — the filter was already applied when building the list, but there was no UI to select a tag until now.
- **State inspection beyond Bloc** — `RecordedStateAdapter` lets an app push state changes in from any framework. Riverpod's `ProviderObserver` and Provider's `ChangeNotifier` each wire up in a few lines, documented on the class, without the toolkit taking on those dependencies.
- **Storage plugin** — view, add, edit and delete `SharedPreferences` entries live from the console, with search and JSON export. Adds `shared_preferences` as a dependency.
- **FPS/memory history sparklines** in the Performance tab — a rolling ~60-sample window rendered as a small line chart, so a dip that only happens during a scroll, or memory that's climbing rather than flat, is visible as a trend instead of only ever showing an instantaneous snapshot.
- **Runtime feature flags** — `FeatureFlagStore.register(FeatureFlag(...))` lets an app expose a boolean, string, number, or fixed-options value that can be flipped from the new Flags tab with no rebuild. Each flag carries its own `ValueNotifier`, so the app reacts the same way it would to any other listenable. Re-registering the same key (safe on every `main()`, including hot reload) returns the existing flag instead of resetting it.

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
- **`init()` threw when called before `runApp()`.** It touched `WidgetsBinding.instance`, which raises "Binding has not yet been initialized" unless the consumer had already called `ensureInitialized()` — something neither the README snippet nor the example app did. `init()` now calls `WidgetsFlutterBinding.ensureInitialized()` itself.
- **The Network tab never updated live.** `NetworkLogStore` was the only store without a change notifier, so captured calls appeared only when something else forced a rebuild, such as typing in the search box. The store now notifies and the tab listens.
- **Any `http` request with a body threw on capture.** `NetworkLog.requestBody` was typed `Map<String, dynamic>?` but `HttpInterceptor` passes `request.body`, a `String`. The field is now `dynamic`, matching what both clients actually hand over.
- `NetworkLogDetailPage` carried its own copy of the `_parseIfJson(String?)` bug, so exporting a Dio-captured call from the detail page threw.
- The Performance tab's frame callback re-armed itself unconditionally and so kept requesting frames for the life of the app after the tab was disposed. It now stops on dispose.
- `ColdStartTimer`, `FrameDropDetector` and `DevConsoleTheme` had shipped since earlier versions as unreachable code — nothing ever called them. All three are now wired up.
- **`PerformanceTab` and `DeviceInfoTab` crashed on web at runtime.** Both referenced `dart:io` (`ProcessInfo`, `Platform`) directly; those members throw `UnsupportedError` the moment they're actually read on web (confirmed by compiling the exact code with `dart compile js` and running the output). `PerformanceTab` already caught its one call, so it only degraded memory reporting to "N/A"; `DeviceInfoTab` did not catch any of its four calls, so opening that tab on a web build threw uncaught. Both now go through conditional-import shims that never touch `dart:io` on web, and Device Info reports real values there via `device_info_plus`'s `WebBrowserInfo`.
- `DeviceInfoTab.getDeviceInfo()` re-runs on every `didChangeDependencies` (e.g. a rotation) but appended to `DeviceInfoLogStore` instead of clearing it first, so the exported device info accumulated duplicate copies of every key over the session.

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
