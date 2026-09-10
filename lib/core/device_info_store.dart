/// One key/value row shown in the Device Info tab.
class DeviceInfoModel {
  /// The property's label (e.g. `'Model'`, `'OS Version'`).
  final String key;

  /// The property's value, already formatted as text.
  final String value;

  /// Creates a device info row.
  DeviceInfoModel({required this.key, required this.value});

  /// Serializes this row as a single-entry map, keyed by [key].
  Map<String, dynamic> toJson() {
    return {key: value};
  }
}

/// In-memory buffer of device info rows, feeding the Device Info tab.
///
/// Rebuilt on each visit to the tab, so [clear] is called first to avoid
/// accumulating duplicates; capped at 500 rows.
class DeviceInfoLogStore {
  static final List<DeviceInfoModel> _logs = [];

  /// Records a device info row, dropping the oldest once the store holds
  /// more than 500.
  static void add(DeviceInfoModel log) {
    _logs.add(log);
    if (_logs.length > 500) _logs.removeAt(0); // limit
  }

  /// All recorded rows, oldest first.
  static List<DeviceInfoModel> get logs => List.unmodifiable(_logs);

  /// Discards every recorded row.
  static void clear() => _logs.clear();
}
