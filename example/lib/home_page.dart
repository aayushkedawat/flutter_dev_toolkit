import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dev_toolkit/core/logger_interface.dart';
import 'package:flutter_dev_toolkit/flutter_dev_toolkit.dart';
import 'package:flutter_dev_toolkit/interceptors/deep_link_observer.dart';
import 'package:flutter_dev_toolkit/interceptors/network/dio_interceptor.dart';
import 'package:flutter_dev_toolkit/interceptors/network/network_mock_rule.dart';
import 'package:flutter_dev_toolkit/interceptors/network/network_mock_store.dart';
import 'package:flutter_dev_toolkit/models/log_tag.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'example_flags.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _makeDioRequest() async {
    final dio = Dio();
    dio.interceptors.add(DioNetworkInterceptor());

    try {
      await dio.get('https://jsonplaceholder.typicode.com/posts/1');
      FlutterDevToolkit.logger.log('Dio request complete');
    } catch (e) {
      FlutterDevToolkit.logger.log('Dio error: $e', level: LogLevel.error);
    }
  }

  /// Hits a URL that returns 404 so the Network tab shows an error entry.
  Future<void> _makeFailingRequest() async {
    final dio = Dio();
    dio.interceptors.add(DioNetworkInterceptor());

    try {
      await dio.get('https://jsonplaceholder.typicode.com/posts/999999');
    } catch (_) {
      // The interceptor already recorded it; swallow so the demo keeps running.
    }
  }

  /// Reported through FlutterError.onError, which the toolkit hooks. Shows up
  /// in the Crashes tab as a non-fatal entry.
  void _reportFlutterError() {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: Exception('Example: something went wrong in a widget'),
        stack: StackTrace.current,
        library: 'flutter_dev_toolkit example',
        context: ErrorDescription('while demonstrating the Crashes tab'),
      ),
    );
  }

  /// An unawaited future that throws reaches PlatformDispatcher.onError, which
  /// the toolkit records as a fatal crash.
  void _throwAsyncError() {
    Future<void>(() {
      throw StateError('Example: unhandled async error');
    });
  }

  /// Blocks the UI thread long enough to blow past the 16 ms frame budget, so
  /// the Performance tab registers jank frames and the FPS reading drops.
  void _causeJank() {
    final until = DateTime.now().add(const Duration(milliseconds: 600));
    var spin = 0;
    while (DateTime.now().isBefore(until)) {
      spin++;
    }
    FlutterDevToolkit.logger.log(
      'Blocked the UI thread for 600ms ($spin iterations)',
      level: LogLevel.warning,
    );
  }

  /// Adds a mock rule for this exact call, then makes it — the Network tab
  /// shows the mocked entry (tagged MOCKED) without a real request ever going
  /// out. Manage rules from the Network tab's own config panel (the tune icon
  /// in its app bar) to try this on any URL.
  Future<void> _demoNetworkMocking() async {
    const url = 'https://jsonplaceholder.typicode.com/posts/1';
    NetworkMockStore.add(
      NetworkMockRule(
        urlContains: '/posts/1',
        statusCode: 200,
        responseBody: '{"id": 1, "title": "mocked from the example app"}',
      ),
    );

    final dio = Dio();
    dio.interceptors.add(DioNetworkInterceptor());
    await dio.get(url);
    FlutterDevToolkit.logger.log(
      'Made a mocked request to $url — check the Network tab',
    );
  }

  Future<void> _writeSamplePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setInt(
        'session_count', (prefs.getInt('session_count') ?? 0) + 1);
    await prefs.setString('last_screen', 'home');
    await prefs
        .setStringList('recent_searches', ['flutter', 'dart', 'widgets']);
    FlutterDevToolkit.logger.log('Wrote sample SharedPreferences entries');
  }

  void _simulateDeepLink() {
    DevToolkitDeepLinkObserver.onLinkReceived(
      'myapp://products/42?ref=email&campaign=spring_sale',
      source: 'example',
    );
  }

  void _logAtEveryLevel() {
    final logger = FlutterDevToolkit.logger;
    logger.log('A debug message', tags: {LogTag.custom});
    logger.log('An info message', level: LogLevel.info, tags: {LogTag.custom});
    logger.log(
      'A warning message',
      level: LogLevel.warning,
      tags: {LogTag.custom},
    );
    logger.log(
      'An error message',
      level: LogLevel.error,
      tags: {LogTag.custom},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LiveFlagsBanner(),
          const _SectionHeader('Logs'),
          _DemoButton(
            label: 'Log a Message',
            onPressed: () =>
                FlutterDevToolkit.logger.log('User tapped Log button'),
          ),
          _DemoButton(
            label: 'Log at Every Level',
            onPressed: _logAtEveryLevel,
          ),
          const _SectionHeader('Network'),
          _DemoButton(
              label: 'Make Network Request', onPressed: _makeDioRequest),
          _DemoButton(
            label: 'Make Failing Request (404)',
            onPressed: _makeFailingRequest,
          ),
          _DemoButton(
            label: 'Add a Mock Rule and Call It',
            onPressed: _demoNetworkMocking,
          ),
          const _SectionHeader('Crashes'),
          _DemoButton(
            label: 'Report a Flutter Error',
            onPressed: _reportFlutterError,
          ),
          _DemoButton(
            label: 'Throw an Async Error (fatal)',
            onPressed: _throwAsyncError,
          ),
          const _SectionHeader('Performance'),
          _DemoButton(label: 'Cause Jank (600ms)', onPressed: _causeJank),
          const _SectionHeader('Storage'),
          _DemoButton(
            label: 'Write Sample SharedPreferences',
            onPressed: _writeSamplePreferences,
          ),
          const _SectionHeader('Deep Links'),
          _DemoButton(
            label: 'Simulate a Deep Link',
            onPressed: _simulateDeepLink,
          ),
          const _SectionHeader('Routes'),
          _DemoButton(
            label: 'Go to Details Page',
            onPressed: () => Navigator.pushNamed(context, '/details'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Open the dev console with the floating button, then check the tab '
            'matching each section above.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/// Reacts live to two flags registered in example_flags.dart. Toggle them
/// from the toolkit's Flags tab — no rebuild of the app, no hot reload.
class _LiveFlagsBanner extends StatelessWidget {
  const _LiveFlagsBanner();

  static const _accentColors = {
    'blue': Colors.blue,
    'purple': Colors.purple,
    'green': Colors.green,
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Object>(
      valueListenable: showPromoBannerFlag.notifier,
      builder: (context, showBanner, _) {
        if (showBanner != true) return const SizedBox.shrink();

        return ValueListenableBuilder<Object>(
          valueListenable: accentColorFlag.notifier,
          builder: (context, accent, _) {
            final color = _accentColors[accent] ?? Colors.blue;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                border: Border.all(color: color),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.campaign, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Promo banner — driven by the "Show Promo Banner" and '
                      '"Accent Color" flags. Try flipping them from the '
                      'Flags tab.',
                      style: TextStyle(color: color.withAlpha(220)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.black54,
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}
