import 'package:flutter/material.dart';

import '../../core/dev_console_theme.dart';
import '../../core/storage_inspector_store.dart';

/// The Storage tab's UI: searchable `SharedPreferences` entries with add,
/// edit, and delete actions.
class StorageTab extends StatefulWidget {
  const StorageTab({super.key});

  @override
  State<StorageTab> createState() => _StorageTabState();
}

class _StorageTabState extends State<StorageTab> {
  String _query = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (!StorageInspectorStore.isLoaded) _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await StorageInspectorStore.refresh();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _confirmDelete(String key) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Entry?'),
            content: Text('This will permanently remove "$key".'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed ?? false) await StorageInspectorStore.remove(key);
  }

  Future<void> _showEditor({StorageEntry? existing}) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _StorageEntryEditor(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: StorageInspectorStore.version,
      builder: (context, _, _) {
        final query = _query.toLowerCase();
        final allEntries = StorageInspectorStore.entries;
        final entries =
            allEntries
                .where(
                  (e) =>
                      e.key.toLowerCase().contains(query) ||
                      e.value.toString().toLowerCase().contains(query),
                )
                .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Search keys or values...',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add entry',
                    icon: const Icon(Icons.add),
                    onPressed: () => _showEditor(),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    icon:
                        _loading
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.refresh),
                    onPressed: _loading ? null : _refresh,
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  !StorageInspectorStore.isLoaded
                      ? const Center(child: CircularProgressIndicator())
                      : entries.isEmpty
                      ? Center(
                        child: Text(
                          allEntries.isEmpty
                              ? 'No SharedPreferences entries yet.'
                              : 'No entries match "$_query".',
                          style: TextStyle(color: palette.faint),
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: entries.length,
                        separatorBuilder:
                            (_, _) =>
                                Divider(height: 1, color: palette.divider),
                        itemBuilder: (context, i) {
                          final entry = entries[i];
                          return ListTile(
                            title: Text(
                              entry.key,
                              style: TextStyle(
                                color: palette.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${_typeLabel(entry.value)} · ${_preview(entry.value)}',
                              style: TextStyle(
                                color: palette.subtle,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _showEditor(existing: entry),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Delete',
                              onPressed: () => _confirmDelete(entry.key),
                            ),
                          );
                        },
                      ),
            ),
          ],
        );
      },
    );
  }
}

String _typeLabel(Object? value) => switch (value) {
  bool _ => 'bool',
  int _ => 'int',
  double _ => 'double',
  String _ => 'String',
  List<String> _ => 'List<String>',
  _ => 'unknown',
};

String _preview(Object? value) =>
    value is List<String> ? value.join(', ') : value.toString();

enum _PrefType { boolean, integer, double_, string, stringList }

extension on _PrefType {
  String get label => switch (this) {
    _PrefType.boolean => 'bool',
    _PrefType.integer => 'int',
    _PrefType.double_ => 'double',
    _PrefType.string => 'String',
    _PrefType.stringList => 'List<String>',
  };
}

_PrefType _prefTypeFromValue(Object? value) => switch (value) {
  bool _ => _PrefType.boolean,
  int _ => _PrefType.integer,
  double _ => _PrefType.double_,
  List<String> _ => _PrefType.stringList,
  _ => _PrefType.string,
};

/// Add/edit dialog for one entry. The key and type are fixed once an entry
/// exists — SharedPreferences has no "change this bool into a string"
/// operation short of removing and re-adding it.
class _StorageEntryEditor extends StatefulWidget {
  const _StorageEntryEditor({this.existing});

  final StorageEntry? existing;

  @override
  State<_StorageEntryEditor> createState() => _StorageEntryEditorState();
}

class _StorageEntryEditorState extends State<_StorageEntryEditor> {
  late final TextEditingController _keyController;
  late final TextEditingController _valueController;
  late _PrefType _type;
  bool _boolValue = false;
  String? _error;
  bool _saving = false;

  bool get _isNew => widget.existing == null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _keyController = TextEditingController(text: existing?.key ?? '');
    _type =
        existing == null
            ? _PrefType.string
            : _prefTypeFromValue(existing.value);

    if (_type == _PrefType.boolean) {
      _boolValue = existing?.value as bool? ?? false;
      _valueController = TextEditingController();
    } else if (_type == _PrefType.stringList) {
      final list = existing?.value as List<String>? ?? const [];
      _valueController = TextEditingController(text: list.join('\n'));
    } else {
      _valueController = TextEditingController(
        text: existing?.value?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Key cannot be empty.');
      return;
    }

    Object value;
    switch (_type) {
      case _PrefType.boolean:
        value = _boolValue;
      case _PrefType.integer:
        final parsed = int.tryParse(_valueController.text.trim());
        if (parsed == null) {
          setState(() => _error = 'Enter a whole number.');
          return;
        }
        value = parsed;
      case _PrefType.double_:
        final parsed = double.tryParse(_valueController.text.trim());
        if (parsed == null) {
          setState(() => _error = 'Enter a number.');
          return;
        }
        value = parsed;
      case _PrefType.string:
        value = _valueController.text;
      case _PrefType.stringList:
        value =
            _valueController.text
                .split('\n')
                .map((line) => line.trim())
                .where((line) => line.isNotEmpty)
                .toList();
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    await StorageInspectorStore.setValue(key, value);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isNew ? 'Add Entry' : 'Edit Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _keyController,
              readOnly: !_isNew,
              decoration: const InputDecoration(labelText: 'Key'),
            ),
            const SizedBox(height: 12),
            if (_isNew)
              DropdownButtonFormField<_PrefType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items:
                    _PrefType.values
                        .map(
                          (t) =>
                              DropdownMenuItem(value: t, child: Text(t.label)),
                        )
                        .toList(),
                onChanged: (t) => setState(() => _type = t ?? _type),
              )
            else
              Text(
                'Type: ${_type.label}',
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 12),
            if (_type == _PrefType.boolean)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Value'),
                value: _boolValue,
                onChanged: (v) => setState(() => _boolValue = v),
              )
            else
              TextField(
                controller: _valueController,
                maxLines: _type == _PrefType.stringList ? 4 : 1,
                keyboardType: switch (_type) {
                  _PrefType.integer => TextInputType.number,
                  _PrefType.double_ => const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  _ => TextInputType.text,
                },
                decoration: InputDecoration(
                  labelText: 'Value',
                  helperText:
                      _type == _PrefType.stringList
                          ? 'One item per line'
                          : null,
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
