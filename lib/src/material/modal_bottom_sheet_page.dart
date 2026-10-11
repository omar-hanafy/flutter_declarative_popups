// Copyright (c) 2025-2026. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_declarative_popups/src/utils/page_route.dart';

/// A declarative page-based modal bottom sheet that can be used with Navigator 2.0.
///
/// This page creates a [ModalBottomSheetRoute] when added to the Navigator's pages list.
/// It provides all the functionality of [showModalBottomSheet] but in a declarative way.
///
/// Example usage:
/// ```dart
/// Navigator(
///   pages: [
///     MaterialPage(child: HomePage()),
///     if (showBottomSheet)
///       ModalBottomSheetPage(
///         builder: (context) => MyBottomSheetContent(),
///       ),
///   ],
///   onDidRemovePage: (page) {
///     if (page.key == const ValueKey('bottom-sheet')) {
///       // Update your state here
///     }
///   },
/// )
/// ```
class ModalBottomSheetPage<T> extends Page<T> {
  /// Creates a modal bottom sheet page.
  ///
  /// The [builder] argument must not be null.
  const ModalBottomSheetPage({
    required this.builder,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.barrierLabel,
    this.barrierOnTapHint,
    this.capturedThemes,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    this.showDragHandle,
    this.maxHeightRatio,
    this.transitionAnimationController,
    this.sheetAnimationStyle,
    this.useSafeArea = false,
    this.isScrollControlled = false,
    this.anchorPoint,
    this.constraints,
    this.requestFocus,
    this.onBarrierTap,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.canPop,
    super.onPopInvoked,
  });

  /// Creates a modal bottom sheet page with automatically captured themes.
  ///
  /// This factory constructor captures the current theme context automatically,
  /// similar to how [showModalBottomSheet] works.
  factory ModalBottomSheetPage.withContext({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    String? barrierLabel,
    String? barrierOnTapHint,
    Color? modalBarrierColor,
    bool isDismissible = true,
    bool enableDrag = true,
    bool? showDragHandle,
    double? maxHeightRatio,
    AnimationController? transitionAnimationController,
    AnimationStyle? sheetAnimationStyle,
    bool useSafeArea = false,
    bool isScrollControlled = false,
    Offset? anchorPoint,
    BoxConstraints? constraints,
    bool? requestFocus,
    VoidCallback? onBarrierTap,
    bool canPop = true,
    PopInvokedWithResultCallback<T>? onPopInvoked,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    // Capture themes from the current context
    final capturedThemes = InheritedTheme.capture(
      from: context,
      to: Navigator.of(context).context,
    );

    return ModalBottomSheetPage<T>(
      builder: builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierLabel:
          barrierLabel ?? MaterialLocalizations.of(context).scrimLabel,
      barrierOnTapHint:
          barrierOnTapHint ??
          MaterialLocalizations.of(
            context,
          ).scrimOnTapHint(MaterialLocalizations.of(context).bottomSheetLabel),
      capturedThemes: capturedThemes,
      modalBarrierColor:
          modalBarrierColor ??
          Theme.of(context).bottomSheetTheme.modalBarrierColor,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      maxHeightRatio: maxHeightRatio,
      transitionAnimationController: transitionAnimationController,
      sheetAnimationStyle: sheetAnimationStyle,
      useSafeArea: useSafeArea,
      isScrollControlled: isScrollControlled,
      anchorPoint: anchorPoint,
      constraints: constraints,
      requestFocus: requestFocus,
      onBarrierTap: onBarrierTap,
      canPop: canPop,
      onPopInvoked: onPopInvoked ?? (bool didPop, T? result) {},
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
    );
  }

  /// A builder for the contents of the sheet.
  ///
  /// The bottom sheet will wrap the widget produced by this builder in a
  /// [Material] widget.
  final WidgetBuilder builder;

  /// The bottom sheet's background color.
  ///
  /// Defines the bottom sheet's [Material.color].
  ///
  /// If this property is not provided, it falls back to [Material]'s default.
  final Color? backgroundColor;

  /// The z-coordinate at which to place this material relative to its parent.
  ///
  /// This controls the size of the shadow below the material.
  ///
  /// Defaults to 0, must not be negative.
  final double? elevation;

  /// The shape of the bottom sheet.
  ///
  /// Defines the bottom sheet's [Material.shape].
  ///
  /// If this property is not provided, it falls back to [Material]'s default.
  final ShapeBorder? shape;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defines the bottom sheet's [Material.clipBehavior].
  ///
  /// Use this property to enable clipping of content when the bottom sheet has
  /// a custom [shape] and the content can extend past this shape. For example,
  /// a bottom sheet with rounded corners and an edge-to-edge [Image] at the
  /// top.
  ///
  /// If this property is null, the [BottomSheetThemeData.clipBehavior] of
  /// [ThemeData.bottomSheetTheme] is used. If that's null, the behavior defaults
  /// to [Clip.none].
  final Clip? clipBehavior;

  /// The semantic label used for the barrier.
  ///
  /// If this property is null, the [MaterialLocalizations.scrimLabel] will be used.
  final String? barrierLabel;

  /// The semantic hint text that informs users what will happen if they
  /// tap on the widget. Announced in the format of 'Double tap to ...'.
  ///
  /// If the field is null, the default hint will be used, which results in
  /// announcement of 'Double tap to activate'.
  final String? barrierOnTapHint;

  /// Stores a list of captured [InheritedTheme]s that are wrapped around the
  /// bottom sheet.
  ///
  /// Consider using [ModalBottomSheetPage.withContext] factory constructor
  /// to automatically capture themes.
  final CapturedThemes? capturedThemes;

  /// Specifies the color of the modal barrier that darkens everything below the
  /// bottom sheet.
  ///
  /// Defaults to `Colors.black54` if not provided.
  final Color? modalBarrierColor;

  /// Specifies whether the bottom sheet will be dismissed
  /// when user taps on the scrim.
  ///
  /// If true, the bottom sheet will be dismissed when user taps on the scrim.
  ///
  /// Defaults to true.
  final bool isDismissible;

  /// Specifies whether the bottom sheet can be dragged up and down
  /// and dismissed by swiping downwards.
  ///
  /// If true, the bottom sheet can be dragged up and down and dismissed by
  /// swiping downwards.
  ///
  /// This applies to the content below the drag handle, if showDragHandle is true.
  /// [Page.canPop] and [PopScope] also block drag dismissal, including the
  /// handle and a [DraggableScrollableSheet] reaching its minimum extent.
  ///
  /// Defaults is true.
  final bool enableDrag;

  /// Specifies whether a drag handle is shown.
  ///
  /// The drag handle appears at the top of the bottom sheet. The default color is
  /// [ColorScheme.onSurfaceVariant] with an opacity of 0.4. The default size
  /// is `Size(32,4)`.
  ///
  /// If null, then the value of [BottomSheetThemeData.showDragHandle] is used.
  /// If that is also null, defaults to false.
  /// The handle is hidden while [Page.canPop] or [PopScope] blocks dismissal,
  /// because the SDK gives the handle its own dismissal gestures and action.
  final bool? showDragHandle;

  /// The max height constraint ratio for the bottom sheet
  /// when [isScrollControlled] is set to false.
  ///
  /// No ratio will be applied when [isScrollControlled] is set to true.
  ///
  /// Defaults to 9/16 (0.5625).
  final double? maxHeightRatio;

  /// The animation controller that controls the bottom sheet's entrance and
  /// exit animations.
  ///
  /// The BottomSheet widget will manipulate the position of this animation, it
  /// is not just a passive observer. It's up to the owner of the controller to
  /// call [AnimationController.dispose] when the controller is no longer needed.
  ///
  /// Changing the controller identity replaces the route and its content state,
  /// even when the page key is unchanged. Its lifecycle is owned by the SDK
  /// route and cannot be changed on an existing route.
  final AnimationController? transitionAnimationController;

  /// Used to override the modal bottom sheet animation duration and reverse
  /// animation duration.
  ///
  /// If [AnimationStyle.duration] is provided, it will be used to override
  /// the modal bottom sheet animation duration.
  ///
  /// If [AnimationStyle.reverseDuration] is provided, it will be used to
  /// override the modal bottom sheet reverse animation duration.
  ///
  /// To disable the modal bottom sheet animation, use [AnimationStyle.noAnimation].
  ///
  /// Duration changes update an existing route when it owns its controller.
  /// Changing [AnimationStyle.curve] or [AnimationStyle.reverseCurve] replaces
  /// the route and its content state, because the SDK caches those curves.
  final AnimationStyle? sheetAnimationStyle;

  /// Whether to avoid system intrusions on the top, left, and right.
  ///
  /// If true, a [SafeArea] is inserted to keep the bottom sheet away from
  /// system intrusions at the top, left, and right sides of the screen.
  ///
  /// If false, the bottom sheet will extend through any system intrusions
  /// at the top, left, and right.
  ///
  /// In either case, the bottom sheet extends all the way to the bottom of
  /// the screen, including any system intrusions.
  ///
  /// The default is false.
  final bool useSafeArea;

  /// Specifies whether this is a route for a bottom sheet that will utilize
  /// [DraggableScrollableSheet].
  ///
  /// Consider setting this parameter to true if this bottom sheet has
  /// a scrollable child, such as a [ListView] or a [GridView],
  /// to have the bottom sheet be draggable.
  final bool isScrollControlled;

  /// {@macro flutter.widgets.DisplayFeatureSubScreen.anchorPoint}
  final Offset? anchorPoint;

  /// Defines minimum and maximum sizes for a [BottomSheet].
  ///
  /// If null, the ambient [ThemeData.bottomSheetTheme]'s
  /// [BottomSheetThemeData.constraints] will be used. If that
  /// is null and [ThemeData.useMaterial3] is true, then the bottom sheet
  /// will have a max width of 640dp. If [ThemeData.useMaterial3] is false, then
  /// the bottom sheet's size will be constrained by its parent
  /// (usually a [Scaffold]). In this case, consider limiting the width by
  /// setting smaller constraints for large screens.
  final BoxConstraints? constraints;

  /// Whether to request focus when the bottom sheet is shown.
  ///
  /// {@macro flutter.widgets.navigator.Route.requestFocus}
  final bool? requestFocus;

  /// Custom callback when the barrier is tapped.
  ///
  /// If provided, this callback will be called instead of the default
  /// behavior of dismissing the bottom sheet.
  ///
  /// This is useful for custom dismiss logic or for preventing dismissal
  /// in certain conditions.
  final VoidCallback? onBarrierTap;

  @override
  Route<T> createRoute(BuildContext context) {
    return _ModalBottomSheetRoute<T>(page: this, context: context);
  }

  @override
  bool canUpdate(Page<dynamic> other) {
    if (!super.canUpdate(other)) {
      return false;
    }
    final previous = other as ModalBottomSheetPage<T>;
    // The SDK owns its animation controller and caches its animation curves.
    // These lifecycle settings require a new route; content and other options
    // can update without discarding the existing sheet's state.
    return identical(
          transitionAnimationController,
          previous.transitionAnimationController,
        ) &&
        sheetAnimationStyle?.curve == previous.sheetAnimationStyle?.curve &&
        sheetAnimationStyle?.reverseCurve ==
            previous.sheetAnimationStyle?.reverseCurve;
  }
}

// The default max height ratio when scroll control is disabled.
const double _defaultScrollControlDisabledMaxHeightRatio = 9.0 / 16.0;

class _ModalBottomSheetRoute<T> extends ModalBottomSheetRoute<T>
    with PopupPageRoute<T, ModalBottomSheetPage<T>>, PopupDismissalGuard<T> {
  _ModalBottomSheetRoute({
    required ModalBottomSheetPage<T> page,
    required BuildContext context,
  }) : _defaultBarrierLabel = MaterialLocalizations.of(context).scrimLabel,
       _defaultBarrierOnTapHint = MaterialLocalizations.of(context)
           .scrimOnTapHint(MaterialLocalizations.of(context).bottomSheetLabel),
       _defaultBarrierColor = Theme.of(context)
           .bottomSheetTheme
           .modalBarrierColor,
       super(
         settings: page,
         builder: page.builder,
         isScrollControlled: page.isScrollControlled,
         transitionAnimationController: page.transitionAnimationController,
       );

  final String _defaultBarrierLabel;
  final String _defaultBarrierOnTapHint;
  final Color? _defaultBarrierColor;

  @override
  WidgetBuilder get builder => _buildContent;

  Widget _buildContent(BuildContext context) =>
      NotificationListener<DraggableScrollableNotification>(
        // The SDK's extent listener calls Navigator.pop directly. Consume its
        // close signal while the route's declarative pop policy forbids it.
        onNotification: (notification) =>
            !userDismissalAllowed &&
            notification.extent == notification.minExtent &&
            notification.shouldCloseOnMinExtent,
        child: preserveContent(Builder(builder: page.builder)),
      );

  @override
  CapturedThemes? get capturedThemes => page.capturedThemes;

  @override
  String get barrierLabel => page.barrierLabel ?? _defaultBarrierLabel;

  @override
  String get barrierOnTapHint =>
      page.barrierOnTapHint ?? _defaultBarrierOnTapHint;

  @override
  Color? get backgroundColor => page.backgroundColor;

  @override
  double? get elevation => page.elevation;

  @override
  ShapeBorder? get shape => page.shape;

  @override
  Clip? get clipBehavior => page.clipBehavior;

  @override
  BoxConstraints? get constraints => page.constraints;

  @override
  Color? get modalBarrierColor =>
      page.modalBarrierColor ?? _defaultBarrierColor;

  @override
  bool get isDismissible => page.isDismissible;

  @override
  bool get enableDrag => page.enableDrag && userDismissalAllowed;

  @override
  bool? get showDragHandle =>
      userDismissalAllowed ? page.showDragHandle : false;

  @override
  bool get isScrollControlled => page.isScrollControlled;

  @override
  double get scrollControlDisabledMaxHeightRatio =>
      page.maxHeightRatio ?? _defaultScrollControlDisabledMaxHeightRatio;

  @override
  Offset? get anchorPoint => page.anchorPoint;

  @override
  bool get useSafeArea => page.useSafeArea;

  @override
  AnimationStyle? get sheetAnimationStyle => page.sheetAnimationStyle;

  @override
  bool get requestFocus => page.requestFocus ?? super.requestFocus;

  @override
  bool get synchronizeAnimationDurations =>
      transitionAnimationController == null;

  @override
  Widget buildModalBarrier() {
    final barrier = super.buildModalBarrier();
    if (page.onBarrierTap == null || !barrierDismissible) {
      return barrier;
    }
    return customizeModalBarrier(
      barrier,
      onDismiss: () {
        if (isCurrent) {
          page.onBarrierTap!();
        }
      },
    );
  }
}
