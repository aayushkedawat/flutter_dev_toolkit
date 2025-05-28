import 'package:flutter/material.dart';
import 'package:flutter_dev_toolkit/core/default_logger.dart';
import '../../../core/logger_interface.dart';
import '../../../flutter_dev_toolkit.dart';
import '../../models/log_tag.dart';

class LogsTab extends StatefulWidget {
  const LogsTab({super.key});

  @override
  State<LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends State<LogsTab> {
  String _searchQuery = '';
  LogLevel? _level;
  final Set<LogTag> _selectedTags = {};

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: DefaultLogger.logVersion,
      builder: (context, _, __) {
        final logs =
            FlutterDevToolkit.logger.logEntries
                .where((log) {
                  final matchLevel = _level == null || log.level == _level;
                  final matchQuery = log.message.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
                  final matchTags =
                      _selectedTags.isEmpty ||
                      log.tags.any(_selectedTags.contains);
                  return matchLevel && matchQuery && matchTags;
                })
                .toList()
                .reversed
                .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  DropdownButton<LogLevel?>(
                    value: _level,
                    hint: const Text('Level'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...LogLevel.values.map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: Text(level.name.toUpperCase()),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _level = val),
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Search logs...',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final color = switch (log.level) {
                    LogLevel.debug => Colors.white,
                    LogLevel.info => Colors.blue,
                    LogLevel.warning => Colors.orange,
                    LogLevel.error => Colors.red,
                  };

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.message, style: TextStyle(color: color)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
