import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dev_toolkit/core/share_utils.dart';
import 'package:flutter_dev_toolkit/interceptors/network_interceptor.dart';
import '../../core/dev_toolkit_plugin.dart';
import '../core/network_log_store.dart';
import 'widgets/network_tab.dart';

class NetworkPlugin extends DevToolkitPlugin {
  @override
  String get name => 'Network';

  @override
  IconData get icon => Icons.network_check;

  @override
  void onInit() {
    NetworkInterceptor.init();
  }

  @override
  Widget buildTab(BuildContext context) => const NetworkTab();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Export Network Logs',
        icon: const Icon(Icons.share),
        onPressed: () {
          final logs = NetworkLogStore.logs;
          final json = jsonEncode(logs.map((e) => e.toJson()).toList());

          final fileName = 'Network Logs';

          ExportUtil.exportData(text: json, title: fileName);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exported network logs')),
          );
        },
      ),
    ];
  }
}
