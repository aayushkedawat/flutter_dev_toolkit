import 'package:flutter/material.dart';

class LogTileWidget extends StatelessWidget {
  const LogTileWidget({
    super.key,
    this.prefix,
    this.subTitle,
    required this.title,
    this.suffix,
    this.titleColor,
    this.onTap,
  });
  final Widget? prefix;
  final Widget? suffix;
  final String title;
  final String? subTitle;
  final Color? titleColor;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
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
                        style: TextStyle(color: titleColor ?? Colors.white),
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
      ),
    );
  }
}
