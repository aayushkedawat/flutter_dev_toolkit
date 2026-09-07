import 'package:flutter/material.dart';

import '../../core/dev_console_theme.dart';
import '../../interceptors/network/network_mock_rule.dart';
import '../../interceptors/network/network_mock_store.dart';

/// Config panel for the Network plugin, opened via the "tune" icon in the
/// console app bar. Manages mock rules that short-circuit a matching request
/// with a canned response instead of letting it reach the network.
class NetworkMockPanel extends StatelessWidget {
  const NetworkMockPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NetworkMockStore.version,
      builder: (context, _, _) {
        final rules = NetworkMockStore.rules;
        return Container(
          constraints: const BoxConstraints(maxHeight: 260),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MOCK RULES',
                    style: TextStyle(
                      color: palette.subtle,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showEditor(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Rule'),
                  ),
                ],
              ),
              if (rules.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No mock rules. Requests reach the network as usual.',
                    style: TextStyle(color: palette.faint, fontSize: 12),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: rules.length,
                    itemBuilder: (context, i) {
                      final rule = rules[i];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Switch(
                          value: rule.enabled,
                          onChanged:
                              (v) => NetworkMockStore.updateAt(
                                i,
                                rule.copyWith(enabled: v),
                              ),
                        ),
                        title: Text(
                          '${rule.method ?? 'ANY'} contains "${rule.urlContains}"',
                          style: TextStyle(
                            color: palette.onSurface,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          'Status ${rule.statusCode}'
                          '${rule.delay > Duration.zero ? ' · ${rule.delay.inMilliseconds}ms delay' : ''}',
                          style: TextStyle(color: palette.faint, fontSize: 11),
                        ),
                        onTap:
                            () =>
                                _showEditor(context, index: i, existing: rule),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () => NetworkMockStore.removeAt(i),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditor(
    BuildContext context, {
    int? index,
    NetworkMockRule? existing,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => _MockRuleEditor(index: index, existing: existing),
    );
  }
}

class _MockRuleEditor extends StatefulWidget {
  const _MockRuleEditor({this.index, this.existing});

  final int? index;
  final NetworkMockRule? existing;

  @override
  State<_MockRuleEditor> createState() => _MockRuleEditorState();
}

class _MockRuleEditorState extends State<_MockRuleEditor> {
  static const _methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'];

  late final TextEditingController _urlController;
  late final TextEditingController _statusController;
  late final TextEditingController _bodyController;
  late final TextEditingController _delayController;
  String? _method;

  bool get _isNew => widget.existing == null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _urlController = TextEditingController(text: existing?.urlContains ?? '');
    _statusController = TextEditingController(
      text: (existing?.statusCode ?? 200).toString(),
    );
    _bodyController = TextEditingController(text: existing?.responseBody ?? '');
    _delayController = TextEditingController(
      text: (existing?.delay.inMilliseconds ?? 0).toString(),
    );
    _method = existing?.method;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _statusController.dispose();
    _bodyController.dispose();
    _delayController.dispose();
    super.dispose();
  }

  void _save() {
    final urlContains = _urlController.text.trim();
    if (urlContains.isEmpty) return;

    final rule = NetworkMockRule(
      urlContains: urlContains,
      method: _method,
      statusCode: int.tryParse(_statusController.text.trim()) ?? 200,
      responseBody: _bodyController.text,
      delay: Duration(
        milliseconds: int.tryParse(_delayController.text.trim()) ?? 0,
      ),
      enabled: widget.existing?.enabled ?? true,
    );

    if (widget.index != null) {
      NetworkMockStore.updateAt(widget.index!, rule);
    } else {
      NetworkMockStore.add(rule);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isNew ? 'Add Mock Rule' : 'Edit Mock Rule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'URL contains',
                helperText:
                    'e.g. /api/users — matches any URL with this substring',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _method,
              decoration: const InputDecoration(labelText: 'Method'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Any')),
                for (final m in _methods)
                  DropdownMenuItem(value: m, child: Text(m)),
              ],
              onChanged: (v) => setState(() => _method = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _statusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Status code'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Response body'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _delayController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Delay (ms)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
