import 'package:flutter/material.dart';
import '../../core/dev_console_theme.dart';

import '../../core/logger_interface.dart';
import '../../core/network_log_store.dart';
import '../../flutter_dev_toolkit.dart';
import '../../interceptors/network/network_log.dart';
import 'package:http/http.dart' as http;

import '../../ui/network_log_detail_page.dart';

class NetworkTab extends StatefulWidget {
  const NetworkTab({super.key});

  @override
  State<NetworkTab> createState() => _NetworkTabState();
}

/// Status buckets offered alongside the method filter.
enum _StatusFilter {
  all('All'),
  success('2xx'),
  redirect('3xx'),
  clientError('4xx'),
  serverError('5xx'),
  failed('Failed');

  const _StatusFilter(this.label);

  final String label;

  bool matches(NetworkLog log) => switch (this) {
    _StatusFilter.all => true,
    // Never got a usable status: the request threw, or timed out.
    _StatusFilter.failed => log.statusGroup == null,
    _StatusFilter.success => log.statusGroup == 2,
    _StatusFilter.redirect => log.statusGroup == 3,
    _StatusFilter.clientError => log.statusGroup == 4,
    _StatusFilter.serverError => log.statusGroup == 5,
  };
}

class _NetworkTabState extends State<NetworkTab> {
  String _searchQuery = '';
  String _methodFilter = 'All';
  _StatusFilter _statusFilter = _StatusFilter.all;

  final _methods = ['All', 'GET', 'POST', 'PUT', 'DELETE', 'PATCH'];

  @override
  Widget build(BuildContext context) {
    // Rebuild as calls come in, not only when a filter is touched.
    return ValueListenableBuilder<int>(
      valueListenable: NetworkLogStore.version,
      builder: (context, _, _) => _buildList(),
    );
  }

  Widget _buildList() {
    final query = _searchQuery.toLowerCase();
    final logs =
        NetworkLogStore.logs.reversed.where((log) {
          final matchesMethod =
              _methodFilter == 'All' || log.method == _methodFilter;
          final matchesSearch =
              log.url.toLowerCase().contains(query) ||
              (log.statusCode?.toString().contains(_searchQuery) ?? false);
          return matchesMethod && _statusFilter.matches(log) && matchesSearch;
        }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Row(
                children: [
                  DropdownButton<String>(
                    value: _methodFilter,
                    items:
                        _methods
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                    onChanged:
                        (val) => setState(() => _methodFilter = val ?? 'All'),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<_StatusFilter>(
                    value: _statusFilter,
                    items:
                        _StatusFilter.values
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.label),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (val) => setState(
                          () => _statusFilter = val ?? _StatusFilter.all,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${logs.length} of ${NetworkLogStore.logs.length}',
                    style: TextStyle(color: palette.subtle, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search URL or status...',
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
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

              final ms = log.duration.inMilliseconds;
              final speedColor =
                  log.isError
                      ? Colors.red
                      : ms < 200
                      ? Colors.green
                      : ms < 1000
                      ? Colors.orange
                      : Colors.red;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      log.isError
                          ? Colors.red.shade100
                          : Colors.lightGreen.shade50,
                  border: Border.all(
                    color: log.isError ? Colors.red : Colors.green,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          log.method,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (log.isMocked) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'MOCKED',
                              style: TextStyle(
                                color: Colors.purple.shade900,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.url,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Status: ${log.statusCode}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Response-time badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: speedColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${ms}ms',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            child: const Text(
                              'Details',
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => NetworkLogDetailPage(log: log),
                                  settings: RouteSettings(arguments: log),
                                ),
                              );
                            },
                          ),
                          GestureDetector(
                            child: const Text(
                              'Replay',
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () => _replay(log),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _replay(NetworkLog log) async {
    try {
      final uri = Uri.parse(log.url);
      final request = http.Request(log.method, uri);
      if (log.requestBody != null && log.method != 'GET') {
        request.body = log.requestBody.toString();
        request.headers['Content-Type'] = 'application/json';
      }

      final client = http.Client();
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      FlutterDevToolkit.logger.log(
        '🔁 Replayed ${log.method} ${log.url} → Status: ${response.statusCode}',
        level: LogLevel.info,
      );
    } catch (e) {
      FlutterDevToolkit.logger.log('Replay failed: $e', level: LogLevel.error);
    }
  }
}
