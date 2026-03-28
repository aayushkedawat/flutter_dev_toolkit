import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dev_toolkit/core/logger_interface.dart';
import 'package:flutter_dev_toolkit/flutter_dev_toolkit.dart';
import 'package:flutter_dev_toolkit/interceptors/deep_link_observer.dart';
import 'package:flutter_dev_toolkit/interceptors/network/dio_interceptor.dart';
import 'package:flutter_dev_toolkit/interceptors/network/http_interceptor.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ─── Network ────────────────────────────────────────────────────────────────

  Future<void> _makeDioRequest() async {
    final dio = Dio()..interceptors.add(DioNetworkInterceptor());
    try {
      await dio.get('https://jsonplaceholder.typicode.com/posts/1');
      FlutterDevToolkit.logger.log('Dio GET complete', level: LogLevel.info);
    } catch (e) {
      FlutterDevToolkit.logger.log('Dio error: $e', level: LogLevel.error);
    }
  }

  Future<void> _makeHttpRequest() async {
    final client = HttpInterceptor(http.Client());
    try {
      final response = await client.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users/1'),
      );
      FlutterDevToolkit.logger.log(
        'http GET → ${response.statusCode}',
        level: LogLevel.info,
      );
    } catch (e) {
      FlutterDevToolkit.logger.log('http error: $e', level: LogLevel.error);
    } finally {
      client.close();
    }
  }

  Future<void> _makeFailingRequest() async {
    final dio = Dio()..interceptors.add(DioNetworkInterceptor());
    try {
      await dio.get('https://jsonplaceholder.typicode.com/posts/99999');
    } catch (_) {
      // error captured by the network interceptor and shown in Network tab
    }
  }

  // ─── Logging ────────────────────────────────────────────────────────────────

  void _logAllLevels() {
    FlutterDevToolkit.logger.log('Debug: cache primed', level: LogLevel.debug);
    FlutterDevToolkit.logger.log('Info: user signed in', level: LogLevel.info);
    FlutterDevToolkit.logger.log(
      'Warning: token expires in 5 min',
      level: LogLevel.warning,
    );
    FlutterDevToolkit.logger.log(
      'Error: payment gateway timeout',
      level: LogLevel.error,
    );
  }

  // ─── Crashes ────────────────────────────────────────────────────────────────

  void _triggerFlutterError(BuildContext context) {
    // Reports to Crashes tab via FlutterError.onError
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: StateError('Example error: invalid cart state'),
        stack: StackTrace.current,
        library: 'example',
        context: ErrorDescription('triggered from HomePage demo button'),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error reported — check the Crashes tab')),
    );
  }

  // ─── Deep Links ─────────────────────────────────────────────────────────────

  void _simulateDeepLinks() {
    DevToolkitDeepLinkObserver.onLinkReceived(
      'myapp://product/42?ref=banner&utm_source=email',
      source: 'manual',
    );
    DevToolkitDeepLinkObserver.onLinkReceived(
      'myapp://checkout?cart_id=abc123&promo=SAVE10',
      source: 'manual',
    );
  }

  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Toolkit Example')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _SectionHeader('Logging'),
          _DemoButton(
            label: 'Log all levels',
            icon: Icons.list_alt,
            onTap: _logAllLevels,
          ),

          _SectionHeader('Network'),
          _DemoButton(
            label: 'Dio GET request',
            icon: Icons.cloud_download_outlined,
            onTap: _makeDioRequest,
          ),
          _DemoButton(
            label: 'http GET request',
            icon: Icons.http,
            onTap: _makeHttpRequest,
          ),
          _DemoButton(
            label: 'Failing request (404)',
            icon: Icons.cloud_off_outlined,
            onTap: _makeFailingRequest,
          ),

          _SectionHeader('Crashes'),
          _DemoButton(
            label: 'Trigger Flutter error',
            icon: Icons.bug_report_outlined,
            onTap: () => _triggerFlutterError(context),
            color: Colors.orange.shade700,
          ),

          _SectionHeader('Deep Links'),
          _DemoButton(
            label: 'Simulate 2 deep links',
            icon: Icons.link,
            onTap: _simulateDeepLinks,
          ),

          _SectionHeader('Navigation'),
          _DemoButton(
            label: 'Go to Details page',
            icon: Icons.arrow_forward,
            onTap: () => Navigator.pushNamed(context, '/details'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _DemoButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          backgroundColor: color,
        ),
      ),
    );
  }
}
