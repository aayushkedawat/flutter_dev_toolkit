import 'package:flutter/material.dart';

enum LogTag {
  lifecycle,
  route,
  network,
  custom;

  IconData get icon => switch (this) {
    LogTag.lifecycle => Icons.favorite,
    LogTag.route => Icons.alt_route,
    LogTag.network => Icons.wifi,
    LogTag.custom => Icons.code,
  };

  Color get color => switch (this) {
    LogTag.lifecycle => Colors.purple,
    LogTag.route => Colors.blue,
    LogTag.network => Colors.teal,
    LogTag.custom => Colors.grey,
  };
}
