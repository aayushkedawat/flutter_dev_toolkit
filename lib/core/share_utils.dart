import 'package:share_plus/share_plus.dart';

/// Shares exported text (JSON, HAR, cURL, …) via the platform share sheet.
class ExportUtil {
  /// Opens the share sheet for [text], with [title] as the share dialog's
  /// title where the platform supports one.
  static void exportData({required String text, required String title}) {
    ShareParams shareParams = ShareParams(title: title, text: text);
    SharePlus.instance.share(shareParams);
  }
}
