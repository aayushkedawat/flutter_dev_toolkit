import 'package:flutter/material.dart';

/// A category attached to a log entry, used by the Logs tab's tag filter
/// and to pick each entry's icon/color.
enum LogTag {
  /// App lifecycle transitions (backgrounded, resumed, …).
  lifecycle,

  /// Navigation events recorded by the route interceptor.
  route,

  /// Network request/response activity.
  network,

  /// Anything logged directly by the consumer app via
  /// `FlutterDevToolkit.logger.log`.
  custom;

  /// The icon the Logs tab shows next to entries carrying this tag.
  IconData get icon => switch (this) {
    LogTag.lifecycle => Icons.favorite,
    LogTag.route => Icons.alt_route,
    LogTag.network => Icons.wifi,
    LogTag.custom => Icons.code,
  };

  /// The color the Logs tab uses to render this tag's chip and icon.
  Color get color => switch (this) {
    LogTag.lifecycle => Colors.purple,
    LogTag.route => Colors.blue,
    LogTag.network => Colors.teal,
    LogTag.custom => Colors.grey,
  };
}
