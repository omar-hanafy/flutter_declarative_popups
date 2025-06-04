// Copyright (c) 2025. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_declarative_popups/src/cupertino/cupertino_dialog_page.dart';
import 'package:flutter_declarative_popups/src/cupertino/cupertino_modal_popup_page.dart';
import 'package:flutter_declarative_popups/src/cupertino/cupertino_sheet_page.dart';
import 'package:flutter_declarative_popups/src/material/dialog_page.dart';
import 'package:flutter_declarative_popups/src/material/modal_bottom_sheet_page.dart';
import 'package:flutter_declarative_popups/src/raw/raw_dialog_page.dart';

/// Extension methods for convenient navigation with declarative popup pages.
///
/// These extensions provide a more fluent API for pushing popup pages onto
/// the Navigator stack and creating pages with builder patterns.
extension DeclarativePopupNavigation on NavigatorState {
  // ===== Direct page push methods =====

  /// Push a [DialogPage] onto the navigator.
  ///
  /// This is a convenience method that creates the route automatically.
  Future<T?> pushDialogPage<T>(DialogPage<T> page) {
    return push<T>(page.createRoute(context));
  }

  /// Push a [ModalBottomSheetPage] onto the navigator.
  ///
  /// This is a convenience method that creates the route automatically.
  Future<T?> pushModalBottomSheetPage<T>(ModalBottomSheetPage<T> page) {
    return push<T>(page.createRoute(context));
  }

  /// Push a [CupertinoModalPopupPage] onto the navigator.
  ///
  /// This is a convenience method that creates the route automatically.
  Future<T?> pushCupertinoModalPopupPage<T>(CupertinoModalPopupPage<T> page) {
    return push<T>(page.createRoute(context));
  }

  /// Push a [CupertinoDialogPage] onto the navigator.
  ///
  /// This is a convenience method that creates the route automatically.
  Future<T?> pushCupertinoDialogPage<T>(CupertinoDialogPage<T> page) {
    return push<T>(page.createRoute(context));
  }

  /// Push a [CupertinoSheetPage] onto the navigator.
  ///
  /// This is a convenience method that creates the route automatically.
  Future<T?> pushCupertinoSheetPage<T>(CupertinoSheetPage<T> page) {
    return push<T>(page.createRoute(context));
  }

  /// Push a [RawDialogPage] onto the navigator.
  ///
  /// This is a convenience method that creates the route automatically.
  Future<T?> pushRawDialogPage<T>(RawDialogPage<T> page) {
    return push<T>(page.createRoute(context));
  }

  // ===== Builder methods that create and push pages =====

  /// Shows a dialog by creating and pushing a [DialogPage].
  ///
  /// This method provides a declarative alternative to [showDialog] that works
  /// with Navigator 2.0.
  ///
  /// Example:
  /// ```dart
  /// final result = await Navigator.of(context).showDeclarativeDialog<bool>(
  ///   builder: (context) => AlertDialog(
  ///     title: Text('Confirm'),
  ///     content: Text('Are you sure?'),
  ///     actions: [
  ///       TextButton(
  ///         onPressed: () => Navigator.pop(context, false),
  ///         child: Text('Cancel'),
  ///       ),
  ///       TextButton(
  ///         onPressed: () => Navigator.pop(context, true),
  ///         child: Text('OK'),
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  Future<T?> showDeclarativeDialog<T>({
    required WidgetBuilder builder,
    Offset? anchorPoint,
    Color? barrierColor,
    bool barrierDismissible = true,
    String? barrierLabel,
    bool useSafeArea = true,
    CapturedThemes? themes,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    AnimationStyle? animationStyle,
    bool? requestFocus,
    String? restorationId,
  }) {
    final page = DialogPage<T>(
      builder: builder,
      anchorPoint: anchorPoint,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ??
          (barrierDismissible
              ? MaterialLocalizations.of(context).modalBarrierDismissLabel
              : null),
      useSafeArea: useSafeArea,
      themes: themes,
      traversalEdgeBehavior: traversalEdgeBehavior,
      animationStyle: animationStyle,
      requestFocus: requestFocus,
      restorationId: restorationId,
    );

    return push<T>(page.createRoute(context));
  }

  /// Shows a modal bottom sheet by creating and pushing a [ModalBottomSheetPage].
  ///
  /// This method provides a declarative alternative to [showModalBottomSheet]
  /// that works with Navigator 2.0.
  ///
  /// Example:
  /// ```dart
  /// final result = await Navigator.of(context).showDeclarativeModalBottomSheet<String>(
  ///   builder: (context) => Container(
  ///     height: 200,
  ///     child: Column(
  ///       children: [
  ///         ListTile(
  ///           leading: Icon(Icons.share),
  ///           title: Text('Share'),
  ///           onTap: () => Navigator.pop(context, 'share'),
  ///         ),
  ///         ListTile(
  ///           leading: Icon(Icons.edit),
  ///           title: Text('Edit'),
  ///           onTap: () => Navigator.pop(context, 'edit'),
  ///         ),
  ///       ],
  ///     ),
  ///   ),
  ///   showDragHandle: true,
  /// );
  /// ```
  Future<T?> showDeclarativeModalBottomSheet<T>({
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    String? barrierLabel,
    String? barrierOnTapHint,
    CapturedThemes? capturedThemes,
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
    String? restorationId,
  }) {
    final page = ModalBottomSheetPage<T>(
      builder: builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierLabel:
          barrierLabel ?? MaterialLocalizations.of(context).scrimLabel,
      barrierOnTapHint: barrierOnTapHint ??
          MaterialLocalizations.of(context).scrimOnTapHint(
            MaterialLocalizations.of(context).bottomSheetLabel,
          ),
      capturedThemes: capturedThemes ??
          InheritedTheme.capture(
            from: context,
            to: Navigator.of(context).context,
          ),
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
      restorationId: restorationId,
    );

    return push<T>(page.createRoute(context));
  }

  /// Shows a [RawDialogPage] and returns a [Future] that completes when
  /// the dialog is dismissed.
  ///
  /// This method creates a [RawDialogPage] with the provided parameters
  /// and pushes it onto the navigator.
  ///
  /// Example:
  /// ```dart
  /// final result = await Navigator.of(context).showRawDialog<String>(
  ///   pageBuilder: (context, animation, secondaryAnimation) {
  ///     return MyCustomDialog();
  ///   },
  /// );
  /// ```
  Future<T?> showRawDialog<T>({
    required RoutePageBuilder pageBuilder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder? transitionBuilder,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    TraversalEdgeBehavior? directionalTraversalEdgeBehavior,
    bool? requestFocus,
    String? restorationId,
  }) {
    final page = RawDialogPage<T>(
      pageBuilder: pageBuilder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
      directionalTraversalEdgeBehavior: directionalTraversalEdgeBehavior,
      requestFocus: requestFocus,
      restorationId: restorationId,
    );

    return push<T>(page.createRoute(context));
  }

  /// Pushes a [CupertinoModalPopupPage] onto the navigator.
  ///
  /// This is a convenience method that creates and pushes a
  /// [CupertinoModalPopupPage] in one step, similar to [showCupertinoModalPopup].
  ///
  /// Example:
  /// ```dart
  /// final result = await Navigator.of(context).pushCupertinoModalPopup<String>(
  ///   builder: (context) => CupertinoActionSheet(
  ///     actions: [
  ///       CupertinoActionSheetAction(
  ///         onPressed: () => Navigator.pop(context, 'selected'),
  ///         child: Text('Option'),
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  Future<T?> pushCupertinoModalPopup<T>({
    required WidgetBuilder builder,
    String barrierLabel = 'Dismiss',
    Color? barrierColor = kCupertinoModalBarrierColor,
    bool barrierDismissible = true,
    bool semanticsDismissible = false,
    ImageFilter? filter,
    Offset? anchorPoint,
    bool? requestFocus,
    VoidCallback? onBarrierTap,
    String? barrierOnTapHint,
    String? restorationId,
  }) {
    final page = CupertinoModalPopupPage<T>(
      builder: builder,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      semanticsDismissible: semanticsDismissible,
      filter: filter,
      anchorPoint: anchorPoint,
      requestFocus: requestFocus,
      onBarrierTap: onBarrierTap,
      barrierOnTapHint: barrierOnTapHint,
      restorationId: restorationId,
    );

    return push<T>(page.createRoute(context));
  }

  /// Shows a Cupertino-style dialog by creating and pushing a [CupertinoDialogPage].
  ///
  /// This method provides a declarative alternative to [showCupertinoDialog]
  /// that works with Navigator 2.0.
  ///
  /// Example:
  /// ```dart
  /// final result = await Navigator.of(context).showDeclarativeCupertinoDialog<bool>(
  ///   builder: (context) => CupertinoAlertDialog(
  ///     title: Text('Delete Item'),
  ///     content: Text('Are you sure you want to delete this item?'),
  ///     actions: [
  ///       CupertinoDialogAction(
  ///         onPressed: () => Navigator.pop(context, false),
  ///         child: Text('Cancel'),
  ///       ),
  ///       CupertinoDialogAction(
  ///         onPressed: () => Navigator.pop(context, true),
  ///         isDestructiveAction: true,
  ///         child: Text('Delete'),
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  Future<T?> showDeclarativeCupertinoDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    Duration transitionDuration = const Duration(milliseconds: 250),
    RouteTransitionsBuilder? transitionBuilder,
    bool? requestFocus,
    Offset? anchorPoint,
    VoidCallback? onBarrierTap,
    String? barrierOnTapHint,
    String? restorationId,
  }) {
    final page = CupertinoDialogPage<T>(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
      requestFocus: requestFocus,
      anchorPoint: anchorPoint,
      onBarrierTap: onBarrierTap,
      barrierOnTapHint: barrierOnTapHint,
      restorationId: restorationId,
    );

    return push<T>(page.createRoute(context));
  }

  /// Shows a Cupertino-style sheet by creating and pushing a [CupertinoSheetPage].
  ///
  /// This method provides a declarative alternative for iOS-style sheet presentations.
  ///
  /// Example:
  /// ```dart
  /// final result = await Navigator.of(context).showCupertinoSheet<String>(
  ///   builder: (context) => Container(
  ///     color: CupertinoColors.systemBackground,
  ///     child: SafeArea(
  ///       child: Column(
  ///         children: [
  ///           CupertinoNavigationBar(
  ///             middle: Text('Options'),
  ///             trailing: CupertinoButton(
  ///               child: Text('Done'),
  ///               onPressed: () => Navigator.pop(context, 'done'),
  ///             ),
  ///           ),
  ///           // Content...
  ///         ],
  ///       ),
  ///     ),
  ///   ),
  /// );
  /// ```
  Future<T?> showCupertinoSheet<T>({
    required WidgetBuilder builder,
    bool useNestedNavigation = false,
    GlobalKey<NavigatorState>? nestedNavigatorKey,
    Future<bool> Function()? onWillPop,
    Color? backgroundColor,
    ShapeBorder? shape,
    bool? showDragHandle,
    double? topGapRatio,
    BoxConstraints? constraints,
    bool useSafeArea = false,
    bool enableDrag = true,
    bool isDismissible = true,
    VoidCallback? onBarrierTap,
    Duration? transitionDuration,
    Color? barrierColor,
    bool? barrierDismissible,
    String? barrierLabel,
    String? restorationId,
  }) {
    final page = CupertinoSheetPage<T>(
      builder: builder,
      useNestedNavigation: useNestedNavigation,
      nestedNavigatorKey: nestedNavigatorKey,
      onWillPop: onWillPop,
      backgroundColor: backgroundColor,
      shape: shape,
      showDragHandle: showDragHandle,
      topGapRatio: topGapRatio,
      constraints: constraints,
      useSafeArea: useSafeArea,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      onBarrierTap: onBarrierTap,
      transitionDuration: transitionDuration,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      restorationId: restorationId,
    );

    return push<T>(page.createRoute(context));
  }
}

/// Extension methods for creating popup pages without immediately pushing them.
///
/// These methods are useful when you need to create pages for declarative
/// navigation but don't want to push them immediately.
extension DeclarativePopupBuilders on BuildContext {
  /// Creates a [DialogPage] without pushing it.
  ///
  /// Useful for declarative navigation where you manage the pages list yourself.
  DialogPage<T> createDialogPage<T>({
    required WidgetBuilder builder,
    Offset? anchorPoint,
    Color? barrierColor,
    bool barrierDismissible = true,
    String? barrierLabel,
    bool useSafeArea = true,
    CapturedThemes? themes,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    AnimationStyle? animationStyle,
    bool? requestFocus,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return DialogPage<T>(
      builder: builder,
      anchorPoint: anchorPoint,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ??
          (barrierDismissible
              ? MaterialLocalizations.of(this).modalBarrierDismissLabel
              : null),
      useSafeArea: useSafeArea,
      themes: themes,
      traversalEdgeBehavior: traversalEdgeBehavior,
      animationStyle: animationStyle,
      requestFocus: requestFocus,
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
    );
  }

  /// Creates a [ModalBottomSheetPage] without pushing it.
  ///
  /// Useful for declarative navigation where you manage the pages list yourself.
  ModalBottomSheetPage<T> createModalBottomSheetPage<T>({
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    String? barrierLabel,
    String? barrierOnTapHint,
    CapturedThemes? capturedThemes,
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
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return ModalBottomSheetPage<T>(
      builder: builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierLabel: barrierLabel ?? MaterialLocalizations.of(this).scrimLabel,
      barrierOnTapHint: barrierOnTapHint ??
          MaterialLocalizations.of(this).scrimOnTapHint(
            MaterialLocalizations.of(this).bottomSheetLabel,
          ),
      capturedThemes: capturedThemes ??
          InheritedTheme.capture(
            from: this,
            to: Navigator.of(this).context,
          ),
      modalBarrierColor: modalBarrierColor ??
          Theme.of(this).bottomSheetTheme.modalBarrierColor,
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
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
    );
  }

  /// Creates a [CupertinoDialogPage] without pushing it.
  ///
  /// Useful for declarative navigation where you manage the pages list yourself.
  CupertinoDialogPage<T> createCupertinoDialogPage<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    Duration transitionDuration = const Duration(milliseconds: 250),
    RouteTransitionsBuilder? transitionBuilder,
    bool? requestFocus,
    Offset? anchorPoint,
    VoidCallback? onBarrierTap,
    String? barrierOnTapHint,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CupertinoDialogPage<T>(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
      requestFocus: requestFocus,
      anchorPoint: anchorPoint,
      onBarrierTap: onBarrierTap,
      barrierOnTapHint: barrierOnTapHint,
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
    );
  }

  /// Creates a [CupertinoModalPopupPage] without pushing it.
  ///
  /// Useful for declarative navigation where you manage the pages list yourself.
  CupertinoModalPopupPage<T> createCupertinoModalPopupPage<T>({
    required WidgetBuilder builder,
    String barrierLabel = 'Dismiss',
    Color? barrierColor = kCupertinoModalBarrierColor,
    bool barrierDismissible = true,
    bool semanticsDismissible = false,
    ImageFilter? filter,
    Offset? anchorPoint,
    bool? requestFocus,
    VoidCallback? onBarrierTap,
    String? barrierOnTapHint,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CupertinoModalPopupPage<T>(
      builder: builder,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      semanticsDismissible: semanticsDismissible,
      filter: filter,
      anchorPoint: anchorPoint,
      requestFocus: requestFocus,
      onBarrierTap: onBarrierTap,
      barrierOnTapHint: barrierOnTapHint,
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
    );
  }

  /// Creates a [CupertinoSheetPage] without pushing it.
  ///
  /// Useful for declarative navigation where you manage the pages list yourself.
  CupertinoSheetPage<T> createCupertinoSheetPage<T>({
    required WidgetBuilder builder,
    bool useNestedNavigation = false,
    GlobalKey<NavigatorState>? nestedNavigatorKey,
    Future<bool> Function()? onWillPop,
    Color? backgroundColor,
    ShapeBorder? shape,
    bool? showDragHandle,
    double? topGapRatio,
    BoxConstraints? constraints,
    bool useSafeArea = false,
    bool enableDrag = true,
    bool isDismissible = true,
    VoidCallback? onBarrierTap,
    Duration? transitionDuration,
    Color? barrierColor,
    bool? barrierDismissible,
    String? barrierLabel,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CupertinoSheetPage<T>(
      builder: builder,
      useNestedNavigation: useNestedNavigation,
      nestedNavigatorKey: nestedNavigatorKey,
      onWillPop: onWillPop,
      backgroundColor: backgroundColor,
      shape: shape,
      showDragHandle: showDragHandle,
      topGapRatio: topGapRatio,
      constraints: constraints,
      useSafeArea: useSafeArea,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      onBarrierTap: onBarrierTap,
      transitionDuration: transitionDuration,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
    );
  }

  /// Creates a [RawDialogPage] without pushing it.
  ///
  /// Useful for declarative navigation where you manage the pages list yourself.
  RawDialogPage<T> createRawDialogPage<T>({
    required RoutePageBuilder pageBuilder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder? transitionBuilder,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    TraversalEdgeBehavior? directionalTraversalEdgeBehavior,
    bool? requestFocus,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return RawDialogPage<T>(
      pageBuilder: pageBuilder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
      directionalTraversalEdgeBehavior: directionalTraversalEdgeBehavior,
      requestFocus: requestFocus,
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
    );
  }
}
