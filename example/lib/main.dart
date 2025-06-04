import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_declarative_popups/flutter_declarative_popups.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Declarative Popups Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State for controlling which popup to show
  PopupType? _activePopup;
  String? _lastResult;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Declarative Popups Demo'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_lastResult != null) ...[
                    Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Result:',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _lastResult!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // New section demonstrating extension methods
                  _buildSection(context, 'Extension Methods (Direct Push)', [
                    _buildButton(
                      context,
                      'Show Dialog (Extension)',
                      Icons.new_releases,
                      () async {
                        final result = await Navigator.of(context)
                            .showDeclarativeDialog<String>(
                              builder: (context) => AlertDialog(
                                title: const Text('Extension Method Dialog'),
                                content: const Text(
                                  'This dialog was shown using the '
                                  'showDeclarativeDialog extension method',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop('Cancelled'),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.of(
                                      context,
                                    ).pop('Confirmed via Extension'),
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                            );
                        if (result != null) {
                          setState(() => _lastResult = result);
                        }
                      },
                    ),
                    _buildButton(
                      context,
                      'Show Bottom Sheet (Extension)',
                      Icons.open_in_new,
                      () async {
                        final result = await Navigator.of(context)
                            .showDeclarativeModalBottomSheet<String>(
                              builder: (context) => Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Extension Method Bottom Sheet',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Created with '
                                      'showDeclarativeModalBottomSheet',
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(
                                        context,
                                      ).pop('Sheet Extension Result'),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              ),
                              showDragHandle: true,
                            );
                        if (result != null) {
                          setState(() => _lastResult = result);
                        }
                      },
                    ),
                    _buildButton(
                      context,
                      'Show Cupertino Sheet (Extension)',
                      CupertinoIcons.square_stack_3d_up,
                      () async {
                        final result = await Navigator.of(context)
                            .showCupertinoSheet<String>(
                              builder: (context) => Container(
                                color: CupertinoColors.systemBackground,
                                child: SafeArea(
                                  child: Column(
                                    children: [
                                      CupertinoNavigationBar(
                                        middle: const Text(
                                          'Extension Cupertino Sheet',
                                        ),
                                        trailing: CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          child: const Text('Done'),
                                          onPressed: () => Navigator.of(
                                            context,
                                          ).pop('Cupertino Extension Done'),
                                        ),
                                      ),
                                      const Expanded(
                                        child: Center(
                                          child: Text(
                                            'Created with '
                                            'showCupertinoSheet extension',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              showDragHandle: true,
                            );
                        if (result != null) {
                          setState(() => _lastResult = result);
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection(context, 'Material Design (Declarative)', [
                    _buildButton(
                      context,
                      'Show Dialog',
                      Icons.chat_bubble_outline,
                      () => setState(() => _activePopup = PopupType.dialog),
                    ),
                    _buildButton(
                      context,
                      'Show Bottom Sheet',
                      Icons.vertical_align_bottom,
                      () =>
                          setState(() => _activePopup = PopupType.bottomSheet),
                    ),
                    _buildButton(
                      context,
                      'Show Scrollable Bottom Sheet',
                      Icons.format_list_bulleted,
                      () => setState(
                        () => _activePopup = PopupType.scrollableBottomSheet,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection(context, 'Cupertino (iOS Style)', [
                    _buildButton(
                      context,
                      'Show Action Sheet',
                      CupertinoIcons.square_list,
                      () =>
                          setState(() => _activePopup = PopupType.actionSheet),
                    ),
                    _buildButton(
                      context,
                      'Show Cupertino Sheet',
                      CupertinoIcons.square_arrow_up,
                      () => setState(
                        () => _activePopup = PopupType.cupertinoSheet,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection(context, 'Custom Implementations', [
                    _buildButton(
                      context,
                      'Show Custom Dialog',
                      Icons.auto_awesome,
                      () =>
                          setState(() => _activePopup = PopupType.customDialog),
                    ),
                    _buildButton(
                      context,
                      'Show Nested Navigation Sheet',
                      Icons.layers,
                      () => setState(
                        () => _activePopup = PopupType.nestedNavigation,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    'Page Builders (For Declarative Nav)',
                    [
                    _buildButton(
                      context,
                      'Create Dialog Page',
                      Icons.construction,
                      () {
                        final page = context.createDialogPage<String>(
                          builder: (context) => AlertDialog(
                            title: const Text('Created Page'),
                            content: const Text(
                              'This DialogPage was created using '
                              'createDialogPage',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(
                                  context,
                                ).pop('Created Page Result'),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        // For demonstration, we'll push it immediately
                        Navigator.of(
                          context,
                        ).push(page.createRoute(context)).then((result) {
                          if (result != null) {
                            setState(() => _lastResult = result);
                          }
                        });
                      },
                    ),
                    _buildButton(
                      context,
                      'Create Raw Dialog Page',
                      Icons.widgets,
                      () {
                        final page = context.createRawDialogPage<String>(
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsets.all(20),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Raw Dialog Page',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Created with createRawDialogPage',
                                          ),
                                          const SizedBox(height: 24),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop('Raw Page Result'),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                          barrierLabel: 'Dismiss',
                        );
                        Navigator.of(
                          context,
                        ).push(page.createRoute(context)).then((result) {
                          if (result != null) {
                            setState(() => _lastResult = result);
                          }
                        });
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
        // Add popup pages based on active popup state
        if (_activePopup == PopupType.dialog)
          DialogPage<String>(
            builder: (context) => AlertDialog(
              title: const Text('Declarative Dialog'),
              content: const Text(
                'This dialog was shown using DialogPage with Navigator 2.0',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop('Cancelled'),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop('Confirmed'),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        if (_activePopup == PopupType.bottomSheet)
          ModalBottomSheetPage<String>(
            builder: (context) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bottom Sheet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This is a modal bottom sheet created with '
                    'ModalBottomSheetPage',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop('Option 1'),
                        child: const Text('Option 1'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop('Option 2'),
                        child: const Text('Option 2'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop('Option 3'),
                        child: const Text('Option 3'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            showDragHandle: true,
            enableDrag: true,
          ),
        if (_activePopup == PopupType.scrollableBottomSheet)
          ModalBottomSheetPage<String>(
            isScrollControlled: true,
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.25,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Scrollable List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: 50,
                        itemBuilder: (context, index) => ListTile(
                          leading: CircleAvatar(child: Text('$index')),
                          title: Text('Item $index'),
                          onTap: () =>
                              Navigator.of(context).pop('Selected item $index'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_activePopup == PopupType.actionSheet)
          CupertinoModalPopupPage<String>(
            builder: (context) => CupertinoActionSheet(
              title: const Text('Select an Option'),
              message: const Text(
                'This action sheet was created using CupertinoModalPopupPage',
              ),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop('Camera'),
                  child: const Text('Camera'),
                ),
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop('Gallery'),
                  child: const Text('Photo Gallery'),
                ),
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop('Delete'),
                  isDestructiveAction: true,
                  child: const Text('Delete'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop('Cancelled'),
                isDefaultAction: true,
                child: const Text('Cancel'),
              ),
            ),
          ),
        if (_activePopup == PopupType.cupertinoSheet)
          CupertinoSheetPage<String>(
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
                        onPressed: () => Navigator.of(context).pop('Done'),
                      ),
                    ),
                    Expanded(
                      child: CupertinoScrollbar(
                        child: ListView(
                          children: List.generate(
                            20,
                            (index) => CupertinoListTile(
                              title: Text('Option ${index + 1}'),
                              trailing: const CupertinoListTileChevron(),
                              onTap: () => Navigator.of(
                                context,
                              ).pop('Selected option ${index + 1}'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            showDragHandle: true,
          ),
        if (_activePopup == PopupType.customDialog)
          RawDialogPage<String>(
            pageBuilder: (context, animation, secondaryAnimation) {
              return Center(
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.elasticOut,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 48,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Custom Dialog!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This is a completely custom dialog using '
                          'RawDialogPage',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pop('Awesome!'),
                          child: const Text('Cool!'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            barrierDismissible: true,
            barrierColor: Colors.black54,
            barrierLabel: 'Dismiss',
            transitionDuration: const Duration(milliseconds: 600),
          ),
        if (_activePopup == PopupType.nestedNavigation)
          CupertinoSheetPage<String>(
            useNestedNavigation: true,
            showDragHandle: true,
            builder: (context) => const NestedNavigationExample(),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        setState(() {
          _activePopup = null;
          if (result != null) {
            _lastResult = result.toString();
          }
        });
        return true;
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}

// Nested navigation example widget
class NestedNavigationExample extends StatefulWidget {
  const NestedNavigationExample({super.key});

  @override
  State<NestedNavigationExample> createState() =>
      _NestedNavigationExampleState();
}

class _NestedNavigationExampleState extends State<NestedNavigationExample> {
  int _currentStep = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AppBar(
            title: const Text('Multi-Step Form'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  // This will close the entire sheet because we're using
                  // rootNavigator: true due to nested navigation
                  Navigator.of(context, rootNavigator: true).pop('Closed');
                },
              ),
            ],
          ),
          Expanded(
            child: Stepper(
              currentStep: _currentStep - 1,
              onStepTapped: (step) => setState(() => _currentStep = step + 1),
              onStepContinue: () {
                if (_currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop('Completed all steps');
                }
              },
              onStepCancel: () {
                if (_currentStep > 1) {
                  setState(() => _currentStep--);
                }
              },
              steps: [
                Step(
                  title: const Text('Step 1'),
                  content: const Text('This is step 1 content'),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: const Text('Step 2'),
                  content: const Text('This is step 2 content'),
                  isActive: _currentStep >= 2,
                ),
                Step(
                  title: const Text('Step 3'),
                  content: const Text('This is the final step'),
                  isActive: _currentStep >= 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum PopupType {
  dialog,
  bottomSheet,
  scrollableBottomSheet,
  actionSheet,
  cupertinoSheet,
  customDialog,
  nestedNavigation,
}
