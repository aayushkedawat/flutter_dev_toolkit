import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/dev_toolkit_plugin.dart';

import 'app_state_adapter.dart';
import 'app_state_entry.dart';

class AppStateInspectorPlugin extends DevToolkitPlugin {
  final List<AppStateAdapter> adapters;

  AppStateInspectorPlugin(this.adapters);

  @override
  String get name => 'App State';

  @override
  IconData get icon => Icons.data_object;

  @override
  void onInit() {}

  @override
  Widget buildTab(BuildContext context) {
    return AppStateInspectorView(adapters: adapters);
  }
}

class AppStateInspectorView extends StatefulWidget {
  final List<AppStateAdapter> adapters;

  const AppStateInspectorView({super.key, required this.adapters});

  @override
  State<AppStateInspectorView> createState() => _AppStateInspectorViewState();
}

class _AppStateInspectorViewState extends State<AppStateInspectorView> {
  int _selectedAdapterIndex = 0;
  int? selectedEntryIndex;

  @override
  Widget build(BuildContext context) {
    final adapter = widget.adapters[_selectedAdapterIndex];
    final entries = adapter.entries.reversed.toList();

    if (entries.isEmpty) {
      return Center(child: Text('No ${adapter.name} state changes yet.'));
    }

    final isWide = MediaQuery.of(context).size.width > 600;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: DropdownButton<int>(
            value: _selectedAdapterIndex,
            onChanged:
                (val) => setState(() {
                  _selectedAdapterIndex = val!;
                  selectedEntryIndex = null;
                }),
            items: List.generate(widget.adapters.length, (i) {
              return DropdownMenuItem(
                value: i,
                child: Text(widget.adapters[i].name),
              );
            }),
          ),
        ),
        const Divider(height: 0),
        Expanded(
          child:
              isWide
                  ? Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (_, i) {
                            final entry = entries[i];
                            return ListTile(
                              selected: selectedEntryIndex == i,
                              onTap:
                                  () => setState(() => selectedEntryIndex = i),
                              title: Text(entry.source),
                              subtitle: Text(
                                entry.timestamp
                                    .toIso8601String()
                                    .split('T')
                                    .last,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Flexible(
                        flex: 3,
                        child:
                            selectedEntryIndex == null
                                ? const Center(child: Text('Select an entry'))
                                : _buildEntryDetail(
                                  entries[selectedEntryIndex!],
                                ),
                      ),
                    ],
                  )
                  : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder:
                        (_, i) => ExpansionTile(
                          title: Text(entries[i].source),
                          subtitle: Text(
                            entries[i].timestamp
                                .toIso8601String()
                                .split('T')
                                .last,
                            style: const TextStyle(fontSize: 12),
                          ),
                          children: [_buildEntryDetail(entries[i])],
                        ),
                  ),
        ),
      ],
    );
  }

  Widget _buildEntryDetail(AppStateEntry entry) {
    final formatted = _prettyJson(entry.value);
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  formatted,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: formatted));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('State copied to clipboard')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Text(
          //   formatted,
          //   style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          // ),
        ],
      ),
    );
  }

  String _prettyJson(dynamic value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }
}
