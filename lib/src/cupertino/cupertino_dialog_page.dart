// Copyright (c) 2025-2026. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter_declarative_popups/src/utils/cupertino_color.dart';
import 'package:flutter_declarative_popups/src/utils/page_route.dart';

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
  /// Custom dynamic Cupertino colors honor the opening context's local theme
  /// and the navigator's ambient brightness, contrast, and interface level.
  final Color? barrierColor;

  /// The semantic label used for the modal barrier if it is dismissible.
  ///
  /// If this is null, the default label from [CupertinoLocalizations.modalBarrierDismissLabel]
  /// will be used.
  final String? barrierLabel;

  /// The duration of the transition animation.
  ///
  /// The default 250 milliseconds uses Flutter's native spring transition,
  /// whose actual settling time is determined by the spring. A custom value
  /// uses a timed transition of that duration; [Duration.zero] disables it.
  final Duration transitionDuration;

  /// Custom transition builder for the dialog animation.
  ///
  /// If null, the default iOS-style fade and scale animation will be used.
  final RouteTransitionsBuilder? transitionBuilder;

  /// Whether the route should request focus when pushed.
  ///
  /// If null, the route uses [Navigator.requestFocus].
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
    return _CupertinoDialogRoute<T>(page: this, context: context);
  }
}

class _CupertinoDialogRoute<T> extends CupertinoDialogRoute<T>
    with PopupPageRoute<T, CupertinoDialogPage<T>> {
  _CupertinoDialogRoute({
    required CupertinoDialogPage<T> page,
    required super.context,
  }) : _colorResolver = CupertinoPopupColorResolver(context),
       _defaultBarrierLabel = CupertinoLocalizations.of(context)
           .modalBarrierDismissLabel,
       super(
         settings: page,
         builder: (context) {
           final page =
               ModalRoute.settingsOf(context)! as CupertinoDialogPage<T>;
           return page.builder(context);
         },
       );

  final CupertinoPopupColorResolver _colorResolver;
  final String _defaultBarrierLabel;

  @override
  bool get barrierDismissible => page.barrierDismissible;

  @override
  Color get barrierColor =>
      _colorResolver.resolve(page.barrierColor ?? kCupertinoModalBarrierColor)!;

  @override
  String get barrierLabel => page.barrierLabel ?? _defaultBarrierLabel;

  @override
  Duration get transitionDuration => page.transitionDuration;

  @override
  Simulation createSimulation({required bool forward}) {
    if (transitionDuration == const Duration(milliseconds: 250)) {
      return super.createSimulation(forward: forward);
    }
    return _TimedDialogSimulation(
      begin: controller!.value,
      end: forward ? 1 : 0,
      duration: transitionDuration,
    );
  }

  @override
  Offset? get anchorPoint => page.anchorPoint;

  @override
  bool get requestFocus => page.requestFocus ?? super.requestFocus;

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
        super.buildTransitions(context, animation, secondaryAnimation, child);
  }

  @override
  Widget buildModalBarrier() {
    final barrier = super.buildModalBarrier();
    if (page.onBarrierTap == null && page.barrierOnTapHint == null) {
      return barrier;
    }
    return customizeModalBarrier(
      barrier,
      onDismiss: _handleBarrierTap,
      semanticsOnTapHint: page.barrierOnTapHint,
    );
  }

  void _handleBarrierTap() {
    if (!isCurrent) {
      return;
    }
    if (page.onBarrierTap != null) {
      page.onBarrierTap!();
    } else {
      navigator?.maybePop();
    }
  }
}

// CupertinoDialogRoute requires a non-null simulation, while its native
// spring ignores transitionDuration. This preserves custom duration values.
class _TimedDialogSimulation extends Simulation {
  _TimedDialogSimulation({
    required this.begin,
    required this.end,
    required Duration duration,
  }) : duration = duration.inMicroseconds / Duration.microsecondsPerSecond;

  final double begin;
  final double end;
  final double duration;

  @override
  double x(double time) => duration == 0
      ? end
      : begin + (end - begin) * (time / duration).clamp(0, 1);

  @override
  double dx(double time) =>
      duration == 0 || isDone(time) ? 0 : (end - begin) / duration;

  @override
  bool isDone(double time) => time >= duration;
}
