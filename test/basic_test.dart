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
      String? result;

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
            onPopPage: (route, res) {
              result = res as String?;
              return route.didPop(res);
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

      // Verify result
      expect(result, 'test_result');
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
      String? result;

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
            onPopPage: (route, res) {
              result = res as String?;
              return route.didPop(res);
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

      // Verify result
      expect(result, 'sheet_result');
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
      String? result;

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
            onPopPage: (route, res) {
              result = res as String?;
              return route.didPop(res);
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

      // Verify result
      expect(result, 'action_result');
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
          return const Center(
            child: Material(
              child: Text('Raw Dialog'),
            ),
          );
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
  return const AlertDialog(
    title: Text('Test Dialog'),
  );
}

Widget _buildTestBottomSheet(BuildContext context) {
  return const SizedBox(
    height: 200,
    child: Center(
      child: Text('Test Bottom Sheet'),
    ),
  );
}

Widget _buildTestCupertinoPopup(BuildContext context) {
  return Container(
    height: 200,
    color: Colors.white,
    child: const Center(
      child: Text('Test Cupertino Popup'),
    ),
  );
}
