import 'package:flutter/material.dart';

import '../core/default_logger.dart';
import '../flutter_dev_toolkit.dart';
import 'log_console.dart';

/// The draggable floating action button that opens/closes the console.
/// Stack it above your app via `MaterialApp.builder`; renders nothing when
/// `FlutterDevToolkit.isEnabled` is false.
class DevOverlay extends StatefulWidget {
  const DevOverlay({super.key});

  @override
  State<DevOverlay> createState() => _DevOverlayState();
}

class _DevOverlayState extends State<DevOverlay> {
  bool _open = false;

  // FAB drag position — starts bottom-right, user can drag anywhere.
  double _dx = 0;
  double _dy = 0;
  bool _positionInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_positionInitialized) {
      final size = MediaQuery.of(context).size;
      _dx = size.width - 80;
      _dy = size.height - 120;
      _positionInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Respect the enableInRelease flag — render nothing if toolkit is disabled.
    if (!FlutterDevToolkit.isEnabled) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        if (_open) const Positioned.fill(child: DevConsole()),
        Positioned(
          left: _dx.clamp(0, size.width - 64),
          top: _dy.clamp(0, size.height - 64),
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _dx = (_dx + details.delta.dx).clamp(0, size.width - 64);
                _dy = (_dy + details.delta.dy).clamp(0, size.height - 64);
              });
            },
            child: _BadgedFab(
              open: _open,
              onTap: () => setState(() => _open = !_open),
            ),
          ),
        ),
      ],
    );
  }
}

/// FAB with an auto-updating red badge showing the error count for the session.
class _BadgedFab extends StatelessWidget {
  final bool open;
  final VoidCallback onTap;

  const _BadgedFab({required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: DefaultLogger.errorCount,
      builder: (_, errorCount, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            FloatingActionButton(
              heroTag: 'dev_toolkit_fab',
              backgroundColor:
                  open ? Colors.red.shade700 : Colors.blueGrey.shade800,
              onPressed: onTap,
              child: Icon(
                open ? Icons.close : Icons.bug_report,
                color: Colors.white,
              ),
            ),
            if (!open && errorCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    errorCount > 99 ? '99+' : '$errorCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
