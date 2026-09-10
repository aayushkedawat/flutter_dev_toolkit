import 'package:flutter/material.dart';

/// The console's color scheme. Set the starting value via
/// `DevToolkitConfig.theme`; flip it at runtime with
/// [DevConsoleThemeController.toggle].
enum DevConsoleTheme {
  /// Dark background, light text — the default.
  dark,

  /// Light background, dark text.
  light,
}

/// The colours the console chrome and tabs paint with.
///
/// Deliberately small: the panels need a background, a raised surface, a
/// divider and three levels of text emphasis. Accent colours (severity reds,
/// status greens) are semantic and stay the same in both themes.
@immutable
class DevConsolePalette {
  /// The console's base background, behind every tab.
  final Color background;

  /// The app bar's background.
  final Color appBar;

  /// Background for raised elements: cards, selected list tiles, panels.
  final Color surface;

  /// Line color for dividers and borders.
  final Color divider;

  /// Primary text/icon color, for the most prominent content.
  final Color onSurface;

  /// Secondary text color, for less prominent labels.
  final Color subtle;

  /// Tertiary text/icon color, for placeholders and disabled-looking content.
  final Color faint;

  /// Overlay color for dimming content behind a config panel or dialog.
  final Color scrim;

  /// Creates a palette. Every color is required — there is no default look
  /// to fall back on, by design, so a new theme can't ship half-styled.
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

  /// The palette used by [DevConsoleTheme.dark].
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

  /// The palette used by [DevConsoleTheme.light].
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

/// Derives the concrete palette, [Brightness], and [ThemeData] for a
/// [DevConsoleTheme] value.
extension DevConsoleThemeX on DevConsoleTheme {
  /// This theme's color palette.
  DevConsolePalette get palette => switch (this) {
    DevConsoleTheme.dark => DevConsolePalette.dark,
    DevConsoleTheme.light => DevConsolePalette.light,
  };

  /// This theme's [Brightness], for widgets that key off it directly.
  Brightness get brightness => switch (this) {
    DevConsoleTheme.dark => Brightness.dark,
    DevConsoleTheme.light => Brightness.light,
  };

  /// A [ThemeData] built from [palette], for the console's `MaterialApp`.
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
/// Seeded from `DevToolkitConfig.theme` at init and flipped by the toggle in
/// the console app bar. The console listens, so every tab repaints together.
class DevConsoleThemeController {
  /// The active theme. Listen to this to repaint when it changes.
  static final ValueNotifier<DevConsoleTheme> theme = ValueNotifier(
    DevConsoleTheme.dark,
  );

  /// The active theme's palette. Shorthand for `theme.value.palette`.
  static DevConsolePalette get palette => theme.value.palette;

  /// Flips [theme] between [DevConsoleTheme.dark] and [DevConsoleTheme.light].
  static void toggle() {
    theme.value =
        theme.value == DevConsoleTheme.dark
            ? DevConsoleTheme.light
            : DevConsoleTheme.dark;
  }
}
