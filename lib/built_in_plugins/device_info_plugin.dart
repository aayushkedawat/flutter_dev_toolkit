import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dev_toolkit/built_in_plugins/widgets/device_info_tab.dart';
import 'package:flutter_dev_toolkit/core/device_info_store.dart';
import 'package:share_plus/share_plus.dart';

import '../core/dev_toolkit_plugin.dart';
import '../flutter_dev_toolkit.dart';

class UserDeviceInfoPlugin extends DevToolkitPlugin {
  @override
  String get name => 'Device Info';

  @override
  IconData get icon => Icons.devices;

  @override
  void onInit() {}

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          Map<String, dynamic> shareData = {};

          for (var element in DeviceInfoLogStore.logs) {
            // shareData += '${element.key} : ${element.value}\n';
            // shareData.add(element.toJson());
            shareData[element.key] = element.value;
          }
          FlutterDevToolkit.logger.log('📤 Exported Device Info:\n$shareData');
          ShareParams shareParams = ShareParams(
            text: jsonEncode(shareData),
            subject: name,
          );
          SharePlus.instance.share(shareParams);
        },
        icon: Icon(Icons.share),
      ),
    ];
  }

  @override
  Widget buildTab(BuildContext context) {
    return DeviceInfoTab();
  }
}
