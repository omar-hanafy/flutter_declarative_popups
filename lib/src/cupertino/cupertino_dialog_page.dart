// Copyright (c) 2025. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

/// A page that creates a Cupertino-style dialog route.
///
/// This page can be used with Navigator 2.0 (declarative API) to show
/// iOS-style dialogs, similar to [showCupertinoDialog].
///
/// {@tool snippet}
/// This example shows how to use [CupertinoDialogPage] with Navigator 2.0:
///
/// ```dart
/// Navigator(
///   pages: [
///     MaterialPage(child: HomeScreen()),
///     if (showDialog)
///       CupertinoDialogPage<bool>(
///         key: ValueKey('confirm-dialog'),
///         builder: (context) => CupertinoAlertDialog(
///           title: Text('Delete Item'),
///           content: Text('Are you sure you want to delete this item?'),
///           actions: [
///             CupertinoDialogAction(
///               onPressed: () => Navigator.pop(context, false),
///               child: Text('Cancel'),
///             ),
///             CupertinoDialogAction(
///               onPressed: () => Navigator.pop(context, true),
///               isDestructiveAction: true,
///               child: Text('Delete'),
///             ),
///           ],
///         ),
///       ),
///   ],
///   onDidRemovePage: (page) {
///     if (page.key == const ValueKey('confirm-dialog')) {
///       // Handle removal here
///     }
///   },
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [CupertinoDialogRoute], which is the route this page creates.
///  * [showCupertinoDialog], which is the imperative API equivalent.
///  * [CupertinoAlertDialog], which is typically used as the child widget.
class CupertinoDialogPage<T> extends Page<T> {
  /// Creates a page that shows an iOS-style dialog.
  ///
  /// The [builder] argument must not be null.
  const CupertinoDialogPage({
    required this.builder,
    this.barrierDismissible = true,
    this.barrierColor,
    this.barrierLabel,
    this.transitionDuration = const Duration(milliseconds: 250),
    this.transitionBuilder,
    this.requestFocus,
    this.anchorPoint,
    this.onBarrierTap,
    this.barrierOnTapHint,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.canPop,
    super.onPopInvoked,
  });

  /// Builds the primary contents of the dialog.
  ///
  /// The [builder] argument typically builds a [CupertinoAlertDialog] widget.
  /// Content below the widget is dimmed with a [ModalBarrier]. The widget built
  /// by the [builder] does not share a context with the route it was originally
  /// built from. Use a [StatefulBuilder] or a custom [StatefulWidget] if the
  /// widget needs to update dynamically.
  final WidgetBuilder builder;

  /// Whether you can dismiss this route by tapping the modal barrier.
  ///
  /// When this is set to true, tapping outside the dialog will cause the
  /// current route to be popped with null as the value.
  ///
  /// Defaults to true.
  final bool barrierDismissible;

  /// The color to use for the modal barrier.
  ///
  /// If this is null, the barrier will use the default iOS modal barrier color
  /// resolved from [kCupertinoModalBarrierColor] using [CupertinoDynamicColor.resolve].
  final Color? barrierColor;

  /// The semantic label used for the modal barrier if it is dismissible.
  ///
  /// If this is null, the default label from [CupertinoLocalizations.modalBarrierDismissLabel]
  /// will be used.
  final String? barrierLabel;

  /// The duration of the transition animation.
  ///
  /// This transition duration was eyeballed comparing with iOS.
  /// Defaults to 250 milliseconds.
  final Duration transitionDuration;

  /// Custom transition builder for the dialog animation.
  ///
  /// If null, the default iOS-style fade and scale animation will be used.
  final RouteTransitionsBuilder? transitionBuilder;

  /// Whether the route should request focus when pushed.
  ///
  /// {@macro flutter.widgets.navigator.requestFocus}
  final bool? requestFocus;

  /// {@macro flutter.widgets.DisplayFeatureSubScreen.anchorPoint}
  final Offset? anchorPoint;

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
      return _CustomCupertinoDialogRoute<T>(
        builder: builder,
        context: context,
        settings: this,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
        requestFocus: requestFocus,
        anchorPoint: anchorPoint,
        onBarrierTap: onBarrierTap,
        barrierOnTapHint: barrierOnTapHint,
      );
    }

    // Otherwise use the standard route
    return CupertinoDialogRoute<T>(
      builder: builder,
      context: context,
      settings: this,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
      requestFocus: requestFocus,
      anchorPoint: anchorPoint,
    );
  }
}

/// Custom [CupertinoDialogRoute] that supports additional barrier customization.
class _CustomCupertinoDialogRoute<T> extends CupertinoDialogRoute<T> {
  _CustomCupertinoDialogRoute({
    required super.builder,
    required super.context,
    super.barrierDismissible,
    super.barrierColor,
    super.barrierLabel,
    super.transitionDuration,
    super.transitionBuilder,
    super.settings,
    super.requestFocus,
    super.anchorPoint,
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

/// A convenience widget that shows a dialog using [CupertinoDialogPage].
///
/// This is a declarative wrapper around [CupertinoDialogPage] that can be
/// used in widget trees where you want to conditionally show a dialog.
///
/// {@tool snippet}
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   bool _showDialog = false;
///   String? _result;
///
///   @override
///   Widget build(BuildContext context) {
///     return Stack(
///       children: [
///         // Your main content
///         Scaffold(
///           body: Center(
///             child: Column(
///               mainAxisAlignment: MainAxisAlignment.center,
///               children: [
///                 CupertinoButton(
///                   onPressed: () => setState(() => _showDialog = true),
///                   child: Text('Show Alert'),
///                 ),
///                 if (_result != null)
///                   Text('Result: $_result'),
///               ],
///             ),
///           ),
///         ),
///         // Dialog overlay
///         if (_showDialog)
///           CupertinoDialogOverlay(
///             onDismiss: () => setState(() => _showDialog = false),
///             builder: (context) => CupertinoAlertDialog(
///               title: Text('Alert'),
///               content: Text('This is an iOS-style alert dialog.'),
///               actions: [
///                 CupertinoDialogAction(
///                   onPressed: () {
///                     setState(() {
///                       _showDialog = false;
///                       _result = 'Cancelled';
///                     });
///                   },
///                   child: Text('Cancel'),
///                 ),
///                 CupertinoDialogAction(
///                   onPressed: () {
///                     setState(() {
///                       _showDialog = false;
///                       _result = 'Confirmed';
///                     });
///                   },
///                   isDefaultAction: true,
///                   child: Text('OK'),
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
class CupertinoDialogOverlay extends StatelessWidget {
  const CupertinoDialogOverlay({
    super.key,
    required this.builder,
    required this.onDismiss,
    this.barrierColor,
    this.barrierDismissible = true,
    this.transitionDuration = const Duration(milliseconds: 250),
    this.transitionBuilder,
  });

  final WidgetBuilder builder;
  final VoidCallback onDismiss;
  final Color? barrierColor;
  final bool barrierDismissible;
  final Duration transitionDuration;
  final RouteTransitionsBuilder? transitionBuilder;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return CupertinoDialogPage<void>(
          builder: builder,
          barrierColor: barrierColor,
          barrierDismissible: barrierDismissible,
          transitionDuration: transitionDuration,
          transitionBuilder: transitionBuilder,
          onBarrierTap: barrierDismissible ? onDismiss : null,
        ).createRoute(context);
      },
    );
  }
}
