// Copyright (c) 2025-2026. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter_declarative_popups/src/utils/cupertino_color.dart';
import 'package:flutter_declarative_popups/src/utils/page_route.dart';

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
  /// Dynamic Cupertino colors honor the opening context's local theme and
  /// the navigator's ambient brightness, contrast, and interface level.
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
  /// If null, the route uses [Navigator.requestFocus].
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
    return _CupertinoModalPopupRoute<T>(page: this, context: context);
  }
}

class _CupertinoModalPopupRoute<T> extends CupertinoModalPopupRoute<T>
    with PopupPageRoute<T, CupertinoModalPopupPage<T>> {
  _CupertinoModalPopupRoute({
    required CupertinoModalPopupPage<T> page,
    required BuildContext context,
  }) : _colorResolver = CupertinoPopupColorResolver(context),
       super(settings: page, builder: page.builder);

  final CupertinoPopupColorResolver _colorResolver;

  @override
  WidgetBuilder get builder => page.builder;

  @override
  String get barrierLabel => page.barrierLabel;

  @override
  Color? get barrierColor => _colorResolver.resolve(page.barrierColor);

  @override
  bool get barrierDismissible => page.barrierDismissible;

  @override
  bool get semanticsDismissible => page.semanticsDismissible;

  @override
  ImageFilter? get filter => page.filter;

  @override
  Offset? get anchorPoint => page.anchorPoint;

  @override
  bool get requestFocus => page.requestFocus ?? super.requestFocus;

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
