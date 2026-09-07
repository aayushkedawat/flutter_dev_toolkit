# CLAUDE.md — Flutter Dev Toolkit

This file provides guidance for AI assistants working on this codebase.

---

## Project Overview

**Flutter Dev Toolkit** is a modular, in-app developer console for Flutter applications. It provides a floating overlay UI with real-time monitoring: logs, network requests, route history, device info, crashes, performance metrics, deep links, and state inspection. It is published as a pub.dev package (`flutter_dev_toolkit`, version 1.4.0).

---

## Repository Structure

```
flutter_dev_toolkit/
├── .github/workflows/ci.yml         # Format, analyze, test, publish dry-run
├── analysis_options.yaml            # Enables flutter_lints
├── lib/
│   ├── flutter_dev_toolkit.dart     # Public API surface, singleton facade, crash hooks
│   ├── core/                        # Config, logger, stores, theme, share helpers
│   ├── models/                      # LogEntry, LogTag, BuiltInPluginType, RouteEntry,
│   │                                #   CrashEntry, DeepLinkEntry
│   ├── interceptors/                # Route, lifecycle, deep link, network interception
│   │   ├── network/                 # http and Dio interceptors + NetworkLog (JSON/HAR)
│   │   └── performance/             # ColdStartTimer, FrameDropDetector
│   ├── built_in_plugins/            # Logs, Network, Routes, DeviceInfo, Crash,
│   │   │                            #   Performance, DeepLink plugins
│   │   └── widgets/                 # One tab widget per plugin
│   ├── plugins/                     # Custom plugin framework + AppStateInspector
│   │   ├── state_inspector/         # AppStateInspectorPlugin, adapters, BlocTracker
│   │   └── adapters/                # BlocAdapter
│   └── ui/                          # LogOverlay (FAB), LogConsole (tabs),
│                                    #   NetworkLogDetailPage, tab sync
├── example/                         # Runnable demo app
│   └── lib/
│       ├── main.dart                # Toolkit init, MaterialApp setup
│       ├── home_page.dart           # Logging/networking/navigation triggers
│       └── details_page.dart
├── test/
│   └── flutter_dev_toolkit_test.dart  # Unit tests for logger, stores, config, export
├── pubspec.yaml
├── CHANGELOG.md
└── README.md
```

---

## Architecture

### Core Design Patterns

| Pattern | Where Used |
|---------|-----------|
| Singleton | `FlutterDevToolkit` global state (logger, config, plugins) |
| Plugin Architecture | `DevToolkitPlugin` abstract base; all panels are plugins |
| Observer | `WidgetsBindingObserver` (lifecycle), `RouteObserver` (navigation), `BlocObserver` (state) |
| Adapter | `AppStateAdapter` decouples state frameworks from inspector UI |
| Registry | `PluginRegistry` manages plugin list; `InterceptorRegistry` for network/route interceptors |
| ValueNotifier | Drives reactive UI without full BLoC overhead |

### Initialization Flow

```dart
FlutterDevToolkit.init(config: DevToolkitConfig(...));
// → returns early with a no-op logger if kReleaseMode && !config.enableInRelease
// → calls WidgetsFlutterBinding.ensureInitialized(), since init() normally
//   runs before runApp() and everything below needs the binding
// → starts ColdStartTimer (stops on the first post-frame callback)
// → installs the config's logger and applies retention caps
//   (config.maxLogEntries → DefaultLogger, config.maxNetworkLogs → NetworkLogStore)
// → installs FlutterError.onError / PlatformDispatcher.onError crash hooks
// → registers route and network interceptors (unless disabled)
// → attaches WidgetsBindingObserver, starts LifecycleInterceptor
// → registers every built-in plugin NOT listed in config.disableBuiltInPlugins,
//   then calls onInit() on each registered plugin
```

Built-in plugins are **opt-out**, not opt-in: `DevToolkitConfig.disableBuiltInPlugins`
takes the `BuiltInPluginType` values to leave out. An empty list (the default)
registers all of them.

`init()` chains to any pre-existing `FlutterError.onError`. Consumers who install
their own handler afterwards must chain to the previous one, or crash capture
stops silently — `example/lib/main.dart` demonstrates the correct pattern.

### Overlay Entry Point

`LogOverlay` (a FloatingActionButton) wraps the app via `DevOverlay` widget. It opens `LogConsole`, which renders tabs for each registered plugin.

### Plugin Lifecycle

Every plugin extends `DevToolkitPlugin` and can override:
- `onPause()` / `onResume()` — called when the app goes to background/foreground
- `build(BuildContext)` — returns the plugin's tab widget
- `icon`, `label` — used for the tab bar

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/flutter_dev_toolkit.dart` | Entry point; `init()`, `registerPlugin()`, plugin list, crash hooks |
| `lib/core/dev_toolkit_config.dart` | `DevToolkitConfig` — plugin opt-outs, release gating, retention caps, theme |
| `lib/core/dev_console_theme.dart` | `DevConsoleTheme`, `DevConsolePalette`, and the `palette` shorthand console widgets paint with |
| `lib/core/dev_toolkit_plugin.dart` | Abstract `DevToolkitPlugin` base class |
| `lib/core/default_logger.dart` | Log buffer; cap from the constructor, else `config.maxLogEntries` (default 2000) |
| `lib/core/network_log_store.dart` | Network log buffer; cap from `config.maxNetworkLogs` (default 500) |
| `lib/interceptors/performance/cold_start_timer.dart` | Times toolkit init → first frame; started by `init()` |
| `lib/interceptors/performance/frame_drop_detector.dart` | The single jank source; the Performance tab reads it |
| `lib/plugins/state_inspector/recorded_state_adapter.dart` | `RecordedStateAdapter` for pushing in Riverpod/Provider/etc. state |
| `lib/core/crash_log_store.dart` | Crash buffer, hard-capped at 200 entries |
| `lib/core/deep_link_store.dart` | Deep link buffer, hard-capped at 200 entries |
| `lib/interceptors/route_interceptor.dart` | NavigatorObserver tracking stack and history with durations |
| `lib/interceptors/network/http_interceptor.dart` | Wraps `http.BaseClient` |
| `lib/interceptors/network/dio_interceptor.dart` | Extends Dio `Interceptor` |
| `lib/interceptors/network/network_log.dart` | Network record + JSON and HAR 1.2 serialization |
| `lib/built_in_plugins/logs_plugin.dart` | Logs tab: filter by level and tag, export, clear |
| `lib/built_in_plugins/network_plugin.dart` | Network tab: request replay, JSON and HAR export |
| `lib/built_in_plugins/crash_plugin.dart` | Crashes tab: captured errors with stack traces |
| `lib/built_in_plugins/performance_plugin.dart` | Performance tab: FPS, RSS memory, jank frames |
| `lib/built_in_plugins/deep_link_plugin.dart` | Deep links tab: URI and query parameter inspector |
| `lib/plugins/state_inspector/app_state_inspector_plugin.dart` | State inspector with split layout |
| `lib/plugins/adapters/bloc_adapter.dart` | `BlocAdapter` wires BlocObserver into state inspector |
| `lib/ui/log_overlay.dart` | Draggable floating overlay toggle (FAB) with error badge |
| `lib/ui/log_console.dart` | Full-screen console with tab controller |

---

## Development Workflows

### Setup

```bash
flutter pub get
```

### Run the Example App

```bash
cd example
flutter pub get
flutter run
```

### Analyze Code

```bash
flutter analyze
```

### Format Code

```bash
dart format lib/
dart format example/lib/
```

### Run Tests

```bash
flutter test
```

`test/flutter_dev_toolkit_test.dart` covers the logic that can be unit tested
without a device: logger retention, store caps, `init()` config wiring, and the
JSON/HAR export paths. Widget-level behaviour is not yet covered. When adding
features, add corresponding tests in `test/`.

### Validate the Package Before Publishing

```bash
flutter pub publish --dry-run
```

### CI

`.github/workflows/ci.yml` runs on every push to `main` and every pull request:
`dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`, and
`flutter pub publish --dry-run` for the package, plus `flutter analyze` for the
example app. Run the same commands locally before committing — `flutter analyze`
fails on `info`-level lints, so a stray unused import will break the build.

---

## Dependencies

| Package | Version Range | Use |
|---------|--------------|-----|
| `flutter_bloc` / `bloc` | `^8.0.0 <10.0.0` | State inspection (optional integration) |
| `dio` | `^5.2.0 <6.0.0` | Network interception for Dio users |
| `http` | `^0.13.0 <2.0.0` | Network interception for http package users |
| `device_info_plus` | `^11.4.0 <=12.0.0` | Device info panel |
| `share_plus` | `^11.0.0 <=12.0.0` | Log/network export via share sheet |
| `intl` | `^0.19.0 <=0.30.0` | Timestamp formatting |

**Important**: No `pubspec.lock` is committed — this is a library (pub.dev best practice). Version constraints intentionally broad for consumer compatibility.

---

## Code Conventions

### Naming
- Classes: `PascalCase` — `LogsPlugin`, `HttpInterceptor`, `DevToolkitConfig`
- Methods / variables: `camelCase`
- Private members: leading underscore `_privateField`
- Enum values: `camelCase` — `LogTag.network`, `BuiltInPluginType.logs`

### Style Rules
- **Null safety** throughout (Dart `^3.7.0`)
- Prefer `async`/`await` over raw `Future` chains
- Use `ValueNotifier` for simple reactive state; avoid introducing new BLoC dependencies in core
- Functional collection methods: `.map()`, `.where()`, `.toList()`
- `switch` expressions (Dart 3) preferred over `if-else` chains for enum dispatch

### Error Handling
- Network operations wrapped in `try/catch`; errors logged via `FlutterDevToolkit.logger`
- No silent catches — always log or rethrow
- UI destructive actions (clear logs, clear network) require `showDialog` confirmation

### Plugin Development
When adding a new built-in plugin:
1. Add its type to `BuiltInPluginType` enum in `lib/models/built_in_plugin_type.dart`
2. Create the plugin class in `lib/built_in_plugins/` extending `DevToolkitPlugin`
3. Create a corresponding widget in `lib/built_in_plugins/widgets/`
4. Register it in `lib/core/plugin_registry.dart` via `tryAdd(...)`, so it can be
   switched off through `DevToolkitConfig.disableBuiltInPlugins`
5. If it needs an interceptor, wire that up in `lib/interceptors/interceptor_registry.dart`
   behind the same `BuiltInPluginType` check

When adding a custom plugin (consumer-facing):
- Extend `DevToolkitPlugin` directly
- Call `FlutterDevToolkit.registerPlugin(myPlugin)` after `init()`

---

## Important Constraints

- **Do not add the root `pubspec.lock` to source control** — this is a library package.
- **Do not introduce breaking changes without a major version bump** — this is a published package with consumers.
- **Maintain broad version constraints** on dependencies to avoid consumer conflicts. Verify constraint ranges before tightening.
- **Update `CHANGELOG.md` whenever `pubspec.yaml`'s version changes** — `pub publish` (and CI's dry-run) fails if the changelog does not mention the current version.
- **The Actions tab is gone** (removed in 1.3.0, files deleted in 1.4.0). Export and clear actions live in individual plugins.
- **`flutter analyze` must be clean** — `analysis_options.yaml` enables `flutter_lints`, and the analyzer treats `info`-level lints as failures in CI.
- **Platform channels** are not used directly; all platform access goes through `device_info_plus`.
- **Crash hooks are global.** `init()` replaces `FlutterError.onError` and `PlatformDispatcher.onError`, chaining to whatever was there. Anything installed after `init()` must chain too.
- **Every store needs a change notifier.** Tabs render from static stores, so a store without a `ValueNotifier` leaves its tab frozen until something else forces a rebuild. `NetworkLogStore` shipped that way and the Network tab did not update live.
- **Console widgets paint with `palette`, not hardcoded `Colors.white*`.** The top-level `palette` getter in `dev_console_theme.dart` resolves the active theme; using literal colors breaks light mode. Note that a `palette.x` lookup is not a constant, so the enclosing widget cannot be `const`.
- **Do not add state-management dependencies** (riverpod, provider, …) to observe them. `RecordedStateAdapter` lets consumers push changes in from any framework instead.

---

## Branch & Commit Guidelines

- Main branch: `main`
- Feature work happens on a branch; push with `git push -u origin <branch-name>`
- Commit messages: imperative mood, concise, e.g. `Add network replay feature` not `Added...`
- Push with: `git push -u origin <branch-name>`

---

## Common Tasks

### Add a Log Entry (from consumer app)
```dart
FlutterDevToolkit.logger.log(
  'message',
  level: LogLevel.info,
  tags: {LogTag.custom}, // a Set, not a single tag
);
```

### Intercept Dio Network Calls
```dart
dio.interceptors.add(DioNetworkInterceptor());
```

### Intercept http Network Calls
```dart
final client = HttpInterceptor(); // wraps http.Client() by default
```

### Register a Route Observer
```dart
MaterialApp(
  navigatorObservers: [RouteInterceptor.instance],
)
```

### Add the Overlay to an App

`DevOverlay` takes no child — it is stacked on top of the app in
`MaterialApp.builder`:

```dart
MaterialApp(
  builder: (context, child) => Stack(
    children: [child!, const DevOverlay()],
  ),
)
```
