// Copyright (c) 2025-2026. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_declarative_popups/src/utils/page_route.dart';

/// A page-based implementation of [RawDialogRoute] that can be used with
/// Navigator 2.0 and declarative routing.
///
/// This page provides a way to show custom dialogs using the page-based
/// navigation API, which enables better integration with Navigator 2.0,
/// deep linking, and state restoration.
///
/// Unlike DialogPage which is Material-specific, [RawDialogPage] provides
/// a bare-bones dialog implementation that allows for complete customization
/// of the dialog's appearance and behavior.
///
/// ## Example
///
/// ```dart
/// Navigator.of(context).push<String>(
///   RawDialogPage<String>(
///     pageBuilder: (context, animation, secondaryAnimation) {
///       return Center(
///         child: Container(
///           width: 300,
///           height: 200,
///           color: Colors.white,
///           child: Center(
///             child: TextButton(
///               onPressed: () => Navigator.of(context).pop('Result'),
///               child: Text('Close Dialog'),
///             ),
///           ),
///         ),
///       );
///     },
///     barrierLabel: 'Dismiss',
///   ).createRoute(context),
/// );
/// ```
///
/// ## State Restoration
///
/// Provide a [restorationId] to make the page's route restorable. The app and
/// [Navigator] also need restoration scopes, and the owner of the `pages` list
/// must restore the state that includes this page. A page's restoration ID
/// alone does not reconstruct the list after the app is restarted.
///
/// A page in the restored list can use:
///
/// ```dart
/// RawDialogPage<void>(
///   restorationId: 'my_dialog',
///   barrierLabel: 'Dismiss',
///   pageBuilder: (context, animation, secondaryAnimation) {
///     return MyDialogWidget();
///   },
/// )
/// ```
///
/// See also:
///
///  * [RawDialogRoute], the underlying route implementation
///  * [showGeneralDialog], for showing dialogs imperatively
///  * DialogPage, for Material Design dialogs
///  * CupertinoModalPopupPage, for iOS-style popups
@immutable
class RawDialogPage<T> extends Page<T> {
  /// Creates a page that shows a custom dialog.
  ///
  /// The [pageBuilder] argument must not be null and is used to build the
  /// primary content of the dialog.
  ///
  /// The [barrierLabel] argument is required when [barrierDismissible] is true
  /// for accessibility purposes.
  const RawDialogPage({
    required this.pageBuilder,
    this.barrierDismissible = true,
    this.barrierColor,
    this.barrierLabel,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.transitionBuilder,
    this.anchorPoint,
    this.traversalEdgeBehavior,
    this.directionalTraversalEdgeBehavior,
    this.requestFocus,
    this.fullscreenDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.canPop,
    super.onPopInvoked,
  }) : assert(
         !barrierDismissible || barrierLabel != null,
         'A barrierLabel must be provided when barrierDismissible is true',
       );

  /// Builds the primary content of the route.
  ///
  /// The arguments have the following meanings:
  ///
  ///  * `context`: The context in which the route is being built.
  ///  * `animation`: The animation for this route's transition. When entering,
  ///    the animation runs forward from 0.0 to 1.0. When exiting, this
  ///    animation runs backwards from 1.0 to 0.0.
  ///  * `secondaryAnimation`: The animation for the route being pushed on top
  ///    of this route. This animation lets this route coordinate with the
  ///    entrance and exit transition of routes pushed on top of this route.
  final RoutePageBuilder pageBuilder;

  /// Whether the dialog can be dismissed by tapping on the barrier.
  ///
  /// If true, tapping on the barrier will pop the dialog and return null.
  /// If false, tapping on the barrier has no effect.
  ///
  /// Defaults to true.
  final bool barrierDismissible;

  /// The color to use for the modal barrier.
  ///
  /// Defaults to a semi-transparent black (Color(0x80000000)). Use
  /// [Colors.transparent] for a transparent barrier.
  ///
  /// The color is animated from transparent to the specified color when
  /// the dialog is shown, and back to transparent when dismissed.
  final Color? barrierColor;

  /// The semantic label for the barrier.
  ///
  /// This is announced by screen readers when the barrier is tapped while
  /// [barrierDismissible] is true.
  ///
  /// This must be provided if [barrierDismissible] is true.
  final String? barrierLabel;

  /// The duration of the transition animation.
  ///
  /// This controls how long it takes for the dialog to animate in and out.
  ///
  /// Defaults to 200 milliseconds.
  final Duration transitionDuration;

  /// Optional custom transition builder.
  ///
  /// If not provided, a simple fade transition is used.
  ///
  /// The `child` parameter in the builder is the widget returned by
  /// [pageBuilder].
  final RouteTransitionsBuilder? transitionBuilder;

  /// The anchor point for positioning the dialog when using multiple displays.
  ///
  /// When a DisplayFeature splits the screen, the dialog will appear in
  /// the sub-screen that contains this anchor point.
  ///
  /// If null, the dialog positioning depends on the Directionality:
  /// - For LTR: Top-left (Offset.zero)
  /// - For RTL: Top-right (Offset(double.maxFinite, 0))
  final Offset? anchorPoint;

  /// Controls focus traversal behavior at the route boundary.
  ///
  /// If null, uses the Navigator's routeTraversalEdgeBehavior.
  /// Changing this policy replaces the route and its content state so that
  /// the SDK initializes a new focus scope with the requested policy.
  final TraversalEdgeBehavior? traversalEdgeBehavior;

  /// Controls directional focus traversal behavior at the route boundary.
  ///
  /// If null, uses the Navigator's
  /// routeDirectionalTraversalEdgeBehavior.
  /// Changing this policy replaces the route and its content state so that
  /// the SDK initializes a new focus scope with the requested policy.
  final TraversalEdgeBehavior? directionalTraversalEdgeBehavior;

  /// Whether the route should request focus when shown.
  ///
  /// If null, uses the Navigator's default behavior.
  final bool? requestFocus;

  /// Whether this route represents a full-screen dialog.
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    return _RawDialogRoute<T>(page: this);
  }

  @override
  bool canUpdate(Page<dynamic> other) {
    if (!super.canUpdate(other)) {
      return false;
    }
    final previous = other as RawDialogPage<T>;
    return traversalEdgeBehavior == previous.traversalEdgeBehavior &&
        directionalTraversalEdgeBehavior ==
            previous.directionalTraversalEdgeBehavior;
  }

  @override
  String toString() {
    return 'RawDialogPage('
        'name: $name, '
        'arguments: $arguments, '
        'restorationId: $restorationId, '
        'barrierDismissible: $barrierDismissible'
        ')';
  }
}

class _RawDialogRoute<T> extends RawDialogRoute<T>
    with PopupPageRoute<T, RawDialogPage<T>> {
  _RawDialogRoute({required RawDialogPage<T> page})
    : super(settings: page, pageBuilder: page.pageBuilder);

  @override
  bool get barrierDismissible => page.barrierDismissible;

  @override
  Color get barrierColor => page.barrierColor ?? const Color(0x80000000);

  @override
  String? get barrierLabel => page.barrierLabel;

  @override
  Duration get transitionDuration => page.transitionDuration;

  @override
  Offset? get anchorPoint => page.anchorPoint;

  @override
  TraversalEdgeBehavior? get traversalEdgeBehavior =>
      page.traversalEdgeBehavior;

  @override
  TraversalEdgeBehavior? get directionalTraversalEdgeBehavior =>
      page.directionalTraversalEdgeBehavior;

  @override
  bool get requestFocus => page.requestFocus ?? super.requestFocus;

  @override
  bool get fullscreenDialog => page.fullscreenDialog;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: DisplayFeatureSubScreen(
        anchorPoint: anchorPoint,
        child: page.pageBuilder(context, animation, secondaryAnimation),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return page.transitionBuilder?.call(
          context,
          animation,
          secondaryAnimation,
          child,
        ) ??
        FadeTransition(opacity: animation, child: child);
  }
}
