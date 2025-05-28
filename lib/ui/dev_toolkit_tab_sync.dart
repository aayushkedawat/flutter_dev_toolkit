import 'package:flutter/material.dart';
import '../flutter_dev_toolkit.dart';

/// Keeps the DevToolkit plugin state in sync with the selected tab.
class DevToolkitTabControllerSync extends StatefulWidget {
  final int baseTabCount;
  final Widget child;

  const DevToolkitTabControllerSync({
    super.key,
    required this.baseTabCount,
    required this.child,
  });

  @override
  State<DevToolkitTabControllerSync> createState() =>
      _DevToolkitTabControllerSyncState();
}

class _DevToolkitTabControllerSyncState
    extends State<DevToolkitTabControllerSync> {
  TabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final controller = DefaultTabController.of(context);
    if (_controller != controller) {
      _controller?.removeListener(_syncPlugin);
      _controller = controller;
      _controller?.addListener(_syncPlugin);
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncPlugin());
    }
  }

  void _syncPlugin() {
    if (!mounted || _controller == null) return;
    final index = _controller!.index;

    if (index >= widget.baseTabCount) {
      final plugin = FlutterDevToolkit.plugins[index - widget.baseTabCount];
      FlutterDevToolkit.setActivePlugin(plugin);
    } else {
      FlutterDevToolkit.setActivePlugin(null);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_syncPlugin);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
