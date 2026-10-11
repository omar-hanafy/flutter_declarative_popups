// Copyright (c) 2025-2026. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_declarative_popups/src/utils/page_route.dart';

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
    this.fullscreenDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.canPop,
    super.onPopInvoked,
  });

  /// Creates a [DialogPage] with themes captured from the given [context].
  ///
  /// This factory constructor automatically captures inherited themes from
  /// the provided context and applies them to the dialog.
  factory DialogPage.withContext({
    required BuildContext context,
    required WidgetBuilder builder,
    Offset? anchorPoint,
    Color? barrierColor,
    bool barrierDismissible = true,
    String? barrierLabel,
    bool useSafeArea = true,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    AnimationStyle? animationStyle,
    bool? requestFocus,
    bool fullscreenDialog = false,
    bool canPop = true,
    PopInvokedWithResultCallback<T>? onPopInvoked,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    final themes = InheritedTheme.capture(
      from: context,
      to: Navigator.of(context).context,
    );
    return DialogPage(
      builder: builder,
      anchorPoint: anchorPoint,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      themes: themes,
      traversalEdgeBehavior: traversalEdgeBehavior,
      animationStyle: animationStyle,
      requestFocus: requestFocus,
      fullscreenDialog: fullscreenDialog,
      canPop: canPop,
      onPopInvoked: onPopInvoked ?? (bool didPop, T? result) {},
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
    );
  }

  /// The widget builder that creates the dialog content
  final WidgetBuilder builder;

  /// {@macro flutter.widgets.DisplayFeatureSubScreen.anchorPoint}
  final Offset? anchorPoint;

  /// The color to use for the modal barrier.
  ///
  /// Defaults to the dialog theme's barrier color, then [Colors.black54]. Use
  /// [Colors.transparent] for a transparent barrier.
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
  ///
  /// Defaults to [TraversalEdgeBehavior.closedLoop]. Changing the effective
  /// policy replaces the route and its content state, because the SDK's
  /// existing focus scope retains the policy it was initialized with.
  final TraversalEdgeBehavior? traversalEdgeBehavior;

  /// Configures the animation for the dialog.
  final AnimationStyle? animationStyle;

  /// Whether the route should request focus when opened.
  final bool? requestFocus;

  /// Whether this route represents a full-screen dialog.
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    return _DialogRoute<T>(page: this, context: context);
  }

  @override
  bool canUpdate(Page<dynamic> other) =>
      super.canUpdate(other) &&
      (traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop) ==
          ((other as DialogPage<T>).traversalEdgeBehavior ??
              TraversalEdgeBehavior.closedLoop);
}

/// Internal dialog route used by DialogPage
class _DialogRoute<T> extends DialogRoute<T>
    with PopupPageRoute<T, DialogPage<T>> {
  _DialogRoute({required DialogPage<T> page, required super.context})
    : _defaultBarrierColor =
          DialogTheme.of(context).barrierColor ??
          Theme.of(context).dialogTheme.barrierColor ??
          Colors.black54,
      _defaultBarrierLabel = MaterialLocalizations.of(context)
          .modalBarrierDismissLabel,
      super(
        settings: page,
        useSafeArea: false,
        builder: (context) =>
            (ModalRoute.of(context)! as _DialogRoute<T>)._buildContent(context),
      );

  final Color _defaultBarrierColor;
  final String _defaultBarrierLabel;
  CurvedAnimation? _fadeAnimation;

  Widget _buildContent(BuildContext context) {
    Widget content = preserveContent(Builder(builder: page.builder));
    content = page.themes?.wrap(content) ?? content;
    return page.useSafeArea ? SafeArea(child: content) : content;
  }

  @override
  Color get barrierColor => page.barrierColor ?? _defaultBarrierColor;

  @override
  bool get barrierDismissible => page.barrierDismissible;

  @override
  String get barrierLabel => page.barrierLabel ?? _defaultBarrierLabel;

  @override
  Offset? get anchorPoint => page.anchorPoint;

  @override
  TraversalEdgeBehavior get traversalEdgeBehavior =>
      page.traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop;

  @override
  bool get requestFocus => page.requestFocus ?? super.requestFocus;

  @override
  bool get fullscreenDialog => page.fullscreenDialog;

  @override
  Duration get transitionDuration =>
      page.animationStyle?.duration ?? const Duration(milliseconds: 150);

  @override
  Duration get reverseTransitionDuration =>
      page.animationStyle?.reverseDuration ?? transitionDuration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve = page.animationStyle?.curve ?? Curves.easeOut;
    final reverseCurve = page.animationStyle?.reverseCurve ?? Curves.easeOut;
    if (_fadeAnimation?.parent != animation ||
        _fadeAnimation?.curve != curve ||
        _fadeAnimation?.reverseCurve != reverseCurve) {
      _fadeAnimation?.dispose();
      _fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: curve,
        reverseCurve: reverseCurve,
      );
    }
    return FadeTransition(opacity: _fadeAnimation!, child: child);
  }

  @override
  void dispose() {
    _fadeAnimation?.dispose();
    super.dispose();
  }
}
