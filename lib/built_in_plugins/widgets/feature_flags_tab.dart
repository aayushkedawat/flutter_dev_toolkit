import 'package:flutter/material.dart';

import '../../core/dev_console_theme.dart';
import '../../core/feature_flag_store.dart';

class FeatureFlagsTab extends StatelessWidget {
  const FeatureFlagsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: FeatureFlagStore.version,
      builder: (context, _, _) {
        final flags = FeatureFlagStore.flags;

        if (flags.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No feature flags registered yet.\n\n'
                'Call FeatureFlagStore.register(FeatureFlag(...)) from your '
                'app to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.faint),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: flags.length,
          separatorBuilder:
              (_, _) => Divider(height: 1, color: palette.divider),
          itemBuilder: (context, i) => _FlagRow(flag: flags[i]),
        );
      },
    );
  }
}

class _FlagRow extends StatelessWidget {
  const _FlagRow({required this.flag});

  final FeatureFlag flag;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Object>(
      valueListenable: flag.notifier,
      builder: (context, value, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flag.label,
                      style: TextStyle(
                        color: palette.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      flag.key,
                      style: TextStyle(color: palette.faint, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildControl(context, value),
              IconButton(
                tooltip: 'Reset to default',
                icon: const Icon(Icons.restart_alt, size: 18),
                onPressed:
                    value == flag.defaultValue ? null : () => flag.reset(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControl(BuildContext context, Object value) {
    switch (flag.type) {
      case FeatureFlagType.boolean:
        return Switch(value: value as bool, onChanged: (v) => flag.value = v);
      case FeatureFlagType.options:
        return DropdownButton<Object>(
          value: value,
          underline: const SizedBox.shrink(),
          items: [
            for (final option in flag.options!)
              DropdownMenuItem(value: option, child: Text(option.toString())),
          ],
          onChanged: (v) {
            if (v != null) flag.value = v;
          },
        );
      case FeatureFlagType.number:
      case FeatureFlagType.string:
        return TextButton(
          onPressed: () => _editValue(context, value),
          child: Text(
            value.toString(),
            style: TextStyle(color: palette.onSurface),
          ),
        );
    }
  }

  Future<void> _editValue(BuildContext context, Object current) async {
    final controller = TextEditingController(text: current.toString());
    final result = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(flag.label),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  flag.type == FeatureFlagType.number
                      ? const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      )
                      : TextInputType.text,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, controller.text),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (result == null) return;

    if (flag.type == FeatureFlagType.number) {
      final parsed = num.tryParse(result);
      if (parsed != null) flag.value = parsed;
    } else {
      flag.value = result;
    }
  }
}
