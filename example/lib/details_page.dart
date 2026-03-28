import 'package:flutter/material.dart';
import 'package:flutter_dev_toolkit/core/logger_interface.dart';
import 'package:flutter_dev_toolkit/flutter_dev_toolkit.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  void initState() {
    super.initState();
    FlutterDevToolkit.logger.log(
      'DetailsPage opened',
      level: LogLevel.info,
    );
  }

  @override
  void dispose() {
    FlutterDevToolkit.logger.log(
      'DetailsPage disposed',
      level: LogLevel.debug,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This page entry and exit are logged.\nCheck the Logs and Routes tabs.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
