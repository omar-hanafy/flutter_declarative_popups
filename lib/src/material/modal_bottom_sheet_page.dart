// Copyright (c) 2025. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

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
      barrierOnTapHint: barrierOnTapHint ??
          MaterialLocalizations.of(
            context,
          ).scrimOnTapHint(MaterialLocalizations.of(context).bottomSheetLabel),
      capturedThemes: capturedThemes,
      modalBarrierColor: modalBarrierColor ??
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
    return _CustomModalBottomSheetRoute<T>(
      builder: builder,
      settings: this,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierLabel: barrierLabel,
      barrierOnTapHint: barrierOnTapHint,
      capturedThemes: capturedThemes,
      modalBarrierColor: modalBarrierColor,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      scrollControlDisabledMaxHeightRatio:
          maxHeightRatio ?? _defaultScrollControlDisabledMaxHeightRatio,
      transitionAnimationController: transitionAnimationController,
      anchorPoint: anchorPoint,
      useSafeArea: useSafeArea,
      sheetAnimationStyle: sheetAnimationStyle,
      constraints: constraints,
      requestFocus: requestFocus,
      onBarrierTap: onBarrierTap,
    );
  }
}

// The default max height ratio when scroll control is disabled
const double _defaultScrollControlDisabledMaxHeightRatio = 9.0 / 16.0;

class _CustomModalBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  _CustomModalBottomSheetRoute({
    required super.builder,
    required super.isScrollControlled,
    super.capturedThemes,
    super.barrierLabel,
    super.barrierOnTapHint,
    super.backgroundColor,
    super.elevation,
    super.shape,
    super.clipBehavior,
    super.constraints,
    super.modalBarrierColor,
    super.isDismissible,
    super.enableDrag,
    super.showDragHandle,
    super.scrollControlDisabledMaxHeightRatio,
    super.settings,
    super.transitionAnimationController,
    super.anchorPoint,
    super.useSafeArea,
    super.sheetAnimationStyle,
    super.requestFocus,
    this.onBarrierTap,
  });

  /// Custom callback when the barrier is tapped.
  final VoidCallback? onBarrierTap;

  @override
  Widget buildModalBarrier() {
    // Get the base modal barrier from parent
    final baseBarrier = super.buildModalBarrier();

    // If we have a custom onBarrierTap and the barrier is dismissible,
    // wrap it to intercept taps
    if (onBarrierTap != null && barrierDismissible) {
      return GestureDetector(
        onTap: () {
          onBarrierTap!();
        },
        behavior: HitTestBehavior.opaque,
        child: baseBarrier,
      );
    }

    return baseBarrier;
  }
}
