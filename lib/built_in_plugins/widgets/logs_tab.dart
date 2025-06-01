import 'package:flutter/material.dart';
import 'package:flutter_dev_toolkit/built_in_plugins/widgets/log_tile_widget.dart';
import 'package:flutter_dev_toolkit/core/default_logger.dart';
import 'package:intl/intl.dart';
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
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
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
                  return LogTileWidget(
                    prefix: getIconData(log.level),
                    subTitle: DateFormat(
                      'dd/MM/yyyy hh:mm a',
                    ).format(log.timestamp),
                    title: log.message,
                    titleColor: color,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget getIconData(LogLevel logLevel) {
    switch (logLevel) {
      case LogLevel.debug:
        return Icon(Icons.bug_report_outlined);
      case LogLevel.info:
        return Icon(Icons.info_outline, color: Colors.blue);

      case LogLevel.warning:
        return Icon(Icons.warning_amber_outlined, color: Colors.amber);
      case LogLevel.error:
        return Icon(Icons.error_outline, color: Colors.red);
    }
  }
}
