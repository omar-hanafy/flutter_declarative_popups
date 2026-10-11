import 'package:flutter/cupertino.dart';

/// Resolves barrier colors using the traits captured when a route is created.
///
/// Like Flutter's Cupertino popup helpers, resolution uses the caller's local
/// brightness, accessibility contrast, and interface level. Retaining only those
/// values lets later page colors resolve after the caller's context is unmounted.
class CupertinoPopupColorResolver {
  CupertinoPopupColorResolver(BuildContext context)
    : _traits = _ColorTraits.fromContext(context);

  final _ColorTraits _traits;

  /// Preserves null and ordinary colors, and selects a dynamic color's variant.
  ///
  /// If the selected variant is itself dynamic, Flutter uses that variant's
  /// existing effective color rather than resolving it recursively. Copying its
  /// components preserves that behavior and its color space without retaining a
  /// dynamic color's debug context.
  Color? resolve(Color? color) {
    if (color is! CupertinoDynamicColor) {
      return color;
    }
    final selected = switch ((
      _traits.brightness,
      _traits.level,
      _traits.highContrast,
    )) {
      (Brightness.light, CupertinoUserInterfaceLevelData.base, false) =>
        color.color,
      (Brightness.light, CupertinoUserInterfaceLevelData.base, true) =>
        color.highContrastColor,
      (Brightness.light, CupertinoUserInterfaceLevelData.elevated, false) =>
        color.elevatedColor,
      (Brightness.light, CupertinoUserInterfaceLevelData.elevated, true) =>
        color.highContrastElevatedColor,
      (Brightness.dark, CupertinoUserInterfaceLevelData.base, false) =>
        color.darkColor,
      (Brightness.dark, CupertinoUserInterfaceLevelData.base, true) =>
        color.darkHighContrastColor,
      (Brightness.dark, CupertinoUserInterfaceLevelData.elevated, false) =>
        color.darkElevatedColor,
      (Brightness.dark, CupertinoUserInterfaceLevelData.elevated, true) =>
        color.darkHighContrastElevatedColor,
    };
    return Color.from(
      alpha: selected.a,
      red: selected.r,
      green: selected.g,
      blue: selected.b,
      colorSpace: selected.colorSpace,
    );
  }
}

class _ColorTraits {
  _ColorTraits.fromContext(BuildContext context)
    : brightness =
          CupertinoTheme.maybeBrightnessOf(context) ?? Brightness.light,
      highContrast = MediaQuery.maybeHighContrastOf(context) ?? false,
      level =
          CupertinoUserInterfaceLevel.maybeOf(context) ??
          CupertinoUserInterfaceLevelData.base;

  final Brightness brightness;
  final bool highContrast;
  final CupertinoUserInterfaceLevelData level;
}
