import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/dev_toolkit_plugin.dart';

import 'app_state_adapter.dart';
import 'app_state_entry.dart';

/// A custom plugin adding an "App State" tab that inspects state changes
/// from one or more [AppStateAdapter]s (e.g. `BlocAdapter`,
/// `RecordedStateAdapter`).
///
/// Unlike built-in plugins, this one is opt-in — register it explicitly:
///
/// ```dart
/// FlutterDevToolkit.registerPlugin(AppStateInspectorPlugin([BlocAdapter()]));
/// ```
class AppStateInspectorPlugin extends DevToolkitPlugin {
  /// The state sources shown in the tab's adapter dropdown.
  final List<AppStateAdapter> adapters;

  /// Creates the plugin from one or more [adapters].
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

/// The App State Inspector's UI: an adapter picker plus a list/detail view
/// of that adapter's recorded state changes, split side-by-side on wide
/// screens.
class AppStateInspectorView extends StatefulWidget {
  /// The state sources to choose between.
  final List<AppStateAdapter> adapters;

  /// Creates the inspector view.
  const AppStateInspectorView({super.key, required this.adapters});

  @override
  State<AppStateInspectorView> createState() => _AppStateInspectorViewState();
}

class _AppStateInspectorViewState extends State<AppStateInspectorView> {
  int _selectedAdapterIndex = 0;

  /// Held by identity rather than by index: entries are displayed newest-first,
  /// so an index would silently point at a different entry as state flows in.
  AppStateEntry? _selectedEntry;

  @override
  Widget build(BuildContext context) {
    final adapter = widget.adapters[_selectedAdapterIndex];
    final revision = adapter.revision;

    final body = Builder(builder: (context) => _buildBody(adapter));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: DropdownButton<int>(
            value: _selectedAdapterIndex,
            onChanged:
                (val) => setState(() {
                  _selectedAdapterIndex = val!;
                  _selectedEntry = null;
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
          // Rebuild as new state arrives, when the adapter can tell us.
          child:
              revision == null
                  ? body
                  : ListenableBuilder(
                    listenable: revision,
                    builder: (_, _) => body,
                  ),
        ),
      ],
    );
  }

  Widget _buildBody(AppStateAdapter adapter) {
    final entries = adapter.entries.reversed.toList();

    if (entries.isEmpty) {
      return Center(child: Text('No ${adapter.name} state changes yet.'));
    }

    final isWide = MediaQuery.of(context).size.width > 600;
    if (!isWide) {
      return ListView.builder(
        itemCount: entries.length,
        itemBuilder:
            (_, i) => ExpansionTile(
              title: Text(entries[i].source),
              subtitle: Text(
                _formatTime(entries[i].timestamp),
                style: const TextStyle(fontSize: 12),
              ),
              children: [_buildEntryDetail(entries[i])],
            ),
      );
    }

    final selected = entries.contains(_selectedEntry) ? _selectedEntry : null;

    return Row(
      children: [
        Flexible(
          flex: 2,
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final entry = entries[i];
              return ListTile(
                selected: identical(selected, entry),
                onTap: () => setState(() => _selectedEntry = entry),
                title: Text(entry.source),
                subtitle: Text(
                  _formatTime(entry.timestamp),
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
              selected == null
                  ? const Center(child: Text('Select an entry'))
                  : _buildEntryDetail(selected),
        ),
      ],
    );
  }

  Widget _buildEntryDetail(AppStateEntry entry) {
    final formatted = _prettyJson(entry.value);
    final previous = entry.previousState;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current state',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy state',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: formatted));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('State copied to clipboard')),
                  );
                },
              ),
            ],
          ),
          SelectableText(
            formatted,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          if (previous != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Previous state',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            SelectableText(
              _prettyJson(previous),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) =>
      timestamp.toIso8601String().split('T').last;

  String _prettyJson(dynamic value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }
}
