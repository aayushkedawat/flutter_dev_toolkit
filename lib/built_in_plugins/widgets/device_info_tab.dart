import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_dev_toolkit/core/device_info_store.dart';

class DeviceInfoTab extends StatefulWidget {
  const DeviceInfoTab({Key? key}) : super(key: key);
  @override
  State<DeviceInfoTab> createState() => _DeviceInfoTabState();
}

class _DeviceInfoTabState extends State<DeviceInfoTab> {
  Map<String, dynamic> info = {};
  @override
  void initState() {
    super.initState();
  }

  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      info['Available RAM'] = androidInfo.availableRamSize;
      info['Total RAM'] = androidInfo.physicalRamSize;
      info['Device'] = androidInfo.device;
      info['Is Low RAM device'] = androidInfo.isLowRamDevice;
      info['Is Physical Device'] = androidInfo.isPhysicalDevice;
      info['Model'] = androidInfo.model;
      info['Name'] = androidInfo.name;
      info['Product'] = androidInfo.product;
    }

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      info['Available RAM'] = '${iosInfo.availableRamSize} MB';
      info['Total RAM'] = '${iosInfo.physicalRamSize} MB';
      info['Is Physical Device'] = iosInfo.isPhysicalDevice;
      info['Model Name'] = iosInfo.modelName;
      info['OS Name'] = iosInfo.systemName;
      info['OS Version'] = iosInfo.systemVersion;
    }
    final mq = MediaQuery.of(context);
    info.addAll({
      'Platform': Platform.operatingSystem,
      'OS Version': Platform.operatingSystemVersion,
      'Screen Size':
          '${mq.size.width.toStringAsFixed(2)} x ${mq.size.height.toStringAsFixed(2)}',
      'Pixel Ratio': '${mq.devicePixelRatio.toStringAsFixed(2)}',
      'Orientation': mq.orientation.name,
      'Locale': Localizations.localeOf(context).toLanguageTag(),
    });
    info.forEach((key, value) {
      DeviceInfoLogStore.add(
        DeviceInfoModel(key: key, value: value.toString()),
      );
    });

    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
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
                      Text(e.value.toString()),
                      const Divider(),
                    ],
                  );
                }).toList(),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [const SizedBox(width: 12)],
        ),
      ],
    );
  }
}
