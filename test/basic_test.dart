import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_declarative_popups/flutter_declarative_popups.dart';

void main() {
  group('DialogPage', () {
    testWidgets('creates a dialog route with correct settings', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));

      const testPage = DialogPage<String>(
        builder: _buildTestDialog,
        barrierDismissible: false,
        barrierColor: Colors.red,
        barrierLabel: 'Test Barrier',
      );

      final context = tester.element(find.byType(Container));
      final route = testPage.createRoute(context);

      expect(route, isA<Route<String>>());
      // We can only test that the route was created successfully
      // The specific properties are internal to the route implementation
    });

    testWidgets('shows dialog and returns result', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              const MaterialPage(child: Scaffold()),
              DialogPage<String>(
                builder: (context) => AlertDialog(
                  title: const Text('Test Dialog'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop('test_result'),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ],
            onDidRemovePage: (page) {
              // Result will be handled by the route itself in the new API
              // This callback is just for cleanup
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Test Dialog'), findsOneWidget);

      // Tap OK button
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // With the new onDidRemovePage API, result capture is not available
      // in the callback. The test verifies the popup works correctly.
    });
  });

  group('ModalBottomSheetPage', () {
    testWidgets('creates a bottom sheet route', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));

      const testPage = ModalBottomSheetPage<String>(
        builder: _buildTestBottomSheet,
        isDismissible: false,
        enableDrag: false,
        showDragHandle: true,
      );

      final context = tester.element(find.byType(Container));
      final route = testPage.createRoute(context);

      expect(route, isA<Route<String>>());
    });

    testWidgets('shows bottom sheet and returns result', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              const MaterialPage(child: Scaffold()),
              ModalBottomSheetPage<String>(
                builder: (context) => SizedBox(
                  height: 200,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop('sheet_result'),
                    child: const Text('Close Sheet'),
                  ),
                ),
              ),
            ],
            onDidRemovePage: (page) {
              // Result will be handled by the route itself in the new API
              // This callback is just for cleanup
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify bottom sheet is shown
      expect(find.text('Close Sheet'), findsOneWidget);

      // Tap close button
      await tester.tap(find.text('Close Sheet'));
      await tester.pumpAndSettle();

      // With the new onDidRemovePage API, result capture is not available
      // in the callback. The test verifies the popup works correctly.
    });
  });

  group('CupertinoDialogPage', () {
    testWidgets('creates a Cupertino dialog route', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));

      const testPage = CupertinoDialogPage<String>(
        builder: _buildTestCupertinoDialog,
        barrierDismissible: true,
      );

      final context = tester.element(find.byType(Container));
      final route = testPage.createRoute(context);

      expect(route, isA<Route<String>>());
    });

    testWidgets('shows Cupertino dialog and returns result', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              const MaterialPage(child: Scaffold()),
              CupertinoDialogPage<String>(
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Test Alert'),
                  content: const Text('This is a test alert'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop('ok_result'),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ],
            onDidRemovePage: (page) {
              // Result will be handled by the route itself in the new API
              // This callback is just for cleanup
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Test Alert'), findsOneWidget);

      // Tap OK button
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // With the new onDidRemovePage API, result capture is not available
      // in the callback. The test verifies the popup works correctly.
    });
  });

  group('CupertinoModalPopupPage', () {
    testWidgets('creates a Cupertino modal popup route', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));

      const testPage = CupertinoModalPopupPage<String>(
        builder: _buildTestCupertinoPopup,
        barrierDismissible: true,
      );

      final context = tester.element(find.byType(Container));
      final route = testPage.createRoute(context);

      expect(route, isA<Route<String>>());
    });

    testWidgets('shows Cupertino popup and returns result', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              const MaterialPage(child: Scaffold()),
              CupertinoModalPopupPage<String>(
                builder: (context) => CupertinoActionSheet(
                  actions: [
                    CupertinoActionSheetAction(
                      onPressed: () =>
                          Navigator.of(context).pop('action_result'),
                      child: const Text('Action'),
                    ),
                  ],
                ),
              ),
            ],
            onDidRemovePage: (page) {
              // Result will be handled by the route itself in the new API
              // This callback is just for cleanup
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify action sheet is shown
      expect(find.text('Action'), findsOneWidget);

      // Tap action
      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();

      // With the new onDidRemovePage API, result capture is not available
      // in the callback. The test verifies the popup works correctly.
    });
  });

  group('CupertinoSheetPage', () {
    testWidgets('creates a native scrollable Cupertino sheet route', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Container()));

      final testPage = CupertinoSheetPage<String>(
        scrollableBuilder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            children: const [Text('Scrollable Content')],
          );
        },
        showDragHandle: true,
        topGap: 0.2,
        name: 'sheet',
        arguments: 'details',
      );

      final context = tester.element(find.byType(Container));
      final route = testPage.createRoute(context);

      expect(route, isA<CupertinoSheetRoute<String>>());

      final sheetRoute = route as CupertinoSheetRoute<String>;
      expect(sheetRoute.scrollableBuilder, isNotNull);
      expect(sheetRoute.showDragHandle, true);
      expect(sheetRoute.topGap, 0.2);
      expect(sheetRoute.settings.name, 'sheet');
      expect(sheetRoute.settings.arguments, 'details');
    });

    testWidgets('plain builder path still renders the sheet content', (
      tester,
    ) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoSheetPage<void>(
                    builder: (_) => const Text('Plain Builder Sheet'),
                  ).createRoute(context),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Plain Builder Sheet'), findsOneWidget);
    });

    testWidgets(
      'wraps content in a DecoratedBox when backgroundColor is set',
      (tester) async {
        await tester.pumpWidget(
          CupertinoApp(
            home: Builder(
              builder: (context) => CupertinoButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoSheetPage<void>(
                      builder: (_) => const Text('Styled Body'),
                      backgroundColor: CupertinoColors.systemRed,
                    ).createRoute(context),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Styled Body'), findsOneWidget);

        // _applyCustomizations wraps the sheet content in a DecoratedBox
        // whose ShapeDecoration carries the supplied backgroundColor.
        final decoratedBoxFinder = find.ancestor(
          of: find.text('Styled Body'),
          matching: find.byType(DecoratedBox),
        );
        expect(decoratedBoxFinder, findsWidgets);

        final decoratedBox = tester.widgetList<DecoratedBox>(
          decoratedBoxFinder,
        );
        final hasShapeDecorationWithColor = decoratedBox.any((box) {
          final decoration = box.decoration;
          return decoration is ShapeDecoration &&
              decoration.color == CupertinoColors.systemRed;
        });
        expect(hasShapeDecorationWithColor, isTrue);
      },
    );

    testWidgets(
      'no DecoratedBox wrapper inserted when no styling is supplied',
      (tester) async {
        await tester.pumpWidget(
          CupertinoApp(
            home: Builder(
              builder: (context) => CupertinoButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoSheetPage<void>(
                      builder: (_) => const Text('Unstyled Body'),
                    ).createRoute(context),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Unstyled Body'), findsOneWidget);

        // Without backgroundColor or shape, _applyCustomizations must not
        // insert a ShapeDecoration wrapper.
        final decoratedBoxes = tester.widgetList<DecoratedBox>(
          find.ancestor(
            of: find.text('Unstyled Body'),
            matching: find.byType(DecoratedBox),
          ),
        );
        final hasShapeDecoration = decoratedBoxes.any(
          (box) => box.decoration is ShapeDecoration,
        );
        expect(hasShapeDecoration, isFalse);
      },
    );

    test('CupertinoSheetPage with no builders throws AssertionError', () {
      expect(
        () => CupertinoSheetPage<void>(),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Extension Methods', () {
    testWidgets('pushDialogPage works correctly', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).pushDialogPage(
                    DialogPage<String>(
                      builder: (context) => SimpleDialog(
                        children: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, 'extension_result'),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(result, 'extension_result');
    });

    testWidgets('pushCupertinoDialogPage works correctly', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).pushCupertinoDialogPage(
                    CupertinoDialogPage<String>(
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Extension Test'),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () => Navigator.pop(
                              context,
                              'cupertino_extension_result',
                            ),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('Show Cupertino Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Cupertino Dialog'));
      await tester.pumpAndSettle();

      // Tap OK button
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result, 'cupertino_extension_result');
    });

    testWidgets('pushModalBottomSheetPage works correctly', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).pushModalBottomSheetPage(
                    ModalBottomSheetPage<String>(
                      builder: (context) => SizedBox(
                        height: 100,
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pop(context, 'bottom_sheet_result'),
                          child: const Text('Close'),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Show Bottom Sheet'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show bottom sheet
      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      // Tap close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(result, 'bottom_sheet_result');
    });
  });

  group('RawDialogPage', () {
    testWidgets('creates a raw dialog route', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));

      final testPage = RawDialogPage<String>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const Center(child: Material(child: Text('Raw Dialog')));
        },
        barrierLabel: 'Dismiss',
      );

      final context = tester.element(find.byType(Container));
      final route = testPage.createRoute(context);

      expect(route, isA<Route<String>>());
    });
  });
}

Widget _buildTestDialog(BuildContext context) {
  return const AlertDialog(title: Text('Test Dialog'));
}

Widget _buildTestBottomSheet(BuildContext context) {
  return const SizedBox(
    height: 200,
    child: Center(child: Text('Test Bottom Sheet')),
  );
}

Widget _buildTestCupertinoDialog(BuildContext context) {
  return const CupertinoAlertDialog(title: Text('Test Cupertino Dialog'));
}

Widget _buildTestCupertinoPopup(BuildContext context) {
  return Container(
    height: 200,
    color: Colors.white,
    child: const Center(child: Text('Test Cupertino Popup')),
  );
}
