import 'package:flutter/material.dart';

import '../flutter_dev_toolkit.dart';
import '../core/dev_toolkit_plugin.dart';

class DevConsole extends StatefulWidget {
  const DevConsole({super.key});

  @override
  State<DevConsole> createState() => _DevConsoleState();
}

class _DevConsoleState extends State<DevConsole> {
  int _selectedIndex = 0;
  bool _railExpanded = false;

  static const double _collapsedWidth = 56;
  static const double _expandedWidth = 164;

  @override
  void initState() {
    super.initState();
    _syncActivePlugin();
  }

  void _selectPlugin(int index) {
    setState(() => _selectedIndex = index);
    _syncActivePlugin(index: index);
  }

  void _syncActivePlugin({int? index}) {
    final plugins = FlutterDevToolkit.plugins;
    final i = index ?? _selectedIndex;
    if (plugins.isNotEmpty && i < plugins.length) {
      FlutterDevToolkit.setActivePlugin(plugins[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plugins = FlutterDevToolkit.plugins;
    if (plugins.isEmpty) return const SizedBox.shrink();

    final selected = plugins[_selectedIndex];

    return MaterialApp(
      color: Colors.black,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(selected.name),
          backgroundColor: Colors.black87,
          centerTitle: false,
          actions: selected.buildActions(context),
        ),
        body: Row(
          children: [
            _CollapsibleRail(
              plugins: plugins,
              selectedIndex: _selectedIndex,
              expanded: _railExpanded,
              onSelect: _selectPlugin,
              onToggle: () => setState(() => _railExpanded = !_railExpanded),
              collapsedWidth: _collapsedWidth,
              expandedWidth: _expandedWidth,
            ),
            const VerticalDivider(width: 1, thickness: 1, color: Colors.white12),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: plugins.map((p) => p.buildTab(context)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsibleRail extends StatelessWidget {
  final List<DevToolkitPlugin> plugins;
  final int selectedIndex;
  final bool expanded;
  final ValueChanged<int> onSelect;
  final VoidCallback onToggle;
  final double collapsedWidth;
  final double expandedWidth;

  const _CollapsibleRail({
    required this.plugins,
    required this.selectedIndex,
    required this.expanded,
    required this.onSelect,
    required this.onToggle,
    required this.collapsedWidth,
    required this.expandedWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: expanded ? expandedWidth : collapsedWidth,
      color: const Color(0xFF111111),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: plugins.length,
              itemBuilder: (_, i) => _RailItem(
                icon: plugins[i].icon,
                label: plugins[i].name,
                selected: i == selectedIndex,
                expanded: expanded,
                onTap: () => onSelect(i),
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          // Expand / collapse toggle
          SizedBox(
            height: 48,
            child: InkWell(
              onTap: onToggle,
              child: Row(
                mainAxisAlignment: expanded
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.center,
                children: [
                  if (expanded)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Text(
                        'Collapse',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(right: expanded ? 8 : 0),
                    child: Icon(
                      expanded
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                      color: Colors.white38,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.blueAccent : Colors.white54;

    return Tooltip(
      message: expanded ? '' : label,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          decoration: BoxDecoration(
            color: selected ? Colors.blueAccent.withAlpha(30) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: selected ? Colors.blueAccent : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: Icon(icon, color: color, size: 20),
              ),
              if (expanded)
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
