import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../interceptors/network/network_log.dart';

class NetworkLogDetailPage extends StatelessWidget {
  final NetworkLog log;

  const NetworkLogDetailPage({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'API Call Details',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: log.isError ? Colors.red : Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Export Log',
            onPressed: () {
              final export = _formatLogForExport(log);
              Clipboard.setData(ClipboardData(text: export));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Log copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: const [
            TabBar(
              tabs: [
                Tab(text: 'Request'),
                Tab(text: 'Response'),
                Tab(text: 'Error'),
              ],
            ),
            Expanded(child: _TabView()),
          ],
        ),
      ),
    );
  }

  String _formatLogForExport(NetworkLog log) {
    final map = {
      'method': log.method,
      'url': log.url,
      'statusCode': log.statusCode,
      'duration': log.duration.toString(),
      'requestHeaders': log.requestHeaders,
      'requestBody': log.requestBody,
      'responseBody': _parseIfJson(log.responseBody),
      'isError': log.isError,
    };

    try {
      return const JsonEncoder.withIndent('  ').convert(map);
    } catch (_) {
      return map.toString();
    }
  }

  dynamic _parseIfJson(String? input) {
    if (input == null) return null;

    try {
      return json.decode(input);
    } catch (_) {
      return input; // return as-is if not valid JSON
    }
  }
}

class _TabView extends StatelessWidget {
  const _TabView();

  @override
  Widget build(BuildContext context) {
    final log = (ModalRoute.of(context)?.settings.arguments as NetworkLog);

    return TabBarView(
      children: [
        _KeyValueView(
          title: 'Request',
          data: {
            'Method': log.method,
            'URL': log.url,
            'Headers': log.requestHeaders?.toString() ?? 'None',
            'Query Params': Uri.parse(log.url).queryParameters.entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n'),
            'Body': log.requestBody?.toString() ?? 'None',
          },
        ),
        _KeyValueView(
          title: 'Response',
          data: {
            'Status': '${log.statusCode}',
            'Body': log.responseBody?.toString() ?? 'None',
          },
        ),
        _KeyValueView(
          title: 'Error',
          data: {
            'Is Error': log.isError ? 'Yes' : 'No',
            'Exception':
                log.isError && log.responseBody == null
                    ? 'Possible network or server failure.'
                    : 'None',
          },
        ),
      ],
    );
  }
}

class _KeyValueView extends StatelessWidget {
  final String title;
  final Map<String, String> data;

  const _KeyValueView({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children:
          data.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(entry.value),
                const Divider(),
              ],
            );
          }).toList(),
    );
  }
}
