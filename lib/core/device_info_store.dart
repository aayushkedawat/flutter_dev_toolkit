class DeviceInfoModel {
  final String key;
  final String value;

  DeviceInfoModel({required this.key, required this.value});

  Map<String, dynamic> toJson() {
    return {key: value};
  }
}

class DeviceInfoLogStore {
  static final List<DeviceInfoModel> _logs = [];

  static void add(DeviceInfoModel log) {
    _logs.add(log);
    if (_logs.length > 500) _logs.removeAt(0); // limit
  }

  static List<DeviceInfoModel> get logs => List.unmodifiable(_logs);

  static void clear() => _logs.clear();
}
