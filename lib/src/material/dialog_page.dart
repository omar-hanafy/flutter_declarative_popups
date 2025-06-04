import 'package:flutter/material.dart';

/// A page that displays a dialog when pushed onto the Navigator.
///
/// This allows dialogs to be used with declarative navigation patterns
/// like Navigator 2.0 and go_router.
///
/// Example usage:
/// ```dart
/// Navigator.of(context).push(
///   DialogPage(
///     builder: (context) => AlertDialog(
///       title: Text('Hello'),
///       content: Text('This is a dialog as a route!'),
///       actions: [
///         TextButton(
///           onPressed: () => Navigator.of(context).pop(),
///           child: Text('OK'),
///         ),
///       ],
///     ),
///   ).createRoute(context),
/// );
/// ```
class DialogPage<T> extends Page<T> {
  const DialogPage({
    required this.builder,
    this.anchorPoint,
    this.barrierColor,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.useSafeArea = true,
    this.themes,
    this.traversalEdgeBehavior,
    this.animationStyle,
    this.requestFocus,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// The widget builder that creates the dialog content
  final WidgetBuilder builder;

  /// {@macro flutter.widgets.DisplayFeatureSubScreen.anchorPoint}
  final Offset? anchorPoint;

  /// The color to use for the modal barrier. If this is null, the barrier will
  /// be transparent.
  final Color? barrierColor;

  /// Whether you can dismiss this dialog by tapping the modal barrier.
  final bool barrierDismissible;

  /// The semantic label used for a dismissible barrier.
  final String? barrierLabel;

  /// Whether to apply a [SafeArea] wrapper to the dialog.
  final bool useSafeArea;

  /// Themes to be inherited by the dialog.
  final CapturedThemes? themes;

  /// Controls the transfer of focus beyond the first and the last items of the dialog.
  final TraversalEdgeBehavior? traversalEdgeBehavior;

  /// Configures the animation for the dialog.
  final AnimationStyle? animationStyle;

  /// Whether the route should request focus when opened.
  final bool? requestFocus;

  @override
  Route<T> createRoute(BuildContext context) {
    // If no barrier label is provided, use the default from Material localizations
    final effectiveBarrierLabel = barrierLabel ??
        (barrierDismissible
            ? MaterialLocalizations.of(context).modalBarrierDismissLabel
            : null);

    return _DialogRoute<T>(
      context: context,
      builder: builder,
      themes: themes,
      barrierColor: barrierColor ?? Colors.black54,
      barrierDismissible: barrierDismissible,
      barrierLabel: effectiveBarrierLabel,
      useSafeArea: useSafeArea,
      settings: this,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
      animationStyle: animationStyle,
      requestFocus: requestFocus,
    );
  }
}

/// Internal dialog route used by DialogPage
class _DialogRoute<T> extends DialogRoute<T> {
  _DialogRoute({
    required super.context,
    required super.builder,
    super.themes,
    super.barrierColor,
    super.barrierDismissible,
    super.barrierLabel,
    super.useSafeArea,
    super.settings,
    super.anchorPoint,
    super.traversalEdgeBehavior,
    super.animationStyle,
    super.requestFocus,
  });
}
