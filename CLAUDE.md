# CLAUDE.md — Flutter Dev Toolkit

This file provides guidance for AI assistants working on this codebase.

---

## Project Overview

**Flutter Dev Toolkit** is a modular, in-app developer console for Flutter applications. It provides a floating overlay UI with real-time monitoring: logs, network requests, route history, device info, and state inspection. It is published as a pub.dev package (`flutter_dev_toolkit`, version 1.3.2).

---

## Repository Structure

```
flutter_dev_toolkit/
├── lib/
│   ├── flutter_dev_toolkit.dart     # Public API surface & singleton facade
│   ├── core/                        # Config, logger, stores, theme
│   ├── models/                      # LogEntry, LogTag, BuiltInPluginType, RouteEntry
│   ├── interceptors/                # Route, lifecycle, network interception
│   │   └── network/                 # http and Dio interceptor implementations
│   ├── built_in_plugins/            # Logs, Network, Routes, DeviceInfo plugins + widgets
│   ├── plugins/                     # Custom plugin framework + AppStateInspector
│   │   ├── state_inspector/         # AppStateInspectorPlugin, adapters, BlocTracker
│   │   └── adapters/                # BlocAdapter
│   └── ui/                          # LogOverlay (FAB), LogConsole (tabs), NetworkLogDetailPage
├── example/                         # Runnable demo app
│   └── lib/
│       ├── main.dart                # Toolkit init, MaterialApp setup
│       ├── home_page.dart           # Logging/networking/navigation triggers
│       └── details_page.dart
├── test/
│   └── flutter_dev_toolkit_test.dart  # Currently empty
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
// → registers built-in plugins based on config.builtInPlugins
// → sets up logger, network store, device info store
// → attaches WidgetsBindingObserver
```

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
| `lib/flutter_dev_toolkit.dart` | Entry point; `init()`, `registerPlugin()`, plugin list |
| `lib/core/dev_toolkit_config.dart` | `DevToolkitConfig` — controls which built-in plugins to include |
| `lib/core/dev_toolkit_plugin.dart` | Abstract `DevToolkitPlugin` base class |
| `lib/core/default_logger.dart` | Stores up to 2000 log entries; filterable by tag/level |
| `lib/core/network_log_store.dart` | Stores up to 500 network logs |
| `lib/interceptors/route_interceptor.dart` | NavigatorObserver tracking stack and history with durations |
| `lib/interceptors/network/http_interceptor.dart` | Wraps `http.BaseClient` |
| `lib/interceptors/network/dio_interceptor.dart` | Extends Dio `Interceptor` |
| `lib/built_in_plugins/logs_plugin.dart` | Logs tab: filter by level and tag, export, clear |
| `lib/built_in_plugins/network_plugin.dart` | Network tab: replay, cURL export |
| `lib/plugins/state_inspector/app_state_inspector_plugin.dart` | State inspector with split layout |
| `lib/plugins/adapters/bloc_adapter.dart` | `BlocAdapter` wires BlocObserver into state inspector |
| `lib/ui/log_overlay.dart` | Floating overlay toggle (FAB) |
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

> Tests are currently minimal (stub file only). When adding features, add corresponding tests in `test/`.

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
4. Register it in `lib/core/plugin_registry.dart`
5. Add the option to `DevToolkitConfig`

When adding a custom plugin (consumer-facing):
- Extend `DevToolkitPlugin` directly
- Call `FlutterDevToolkit.registerPlugin(myPlugin)` after `init()`

---

## Important Constraints

- **Do not add `pubspec.lock` to source control** — this is a library package.
- **Do not introduce breaking changes without a major version bump** — this is a published package with consumers.
- **Maintain broad version constraints** on dependencies to avoid consumer conflicts. Verify constraint ranges before tightening.
- **The `actions_plugin.dart` / `actions_tab.dart` are deprecated** — do not build on them. Export/clear actions now live in individual plugins.
- **No CI pipeline** currently exists. Tests and analysis should be run manually before committing.
- **Platform channels** are not used directly; all platform access goes through `device_info_plus`.

---

## Branch & Commit Guidelines

- Development branch: `claude/add-claude-documentation-Tf93H` (current session)
- Main branch: `main`
- Commit messages: imperative mood, concise, e.g. `Add network replay feature` not `Added...`
- Push with: `git push -u origin <branch-name>`

---

## Common Tasks

### Add a Log Entry (from consumer app)
```dart
FlutterDevToolkit.logger.log('message', level: LogLevel.info, tag: LogTag.custom);
```

### Intercept Dio Network Calls
```dart
dio.interceptors.add(DevToolkitDioInterceptor());
```

### Intercept http Network Calls
```dart
final client = DevToolkitHttpClient(http.Client());
```

### Register a Route Observer
```dart
MaterialApp(
  navigatorObservers: [DevToolkitRouteInterceptor()],
)
```

### Add the Overlay to an App
```dart
DevOverlay(child: MyApp())
```
