import 'package:flutter/material.dart';
import '../../core/dev_console_theme.dart';

/// A single row in the Logs tab: an optional leading icon, a title, an
/// optional subtitle, and an optional trailing widget.
class LogTileWidget extends StatelessWidget {
  /// Creates a log tile. Only [title] is required.
  const LogTileWidget({
    super.key,
    this.prefix,
    this.subTitle,
    required this.title,
    this.suffix,
    this.titleColor,
    this.onTap,
  });

  /// Shown before the title, typically a level icon.
  final Widget? prefix;

  /// Shown after the title and subtitle.
  final Widget? suffix;

  /// The log message.
  final String title;

  /// Shown below [title], typically a formatted timestamp.
  final String? subTitle;

  /// Overrides [title]'s color, typically to reflect log level.
  final Color? titleColor;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (prefix != null) prefix!,
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: titleColor ?? palette.onSurface),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (subTitle != null) Text(subTitle!),
                  ],
                ),
              ),
              if (suffix != null) suffix!,
            ],
          ),
        ],
      ),
    );
  }
}
