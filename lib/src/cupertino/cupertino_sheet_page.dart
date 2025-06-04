import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A declarative page that displays its content as a Cupertino-style sheet.
///
/// This page wraps Flutter's [CupertinoSheetRoute] and can be used with
/// Navigator 2.0's declarative API or with traditional imperative navigation.
///
/// Example:
/// ```dart
/// // Declarative usage with Navigator 2.0
/// Navigator(
///   pages: [
///     MaterialPage(child: HomePage()),
///     if (showSheet)
///       CupertinoSheetPage(
///         builder: (context) => SheetContent(),
///         showDragHandle: true,
///       ),
///   ],
///   onPopPage: (route, result) => route.didPop(result),
/// )
///
/// // Imperative usage
/// Navigator.of(context).push(
///   CupertinoSheetPage(
///     builder: (context) => SheetContent(),
///   ).createRoute(context),
/// );
/// ```
class CupertinoSheetPage<T> extends Page<T> {
  const CupertinoSheetPage({
    required this.builder,
    // Navigation behavior
    this.useNestedNavigation = false,
    this.nestedNavigatorKey,
    this.onWillPop,
    // Sheet appearance
    this.backgroundColor,
    this.shape,
    this.showDragHandle,
    this.topGapRatio,
    this.constraints,
    this.useSafeArea = false,
    // Sheet behavior
    this.enableDrag = true,
    this.isDismissible = true,
    this.onBarrierTap,
    // Route properties (rarely needed)
    this.transitionDuration,
    this.barrierColor,
    this.barrierDismissible,
    this.barrierLabel,
    // Page properties
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// Builds the primary content of the sheet.
  ///
  /// The builder should create the main widget tree for the sheet's content.
  /// This is the only required parameter.
  final WidgetBuilder builder;

  /// Whether to wrap the content in a nested [Navigator].
  ///
  /// When `true`, navigation within the sheet will be isolated from the main
  /// app navigation. This is useful for multi-step flows within a sheet.
  ///
  /// Defaults to `false`.
  final bool useNestedNavigation;

  /// Optional key for the nested navigator when [useNestedNavigation] is true.
  ///
  /// Useful for controlling the nested navigator programmatically.
  final GlobalKey<NavigatorState>? nestedNavigatorKey;

  /// Callback to control whether the sheet can be popped.
  ///
  /// Only used when [useNestedNavigation] is true. Return `true` to allow
  /// the sheet to be dismissed, `false` to prevent dismissal.
  final Future<bool> Function()? onWillPop;

  /// The background color of the sheet.
  ///
  /// If null, the sheet will use the default background from the current theme.
  /// Consider using [CupertinoColors] for iOS-appropriate colors.
  final Color? backgroundColor;

  /// The shape of the sheet.
  ///
  /// Defaults to rounded corners at the top (12.0 radius) to match iOS style.
  /// Set to `RoundedRectangleBorder()` for square corners.
  final ShapeBorder? shape;

  /// Whether to show a drag handle at the top of the sheet.
  ///
  /// The handle is a small horizontal bar that provides a visual affordance
  /// for dragging. Common in iOS sheets.
  ///
  /// Defaults to `null` (no drag handle).
  final bool? showDragHandle;

  /// The ratio of screen height reserved for the gap at the top.
  ///
  /// iOS sheets don't cover the entire screen, leaving a gap at the top.
  /// Default is 0.08 (8% of screen height), matching native iOS behavior.
  ///
  /// Set to 0.0 for a full-screen sheet.
  final double? topGapRatio;

  /// Additional constraints to apply to the sheet.
  ///
  /// Useful for limiting the sheet's width on large screens or setting
  /// a minimum/maximum height.
  final BoxConstraints? constraints;

  /// Whether to wrap the content in a [SafeArea].
  ///
  /// When true, the sheet content will avoid system UI intrusions.
  /// Default is false as sheets typically handle this themselves.
  final bool useSafeArea;

  /// Whether the sheet can be dismissed by dragging down.
  ///
  /// Defaults to `true`. Set to `false` for modal sheets that require
  /// explicit dismissal (e.g., forms that must be completed).
  final bool enableDrag;

  /// Whether the sheet can be dismissed at all (by drag or programmatically).
  ///
  /// When `false`, the sheet becomes truly modal and can only be dismissed
  /// by calling Navigator.pop() with `rootNavigator: true`.
  ///
  /// Defaults to `true`.
  final bool isDismissible;

  /// Callback when the barrier (area outside the sheet) is tapped.
  ///
  /// Only called if [barrierDismissible] is true. Note that by default,
  /// iOS sheets have a transparent, non-dismissible barrier.
  final VoidCallback? onBarrierTap;

  /// Custom transition duration for the sheet animation.
  ///
  /// Defaults to 500ms to match iOS behavior. Only change this if you
  /// need custom animation timing.
  final Duration? transitionDuration;

  /// The color of the modal barrier (area outside the sheet).
  ///
  /// Defaults to transparent to match iOS behavior. Set to a semi-transparent
  /// black for a dimmed background effect.
  final Color? barrierColor;

  /// Whether tapping the barrier dismisses the sheet.
  ///
  /// Defaults to `false` to match iOS behavior. iOS sheets typically
  /// require dragging or an explicit close button.
  final bool? barrierDismissible;

  /// Semantic label for the barrier.
  ///
  /// Used by screen readers to describe the barrier. Only relevant if
  /// [barrierColor] is not fully transparent.
  final String? barrierLabel;

  @override
  Route<T> createRoute(BuildContext context) {
    // Handle nested navigation setup if requested
    var effectiveBuilder = builder;

    if (useNestedNavigation) {
      final navigatorKey = nestedNavigatorKey ?? GlobalKey<NavigatorState>();

      effectiveBuilder = (BuildContext context) {
        return NavigatorPopHandler(
          onPopWithResult: (T? result) {
            navigatorKey.currentState?.maybePop();
          },
          child: Navigator(
            key: navigatorKey,
            initialRoute: '/',
            onGenerateInitialRoutes:
                (NavigatorState navigator, String initialRouteName) {
              return <Route<void>>[
                CupertinoPageRoute<void>(
                  builder: (BuildContext context) {
                    final content = builder(context);

                    // Handle back gestures for nested navigation
                    return PopScope(
                      canPop: false,
                      onPopInvokedWithResult:
                          (bool didPop, Object? result) async {
                        if (didPop) {
                          return;
                        }

                        // Check custom handler first
                        if (onWillPop != null) {
                          final shouldPop = await onWillPop!();
                          if (shouldPop && context.mounted) {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pop(result);
                          }
                        } else {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pop(result);
                        }
                      },
                      child: content,
                    );
                  },
                ),
              ];
            },
          ),
        );
      };
    }

    return _CustomizedCupertinoSheetRoute<T>(
      builder: effectiveBuilder,
      settings: this,
      enableDrag: enableDrag,
      // Appearance
      backgroundColor: backgroundColor,
      shape: shape,
      showDragHandle: showDragHandle,
      topGapRatio: topGapRatio,
      constraints: constraints,
      useSafeArea: useSafeArea,
      // Behavior
      isDismissible: isDismissible,
      onBarrierTap: onBarrierTap,
      // Route overrides
      customTransitionDuration: transitionDuration,
      customBarrierColor: barrierColor,
      customBarrierDismissible: barrierDismissible,
      customBarrierLabel: barrierLabel,
    );
  }
}

/// Internal route that extends [CupertinoSheetRoute] with customization support.
class _CustomizedCupertinoSheetRoute<T> extends CupertinoSheetRoute<T> {
  _CustomizedCupertinoSheetRoute({
    required super.builder,
    required super.settings,
    required super.enableDrag,
    // Appearance
    this.backgroundColor,
    this.shape,
    this.showDragHandle,
    this.topGapRatio,
    this.constraints,
    this.useSafeArea = false,
    // Behavior
    this.isDismissible = true,
    this.onBarrierTap,
    // Route overrides
    this.customTransitionDuration,
    this.customBarrierColor,
    this.customBarrierDismissible,
    this.customBarrierLabel,
  });

  // Appearance customization
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final bool? showDragHandle;
  final double? topGapRatio;
  final BoxConstraints? constraints;
  final bool useSafeArea;

  // Behavior customization
  final bool isDismissible;
  final VoidCallback? onBarrierTap;

  // Route property overrides
  final Duration? customTransitionDuration;
  final Color? customBarrierColor;
  final bool? customBarrierDismissible;
  final String? customBarrierLabel;

  @override
  Duration get transitionDuration =>
      customTransitionDuration ?? super.transitionDuration;

  @override
  Color? get barrierColor => customBarrierColor ?? super.barrierColor;

  @override
  bool get barrierDismissible =>
      customBarrierDismissible ?? super.barrierDismissible;

  @override
  String? get barrierLabel => customBarrierLabel ?? super.barrierLabel;

  @override
  Widget buildContent(BuildContext context) {
    var content = builder(context);

    // Apply appearance customizations
    content = _applyCustomizations(context, content);

    // Wrap with the standard sheet structure
    final bottomPadding =
        MediaQuery.sizeOf(context).height * (topGapRatio ?? 0.08);

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: CupertinoUserInterfaceLevel(
          data: CupertinoUserInterfaceLevelData.elevated,
          child: content,
        ),
      ),
    );
  }

  Widget _applyCustomizations(BuildContext context, Widget widget) {
    var content = widget;
    // Apply SafeArea first if requested
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    // Apply constraints
    if (constraints != null) {
      content = ConstrainedBox(constraints: constraints!, child: content);
    }

    // Wrap in Material for appearance customization
    if (backgroundColor != null || shape != null) {
      content = Material(
        color: backgroundColor ??
            CupertinoColors.systemBackground.resolveFrom(context),
        shape: shape ??
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    } else {
      // Apply default corner radius
      content = ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: content,
      );
    }

    // Add drag handle
    if (showDragHandle ?? false) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(context),
          Flexible(child: content),
        ],
      );
    }

    return content;
  }

  Widget _buildDragHandle(BuildContext context) {
    return Container(
      height: 22,
      alignment: Alignment.center,
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  @override
  Widget buildModalBarrier() {
    if (onBarrierTap != null && barrierDismissible) {
      return GestureDetector(
        onTap: () {
          onBarrierTap?.call();
          if (isDismissible && barrierDismissible) {
            navigator?.maybePop();
          }
        },
        behavior: HitTestBehavior.opaque,
        child: super.buildModalBarrier(),
      );
    }
    return super.buildModalBarrier();
  }

  @override
  bool get popGestureEnabled =>
      enableDrag && isDismissible && super.popGestureEnabled;
}
