import 'package:share_plus/share_plus.dart';

class ExportUtil {
  static exportData({required String text, required String title}) {
    ShareParams shareParams = ShareParams(title: title, text: text);
    SharePlus.instance.share(shareParams);
  }
}
