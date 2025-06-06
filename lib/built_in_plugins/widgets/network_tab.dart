import 'package:flutter/material.dart';

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

class _NetworkTabState extends State<NetworkTab> {
  String _searchQuery = '';
  String _methodFilter = 'All';

  final _methods = ['All', 'GET', 'POST', 'PUT', 'DELETE', 'PATCH'];

  @override
  Widget build(BuildContext context) {
    final logs =
        NetworkLogStore.logs.reversed.where((log) {
          final matchesMethod =
              _methodFilter == 'All' || log.method == _methodFilter;
          final matchesSearch =
              log.url.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (log.statusCode?.toString().contains(_searchQuery) ?? false);
          return matchesMethod && matchesSearch;
        }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              DropdownButton<String>(
                value: _methodFilter,
                items:
                    _methods
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                onChanged:
                    (val) => setState(() => _methodFilter = val ?? 'All'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Search URL or status...',
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
                          '${log.method}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                '${log.url}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Status: ${log.statusCode} | Time: ${log.duration.inMilliseconds}ms',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Padding(
                      padding: EdgeInsetsGeometry.all(4),
                      // padding: const EdgeInsets.only(left: 4, right: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            child: Text(
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
                            child: Text(
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
