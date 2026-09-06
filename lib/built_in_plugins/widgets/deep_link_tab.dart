import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/deep_link_store.dart';
import '../../models/deep_link_entry.dart';

class DeepLinkTab extends StatefulWidget {
  const DeepLinkTab({super.key});

  @override
  State<DeepLinkTab> createState() => _DeepLinkTabState();
}

class _DeepLinkTabState extends State<DeepLinkTab> {
  DeepLinkEntry? _selected;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: DeepLinkStore.version,
      builder: (context, _, _) {
        final all = DeepLinkStore.entries.reversed.toList();
        final filtered =
            _search.isEmpty
                ? all
                : all
                    .where(
                      (e) =>
                          e.uri.toLowerCase().contains(_search.toLowerCase()),
                    )
                    .toList();

        if (all.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.link_off, color: Colors.white24, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'No deep links recorded yet',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Call DevToolkitDeepLinkObserver.onLinkReceived(uri)\nwhen your app receives a deep link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search deep links...',
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                ),
                onChanged:
                    (v) => setState(() {
                      _search = v;
                      _selected = null;
                    }),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  // List
                  SizedBox(
                    width: 260,
                    child: ListView.separated(
                      separatorBuilder:
                          (_, _) =>
                              const Divider(height: 1, color: Colors.white12),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final entry = filtered[i];
                        final isSelected = _selected == entry;
                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: Colors.white10,
                          leading: const Icon(
                            Icons.link,
                            color: Colors.cyanAccent,
                            size: 20,
                          ),
                          title: Text(
                            entry.uri,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat(
                              'dd/MM/yy HH:mm:ss',
                            ).format(entry.receivedAt),
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
                  // Detail
                  Expanded(
                    child:
                        _selected == null
                            ? const Center(
                              child: Text(
                                'Select a link to inspect',
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                            : _DeepLinkDetail(entry: _selected!),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DeepLinkDetail extends StatelessWidget {
  final DeepLinkEntry entry;

  const _DeepLinkDetail({required this.entry});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(entry.uri);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.uri,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16, color: Colors.white54),
                tooltip: 'Copy URI',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: entry.uri));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('URI copied')));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Received',
            child: Text(
              DateFormat('dd MMM yyyy, HH:mm:ss').format(entry.receivedAt),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          if (entry.source != null) ...[
            const SizedBox(height: 12),
            _Section(
              title: 'Source',
              child: Text(
                entry.source!,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
          if (uri != null) ...[
            const SizedBox(height: 12),
            _Section(
              title: 'Parsed',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('Scheme', uri.scheme),
                  _kv('Host', uri.host),
                  _kv('Path', uri.path),
                  if (uri.fragment.isNotEmpty) _kv('Fragment', uri.fragment),
                ],
              ),
            ),
          ],
          if (entry.queryParams.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Section(
              title: 'Query Parameters',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    entry.queryParams.entries
                        .map((e) => _kv(e.key, e.value))
                        .toList(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final text = const JsonEncoder.withIndent(
                '  ',
              ).convert(entry.toJson());
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Copied as JSON')));
            },
            icon: const Icon(Icons.copy_all, size: 16),
            label: const Text('Copy as JSON'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white12,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String key, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            key,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
