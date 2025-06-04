// Copyright (c) 2025. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

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
/// To enable state restoration for dialogs, provide a [restorationId]:
///
/// ```dart
/// RawDialogPage<void>(
///   restorationId: 'my_dialog',
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
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
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
  /// If this is null, the barrier will be transparent. The default is
  /// a semi-transparent black (Color(0x80000000)).
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
  final TraversalEdgeBehavior? traversalEdgeBehavior;

  /// Controls directional focus traversal behavior at the route boundary.
  ///
  /// If null, uses the Navigator's
  /// routeDirectionalTraversalEdgeBehavior.
  final TraversalEdgeBehavior? directionalTraversalEdgeBehavior;

  /// Whether the route should request focus when shown.
  ///
  /// If null, uses the Navigator's default behavior.
  final bool? requestFocus;

  @override
  Route<T> createRoute(BuildContext context) {
    return RawDialogRoute<T>(
      pageBuilder: pageBuilder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? const Color(0x80000000),
      barrierLabel: barrierLabel,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
      settings: this,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
      directionalTraversalEdgeBehavior: directionalTraversalEdgeBehavior,
      requestFocus: requestFocus,
    );
  }

  @override
  bool canUpdate(Page<dynamic> other) {
    return other.runtimeType == runtimeType && other.key == key;
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
