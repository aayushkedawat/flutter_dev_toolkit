import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/dev_toolkit_plugin.dart';
import '../flutter_dev_toolkit.dart';

class DeviceInfoPlugin extends DevToolkitPlugin {
  @override
  String get name => 'Device Info';

  @override
  IconData get icon => Icons.devices;

  @override
  void onInit() {}

  @override
  Widget buildTab(BuildContext context) {
    final mq = MediaQuery.of(context);

    final info = {
      'Platform': Platform.operatingSystem,
      'OS Version': Platform.operatingSystemVersion,
      'Screen Size': '${mq.size.width} x ${mq.size.height}',
      'Pixel Ratio': '${mq.devicePixelRatio}',
      'Orientation': mq.orientation.name,
      'Locale': Localizations.localeOf(context).toLanguageTag(),
    };

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children:
                info.entries.map((e) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(e.value),
                      const Divider(),
                    ],
                  );
                }).toList(),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Export'),
              onPressed: () {
                String shareData = '';

                for (var element in info.entries) {
                  shareData += '${element.key} : ${element.value}\n';
                }
                FlutterDevToolkit.logger.log(
                  '📤 Exported Device Info:\n$shareData',
                );
                ShareParams shareParams = ShareParams(
                  text: shareData,
                  subject: name,
                );
                SharePlus.instance.share(shareParams);
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
      ],
    );
  }
}
