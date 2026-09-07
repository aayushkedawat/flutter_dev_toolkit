import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_dev_toolkit/core/device_info_store.dart';

import '../../core/platform_probe.dart' as platform;

class DeviceInfoTab extends StatefulWidget {
  const DeviceInfoTab({super.key});
  @override
  State<DeviceInfoTab> createState() => _DeviceInfoTabState();
}

class _DeviceInfoTabState extends State<DeviceInfoTab> {
  Map<String, dynamic> info = {};

  Future<void> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final collected = <String, dynamic>{};

    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      collected['Browser'] = webInfo.browserName.name;
      collected['User Agent'] = webInfo.userAgent ?? 'Unknown';
      collected['Platform'] = webInfo.platform ?? 'Unknown';
      collected['Vendor'] = webInfo.vendor ?? 'Unknown';
      collected['Hardware Concurrency'] = webInfo.hardwareConcurrency;
    } else if (platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      collected['Available RAM'] = androidInfo.availableRamSize;
      collected['Total RAM'] = androidInfo.physicalRamSize;
      collected['Device'] = androidInfo.device;
      collected['Is Low RAM device'] = androidInfo.isLowRamDevice;
      collected['Is Physical Device'] = androidInfo.isPhysicalDevice;
      collected['Model'] = androidInfo.model;
      collected['Name'] = androidInfo.name;
      collected['Product'] = androidInfo.product;
    } else if (platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      collected['Available RAM'] = '${iosInfo.availableRamSize} MB';
      collected['Total RAM'] = '${iosInfo.physicalRamSize} MB';
      collected['Is Physical Device'] = iosInfo.isPhysicalDevice;
      collected['Model Name'] = iosInfo.modelName;
      collected['OS Name'] = iosInfo.systemName;
      collected['OS Version'] = iosInfo.systemVersion;
    }

    // The awaits above mean this State may have been disposed by now; touching
    // an inherited widget after that would throw.
    if (!mounted) return;

    final mq = MediaQuery.of(context);
    collected.addAll({
      'Platform': kIsWeb ? 'web' : platform.operatingSystem,
      if (!kIsWeb) 'OS Version': platform.operatingSystemVersion,
      'Screen Size':
          '${mq.size.width.toStringAsFixed(2)} x ${mq.size.height.toStringAsFixed(2)}',
      'Pixel Ratio': mq.devicePixelRatio.toStringAsFixed(2),
      'Orientation': mq.orientation.name,
      'Locale': Localizations.localeOf(context).toLanguageTag(),
    });

    // Rebuilt wholesale on every call (e.g. a rotation), so the export store
    // must be cleared first — otherwise every recompute piled another copy of
    // every key on top of the last.
    DeviceInfoLogStore.clear();
    collected.forEach((key, value) {
      DeviceInfoLogStore.add(
        DeviceInfoModel(key: key, value: value.toString()),
      );
    });

    setState(() => info = collected);
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
