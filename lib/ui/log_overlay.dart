import 'package:flutter/material.dart';
import 'log_console.dart';

class DevOverlay extends StatefulWidget {
  const DevOverlay({super.key});

  @override
  State<DevOverlay> createState() => _DevOverlayState();
}

class _DevOverlayState extends State<DevOverlay> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_open) const Positioned.fill(child: DevConsole()),
        Positioned(
          bottom: 32,
          right: 32,
          child: FloatingActionButton(
            child: Icon(_open ? Icons.close : Icons.bug_report),
            onPressed: () {
              setState(() => _open = !_open);
            },
          ),
        ),
      ],
    );
  }
}
