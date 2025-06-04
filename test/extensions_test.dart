import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_declarative_popups/flutter_declarative_popups.dart';

void main() {
  group('NavigatorState Extensions', () {
    testWidgets('showDeclarativeDialog works correctly', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result =
                      await Navigator.of(context).showDeclarativeDialog<String>(
                    builder: (context) => AlertDialog(
                      title: const Text('Test Dialog'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, 'dialog_result'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result, 'dialog_result');
    });

    testWidgets('showDeclarativeModalBottomSheet works correctly',
        (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context)
                      .showDeclarativeModalBottomSheet<String>(
                    builder: (context) => SizedBox(
                      height: 200,
                      child: Center(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pop(context, 'sheet_result'),
                          child: const Text('Close Sheet'),
                        ),
                      ),
                    ),
                    showDragHandle: true,
                  );
                },
                child: const Text('Show Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Close Sheet'), findsOneWidget);

      await tester.tap(find.text('Close Sheet'));
      await tester.pumpAndSettle();

      expect(result, 'sheet_result');
    });

    testWidgets('showDeclarativeCupertinoDialog works correctly',
        (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context)
                      .showDeclarativeCupertinoDialog<String>(
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Test Dialog'),
                      content: const Text('This is a test'),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () =>
                              Navigator.pop(context, 'cancel_result'),
                          child: const Text('Cancel'),
                        ),
                        CupertinoDialogAction(
                          onPressed: () => Navigator.pop(context, 'ok_result'),
                          isDefaultAction: true,
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Show Cupertino Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Cupertino Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result, 'ok_result');
    });

    testWidgets('showCupertinoSheet works correctly', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result =
                      await Navigator.of(context).showCupertinoSheet<String>(
                    builder: (context) => Container(
                      color: CupertinoColors.systemBackground,
                      child: SafeArea(
                        child: Column(
                          children: [
                            CupertinoNavigationBar(
                              middle: const Text('Cupertino Sheet'),
                              trailing: CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: const Text('Done'),
                                onPressed: () =>
                                    Navigator.pop(context, 'cupertino_result'),
                              ),
                            ),
                            const Expanded(
                                child: Center(child: Text('Content'))),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Show Cupertino Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Cupertino Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Cupertino Sheet'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(result, 'cupertino_result');
    });
  });

  group('BuildContext Extensions', () {
    testWidgets('createDialogPage creates a valid page', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final page = context.createDialogPage<String>(
                builder: (context) => const AlertDialog(
                  title: Text('Created Dialog'),
                ),
              );

              expect(page, isA<DialogPage<String>>());
              expect(page.builder, isNotNull);

              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );
    });

    testWidgets('createModalBottomSheetPage creates a valid page',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final page = context.createModalBottomSheetPage<String>(
                builder: (context) => const SizedBox(height: 200),
                showDragHandle: true,
              );

              expect(page, isA<ModalBottomSheetPage<String>>());
              expect(page.builder, isNotNull);
              expect(page.showDragHandle, true);

              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );
    });

    testWidgets('createCupertinoDialogPage creates a valid page',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final page = context.createCupertinoDialogPage<String>(
                builder: (context) => const CupertinoAlertDialog(
                  title: Text('Created Dialog'),
                ),
                barrierDismissible: false,
                transitionDuration: const Duration(milliseconds: 300),
              );

              expect(page, isA<CupertinoDialogPage<String>>());
              expect(page.builder, isNotNull);
              expect(page.barrierDismissible, false);
              expect(
                  page.transitionDuration, const Duration(milliseconds: 300));

              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );
    });

    testWidgets('createCupertinoModalPopupPage creates a valid page',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final page = context.createCupertinoModalPopupPage<String>(
                builder: (context) => const CupertinoActionSheet(
                  actions: [],
                ),
              );

              expect(page, isA<CupertinoModalPopupPage<String>>());
              expect(page.builder, isNotNull);

              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );
    });

    testWidgets('createCupertinoSheetPage creates a valid page',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final page = context.createCupertinoSheetPage<String>(
                builder: (context) => Container(),
                useNestedNavigation: true,
              );

              expect(page, isA<CupertinoSheetPage<String>>());
              expect(page.builder, isNotNull);
              expect(page.useNestedNavigation, true);

              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );
    });

    testWidgets('createRawDialogPage creates a valid page', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final page = context.createRawDialogPage<String>(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return const Center(child: Text('Raw Dialog'));
                },
                barrierLabel: 'Test',
              );

              expect(page, isA<RawDialogPage<String>>());
              expect(page.pageBuilder, isNotNull);
              expect(page.barrierLabel, 'Test');

              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );
    });
  });

  group('Integration with Declarative Navigation', () {
    testWidgets('CupertinoDialogPage works with declarative navigation',
        (tester) async {
      bool showDialog = false;

      // Create a stateful widget that properly manages state
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Navigator(
                pages: [
                  MaterialPage(
                    child: Scaffold(
                      body: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showDialog = true;
                            });
                          },
                          child: const Text('Show Cupertino Dialog'),
                        ),
                      ),
                    ),
                  ),
                  if (showDialog)
                    context.createCupertinoDialogPage<String>(
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Declarative Cupertino Dialog'),
                        content: const Text('This is a declarative dialog'),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () => Navigator.pop(context),
                            isDestructiveAction: true,
                            child: const Text('Cancel'),
                          ),
                          CupertinoDialogAction(
                            onPressed: () =>
                                Navigator.pop(context, 'confirmed'),
                            isDefaultAction: true,
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    ),
                ],
                onDidRemovePage: (page) {
                  setState(() {
                    showDialog = false;
                  });
                },
              );
            },
          ),
        ),
      );

      expect(find.text('Show Cupertino Dialog'), findsOneWidget);
      expect(find.text('Declarative Cupertino Dialog'), findsNothing);

      // Tap button to show dialog
      await tester.tap(find.text('Show Cupertino Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Declarative Cupertino Dialog'), findsOneWidget);

      // Tap Confirm to close dialog
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Declarative Cupertino Dialog'), findsNothing);
      expect(find.text('Show Cupertino Dialog'), findsOneWidget);
    });

    testWidgets('pages created with extensions work in Navigator pages list',
        (tester) async {
      bool showDialog = false;

      // Create a stateful widget that properly manages state
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Navigator(
                pages: [
                  MaterialPage(
                    child: Scaffold(
                      body: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showDialog = true;
                            });
                          },
                          child: const Text('Show Dialog'),
                        ),
                      ),
                    ),
                  ),
                  if (showDialog)
                    context.createDialogPage<String>(
                      builder: (context) => AlertDialog(
                        title: const Text('Declarative Dialog'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, 'declarative_result'),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                ],
                onDidRemovePage: (page) {
                  setState(() {
                    showDialog = false;
                  });
                },
              );
            },
          ),
        ),
      );

      expect(find.text('Show Dialog'), findsOneWidget);
      expect(find.text('Declarative Dialog'), findsNothing);

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Declarative Dialog'), findsOneWidget);

      // Tap OK to close dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // With the new onDidRemovePage API, result capture is not available
      // in the callback. The test verifies the popup works correctly.
      expect(find.text('Declarative Dialog'), findsNothing);
      expect(find.text('Show Dialog'), findsOneWidget);
    });
  });
}
