import 'package:flutter/material.dart';

enum DevConsoleTheme { dark, light }

/// The colours the console chrome and tabs paint with.
///
/// Deliberately small: the panels need a background, a raised surface, a
/// divider and three levels of text emphasis. Accent colours (severity reds,
/// status greens) are semantic and stay the same in both themes.
@immutable
class DevConsolePalette {
  final Color background;
  final Color appBar;
  final Color surface;
  final Color divider;
  final Color onSurface;
  final Color subtle;
  final Color faint;
  final Color scrim;

  const DevConsolePalette({
    required this.background,
    required this.appBar,
    required this.surface,
    required this.divider,
    required this.onSurface,
    required this.subtle,
    required this.faint,
    required this.scrim,
  });

  static const DevConsolePalette dark = DevConsolePalette(
    background: Color(0xFF000000),
    appBar: Color(0xDD000000),
    surface: Color(0x1AFFFFFF),
    divider: Color(0x1FFFFFFF),
    onSurface: Color(0xFFFFFFFF),
    subtle: Color(0xB3FFFFFF),
    faint: Color(0x61FFFFFF),
    scrim: Color(0x73000000),
  );

  static const DevConsolePalette light = DevConsolePalette(
    background: Color(0xFFF7F7F8),
    appBar: Color(0xFFE9E9EC),
    surface: Color(0x0F000000),
    divider: Color(0x1F000000),
    onSurface: Color(0xFF16161A),
    subtle: Color(0xB3000000),
    faint: Color(0x73000000),
    scrim: Color(0x40000000),
  );
}

extension DevConsoleThemeX on DevConsoleTheme {
  DevConsolePalette get palette => switch (this) {
    DevConsoleTheme.dark => DevConsolePalette.dark,
    DevConsoleTheme.light => DevConsolePalette.light,
  };

  Brightness get brightness => switch (this) {
    DevConsoleTheme.dark => Brightness.dark,
    DevConsoleTheme.light => Brightness.light,
  };

  ThemeData get themeData {
    final colors = palette;
    final base = switch (this) {
      DevConsoleTheme.dark => ThemeData.dark(),
      DevConsoleTheme.light => ThemeData.light(),
    };

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      dividerColor: colors.divider,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: colors.appBar,
        foregroundColor: colors.onSurface,
      ),
    );
  }
}

/// Shorthand for the active palette, so console widgets can write
/// `palette.subtle` instead of threading a theme through every constructor.
DevConsolePalette get palette => DevConsoleThemeController.palette;

/// Holds the console's active theme.
///
/// Seeded from [DevToolkitConfig.theme] at init and flipped by the toggle in
/// the console app bar. The console listens, so every tab repaints together.
class DevConsoleThemeController {
  static final ValueNotifier<DevConsoleTheme> theme = ValueNotifier(
    DevConsoleTheme.dark,
  );

  static DevConsolePalette get palette => theme.value.palette;

  static void toggle() {
    theme.value =
        theme.value == DevConsoleTheme.dark
            ? DevConsoleTheme.light
            : DevConsoleTheme.dark;
  }
}
