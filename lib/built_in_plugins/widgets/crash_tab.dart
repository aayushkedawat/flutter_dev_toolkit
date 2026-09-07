import 'dart:convert';

import 'package:flutter/material.dart';
import '../../core/dev_console_theme.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/crash_log_store.dart';
import '../../models/crash_entry.dart';

class CrashTab extends StatefulWidget {
  const CrashTab({super.key});

  @override
  State<CrashTab> createState() => _CrashTabState();
}

class _CrashTabState extends State<CrashTab> {
  CrashEntry? _selected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: CrashLogStore.version,
      builder: (context, _, _) {
        final entries = CrashLogStore.entries.reversed.toList();

        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                SizedBox(height: 12),
                Text(
                  'No crashes recorded',
                  style: TextStyle(color: palette.subtle),
                ),
              ],
            ),
          );
        }

        return Row(
          children: [
            // Left: list
            SizedBox(
              width: 260,
              child: ListView.separated(
                separatorBuilder:
                    (_, _) => Divider(height: 1, color: palette.divider),
                itemCount: entries.length,
                itemBuilder: (_, index) {
                  final entry = entries[index];
                  final isSelected = _selected == entry;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: palette.surface,
                    leading: Icon(
                      entry.isFatal
                          ? Icons.dangerous_outlined
                          : Icons.warning_amber_outlined,
                      color: entry.isFatal ? Colors.red : Colors.orange,
                    ),
                    title: Text(
                      entry.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: palette.onSurface),
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yy HH:mm:ss').format(entry.timestamp),
                      style: TextStyle(fontSize: 11, color: palette.subtle),
                    ),
                    onTap: () => setState(() => _selected = entry),
                  );
                },
              ),
            ),
            VerticalDivider(width: 1, color: palette.divider),
            // Right: detail
            Expanded(
              child:
                  _selected == null
                      ? Center(
                        child: Text(
                          'Select a crash to view details',
                          style: TextStyle(color: palette.subtle),
                        ),
                      )
                      : _CrashDetail(entry: _selected!),
            ),
          ],
        );
      },
    );
  }
}

class _CrashDetail extends StatelessWidget {
  final CrashEntry entry;

  const _CrashDetail({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          color: entry.isFatal ? Colors.red.shade900 : Colors.orange.shade900,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                entry.isFatal
                    ? Icons.dangerous_outlined
                    : Icons.warning_amber_outlined,
                size: 16,
                color: palette.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                entry.isFatal ? 'FATAL' : 'ERROR',
                style: TextStyle(
                  color: palette.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yy HH:mm:ss').format(entry.timestamp),
                style: TextStyle(color: palette.subtle, fontSize: 11),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.copy, size: 16, color: palette.subtle),
                tooltip: 'Copy to clipboard',
                onPressed: () {
                  final text = const JsonEncoder.withIndent(
                    '  ',
                  ).convert(entry.toJson());
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ),
        // Message
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            entry.message,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Divider(height: 1, color: palette.divider),
        // Stack trace
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              entry.stackTrace,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: palette.subtle,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
