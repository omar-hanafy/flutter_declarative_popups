// Copyright (c) 2025. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';

/// A page that creates a Cupertino-style modal popup route.
///
/// This page can be used with Navigator 2.0 (declarative API) to show
/// modal popups that slide up from the bottom of the screen, similar
/// to [showCupertinoModalPopup].
///
/// {@tool snippet}
/// This example shows how to use [CupertinoModalPopupPage] with Navigator 2.0:
///
/// ```dart
/// Navigator(
///   pages: [
///     MaterialPage(child: HomeScreen()),
///     if (showActionSheet)
///       CupertinoModalPopupPage<String>(
///         key: ValueKey('action-sheet'),
///         builder: (context) => CupertinoActionSheet(
///           title: Text('Select Option'),
///           actions: [
///             CupertinoActionSheetAction(
///               onPressed: () => Navigator.pop(context, 'delete'),
///               isDestructiveAction: true,
///               child: Text('Delete'),
///             ),
///             CupertinoActionSheetAction(
///               onPressed: () => Navigator.pop(context, 'save'),
///               child: Text('Save'),
///             ),
///           ],
///           cancelButton: CupertinoActionSheetAction(
///             onPressed: () => Navigator.pop(context),
///             child: Text('Cancel'),
///           ),
///         ),
///       ),
///   ],
///   onDidRemovePage: (page) {
///     if (page.key == const ValueKey('action-sheet')) {
///       // Handle removal here
///     }
///   },
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [CupertinoModalPopupRoute], which is the route this page creates.
///  * [showCupertinoModalPopup], which is the imperative API equivalent.
///  * [CupertinoActionSheet], which is typically used as the child widget.
class CupertinoModalPopupPage<T> extends Page<T> {
  /// Creates a page that shows a modal iOS-style popup.
  ///
  /// The [builder] argument must not be null.
  const CupertinoModalPopupPage({
    required this.builder,
    this.barrierLabel = 'Dismiss',
    this.barrierColor = kCupertinoModalBarrierColor,
    this.barrierDismissible = true,
    this.semanticsDismissible = false,
    this.filter,
    this.anchorPoint,
    this.requestFocus,
    this.onBarrierTap,
    this.barrierOnTapHint,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.canPop,
    super.onPopInvoked,
  });

  /// Builds the primary contents of the modal popup.
  ///
  /// The [builder] argument typically builds a [CupertinoActionSheet] widget.
  /// Content below the widget is dimmed with a [ModalBarrier]. The widget built
  /// by the [builder] does not share a context with the route it was originally
  /// built from. Use a [StatefulBuilder] or a custom [StatefulWidget] if the
  /// widget needs to update dynamically.
  final WidgetBuilder builder;

  /// The semantic label used for the modal barrier if it is dismissible.
  ///
  /// It is used by assistive technologies to announce the opening of the barrier.
  /// Defaults to 'Dismiss'.
  final String barrierLabel;

  /// The color to use for the modal barrier.
  ///
  /// If this is null, the barrier will be transparent. Otherwise, the color
  /// will be used to create a semi-transparent barrier. The opacity of the
  /// color is animated when the route is pushed or popped.
  ///
  /// Defaults to [kCupertinoModalBarrierColor].
  final Color? barrierColor;

  /// Whether you can dismiss this route by tapping the modal barrier.
  ///
  /// When this is set to true, tapping outside the popup will cause the
  /// current route to be popped with null as the value.
  ///
  /// Defaults to true.
  final bool barrierDismissible;

  /// Whether the semantics of the modal barrier are included in the
  /// semantics tree.
  ///
  /// By default, modal barriers are excluded from the semantics tree since
  /// they are not interactive. However, when [barrierDismissible] is true,
  /// the modal barrier becomes interactive and should be included in the
  /// semantics tree.
  ///
  /// Defaults to false.
  final bool semanticsDismissible;

  /// The [ImageFilter] to apply to the modal barrier.
  ///
  /// If this is not null, the modal barrier will be blurred by the given
  /// image filter. This allows for effects like frosted glass.
  final ImageFilter? filter;

  /// {@macro flutter.widgets.DisplayFeatureSubScreen.anchorPoint}
  final Offset? anchorPoint;

  /// Whether the route should request focus when pushed.
  ///
  /// {@macro flutter.widgets.navigator.requestFocus}
  final bool? requestFocus;

  /// Called when the barrier is tapped and [barrierDismissible] is true.
  ///
  /// If this is null, the default behavior is to pop the current route
  /// with null as the value. If this is not null, it will be called
  /// instead of the default behavior.
  ///
  /// This can be useful for custom dismissal animations or for preventing
  /// dismissal in certain conditions.
  final VoidCallback? onBarrierTap;

  /// The semantic hint text for the barrier when it is tappable.
  ///
  /// This is announced by screen readers when the user interacts with
  /// the barrier. Only used when [barrierDismissible] is true.
  final String? barrierOnTapHint;

  @override
  Route<T> createRoute(BuildContext context) {
    // If custom barrier handling is provided, use our custom route
    if (onBarrierTap != null || barrierOnTapHint != null) {
      return _CustomCupertinoModalPopupRoute<T>(
        builder: builder,
        settings: this,
        barrierLabel: barrierLabel,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        semanticsDismissible: semanticsDismissible,
        filter: filter,
        anchorPoint: anchorPoint,
        requestFocus: requestFocus,
        onBarrierTap: onBarrierTap,
        barrierOnTapHint: barrierOnTapHint,
      );
    }

    // Otherwise use the standard route
    return CupertinoModalPopupRoute<T>(
      builder: builder,
      settings: this,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      semanticsDismissible: semanticsDismissible,
      filter: filter,
      anchorPoint: anchorPoint,
      requestFocus: requestFocus,
    );
  }
}

/// Custom [CupertinoModalPopupRoute] that supports additional barrier customization.
class _CustomCupertinoModalPopupRoute<T> extends CupertinoModalPopupRoute<T> {
  _CustomCupertinoModalPopupRoute({
    required super.builder,
    required super.barrierLabel,
    super.barrierColor,
    super.barrierDismissible,
    super.semanticsDismissible,
    super.filter,
    super.settings,
    super.anchorPoint,
    super.requestFocus,
    this.onBarrierTap,
    this.barrierOnTapHint,
  });

  /// Custom callback when the barrier is tapped.
  final VoidCallback? onBarrierTap;

  /// Custom semantic hint for the barrier tap action.
  final String? barrierOnTapHint;

  /// Clip details notifier for the modal barrier.
  final ValueNotifier<EdgeInsets> _clipDetailsNotifier =
      ValueNotifier<EdgeInsets>(EdgeInsets.zero);

  @override
  Widget buildModalBarrier() {
    if (barrierColor != null && barrierColor!.a != 0 && !offstage) {
      assert(
        barrierColor != barrierColor!.withValues(alpha: 0),
        'The barrierColor must not be fully transparent when building the modal barrier.',
      );

      final color = animation!.drive(
        ColorTween(
          begin: barrierColor!.withValues(alpha: 0),
          end: barrierColor,
        ).chain(CurveTween(curve: barrierCurve)),
      );

      return AnimatedModalBarrier(
        color: color,
        dismissible: barrierDismissible,
        semanticsLabel: barrierLabel,
        barrierSemanticsDismissible: semanticsDismissible,
        clipDetailsNotifier: _clipDetailsNotifier,
        semanticsOnTapHint: barrierOnTapHint,
        onDismiss: barrierDismissible ? _handleBarrierTap : null,
      );
    } else {
      return ModalBarrier(
        color: barrierColor,
        dismissible: barrierDismissible,
        semanticsLabel: barrierLabel,
        barrierSemanticsDismissible: semanticsDismissible,
        clipDetailsNotifier: _clipDetailsNotifier,
        semanticsOnTapHint: barrierOnTapHint,
        onDismiss: barrierDismissible ? _handleBarrierTap : null,
      );
    }
  }

  void _handleBarrierTap() {
    if (onBarrierTap != null) {
      onBarrierTap!();
    } else if (isCurrent) {
      navigator?.pop();
    }
  }

  @override
  void dispose() {
    _clipDetailsNotifier.dispose();
    super.dispose();
  }
}

// Example usage and additional utilities

/// A convenience widget that shows a modal popup using [CupertinoModalPopupPage].
///
/// This is a declarative wrapper around [CupertinoModalPopupPage] that can be
/// used in widget trees where you want to conditionally show a modal popup.
///
/// {@tool snippet}
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   bool _showModal = false;
///
///   @override
///   Widget build(BuildContext context) {
///     return Stack(
///       children: [
///         // Your main content
///         Scaffold(
///           body: Center(
///             child: CupertinoButton(
///               onPressed: () => setState(() => _showModal = true),
///               child: Text('Show Action Sheet'),
///             ),
///           ),
///         ),
///         // Modal popup overlay
///         if (_showModal)
///           CupertinoModalPopupOverlay(
///             onDismiss: () => setState(() => _showModal = false),
///             builder: (context) => CupertinoActionSheet(
///               title: Text('Options'),
///               actions: [
///                 CupertinoActionSheetAction(
///                   onPressed: () {
///                     setState(() => _showModal = false);
///                     // Handle action
///                   },
///                   child: Text('Option 1'),
///                 ),
///               ],
///             ),
///           ),
///       ],
///     );
///   }
/// }
/// ```
/// {@end-tool}
class CupertinoModalPopupOverlay extends StatelessWidget {
  const CupertinoModalPopupOverlay({
    super.key,
    required this.builder,
    required this.onDismiss,
    this.barrierColor = kCupertinoModalBarrierColor,
    this.barrierDismissible = true,
    this.filter,
  });

  final WidgetBuilder builder;
  final VoidCallback onDismiss;
  final Color? barrierColor;
  final bool barrierDismissible;
  final ImageFilter? filter;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return CupertinoModalPopupPage<void>(
          builder: builder,
          barrierColor: barrierColor,
          barrierDismissible: barrierDismissible,
          filter: filter,
          onBarrierTap: barrierDismissible ? onDismiss : null,
        ).createRoute(context);
      },
    );
  }
}
