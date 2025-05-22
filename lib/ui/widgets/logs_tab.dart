import 'package:flutter/material.dart';

import '../../flutter_dev_toolkit.dart';

class LogsTab extends StatelessWidget {
  const LogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = FlutterDevToolkit.logger.logEntries;

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final entry = logs[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            '[${entry.timestamp.toIso8601String()}] [${entry.level.name.toUpperCase()}] ${entry.message}',
            style: TextStyle(
              color: _logColor(entry.level),
              fontFamily: 'monospace',
            ),
          ),
        );
      },
    );
  }

  Color _logColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.redAccent;
    }
  }
}
