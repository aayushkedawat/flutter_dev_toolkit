import '../models/built_in_plugin_type.dart';
import 'logger_interface.dart';

class DevToolkitConfig {
  final LoggerInterface logger;
  final List<BuiltInPluginType> disableBuiltInPlugins;

  DevToolkitConfig({
    required this.logger,
    this.disableBuiltInPlugins = const [],
  });
}
