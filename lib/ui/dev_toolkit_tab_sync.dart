import 'package:flutter/material.dart';
import '../flutter_dev_toolkit.dart';

/// Keeps the DevToolkit plugin state in sync with the selected tab.
class DevToolkitTabControllerSync extends StatefulWidget {
  /// How many tabs precede the plugin tabs in the enclosing `TabBar`. A
  /// selected index below this count means a non-plugin tab is active.
  final int baseTabCount;

  /// The subtree containing the `DefaultTabController` to observe.
  final Widget child;

  /// Wraps [child], syncing `FlutterDevToolkit`'s active plugin to whichever
  /// tab past [baseTabCount] is selected.
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
