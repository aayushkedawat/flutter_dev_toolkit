# Flutter Dev Toolkit

🚀 A modular in-app developer console for Flutter apps.

Track logs, API calls, navigation, performance, and add your own plugins — all in real time, inside your app.

---

## ✨ Features

- ✅ In-app Dev Console
- ✅ Colored logs with filtering
- ✅ Network call inspector (`http`, `dio`, `retrofit`)
- ✅ Route stack and screen duration tracker
- ✅ Export logs
- ✅ Plugin system for custom tools

---

## 🛠 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_dev_toolkit: ^1.0.0
```

Then:

```bash
flutter pub get
```

---

## 🚀 Getting Started

### Initialize the toolkit in `main.dart`:

```dart
void main() {
  FlutterDevToolkit.init(
    config: DevToolkitConfig(
      enableRouteInterceptor: true,
      enableNetworkInterceptor: true,
    ),
  );

  runApp(MyApp());
}
```

### Add the Dev Console to your widget tree:

```dart
MaterialApp(
  builder: (context, child) {
    return Stack(
      children: [
        child!,
        const DevOverlay(),
      ],
    );
  },
  home: const SplashScreen(),
  navigatorObservers: [RouteInterceptor.instance],
);
```

---

## 🧩 Plugins

You can add custom developer tools as plugins:

```dart
class CounterPlugin extends DevToolkitPlugin {
  @override String get name => 'Counter';
  @override IconData get icon => Icons.exposure_plus_1;

  @override void onInit() {
    debugPrint('CounterPlugin loaded!');
  }

  @override Widget buildTab(BuildContext context) => Center(child: Text('Counter Tab'));
}
```

Register it before `runApp`:

```dart
FlutterDevToolkit.registerPlugin(CounterPlugin());
```

---

## 📤 Exporting

You can export logs and routes via the Actions Tab

## Custom Logs

You  can log custom logs using:
```dart
FlutterDevToolkit.logger.log('Hello!');
```

---

## 📄 License

MIT
