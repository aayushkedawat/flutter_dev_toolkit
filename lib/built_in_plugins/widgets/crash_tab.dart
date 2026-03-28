import 'dart:convert';

import 'package:flutter/material.dart';
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
      builder: (context, _, __) {
        final entries = CrashLogStore.entries.reversed.toList();

        if (entries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                SizedBox(height: 12),
                Text(
                  'No crashes recorded',
                  style: TextStyle(color: Colors.white70),
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
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Colors.white12),
                itemCount: entries.length,
                itemBuilder: (_, index) {
                  final entry = entries[index];
                  final isSelected = _selected == entry;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Colors.white10,
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yy HH:mm:ss').format(entry.timestamp),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                    onTap: () => setState(() => _selected = entry),
                  );
                },
              ),
            ),
            const VerticalDivider(width: 1, color: Colors.white12),
            // Right: detail
            Expanded(
              child:
                  _selected == null
                      ? const Center(
                        child: Text(
                          'Select a crash to view details',
                          style: TextStyle(color: Colors.white54),
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
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                entry.isFatal ? 'FATAL' : 'ERROR',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yy HH:mm:ss').format(entry.timestamp),
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                tooltip: 'Copy to clipboard',
                onPressed: () {
                  final text = const JsonEncoder.withIndent('  ')
                      .convert(entry.toJson());
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
        const Divider(height: 1, color: Colors.white12),
        // Stack trace
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              entry.stackTrace,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
