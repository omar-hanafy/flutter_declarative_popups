/// Flutter Declarative Popups - Routing Examples
///
/// This example demonstrates how to use flutter_declarative_popups with
/// different routing approaches in Flutter:
///
/// 1. **Navigator 2.0** (Default) - Direct RouterDelegate implementation
///    - Full control over navigation stack
///    - Native support for declarative popup pages
///
/// 2. **Navigator 1.0** - Classic imperative navigation
///    - Shows both imperative popups and declarative pages
///    - Limited to push/pop navigation
///
/// 3. **go_router** - Official declarative routing package
///    - Excellent support for path-based popup routes
///    - Each popup has its own URL path
///
/// 4. **auto_route** - Code generation based routing
///    - Type-safe navigation but limited popup support
///    - Uses imperative popups alongside page routing
library;

import 'package:flutter/material.dart';

import 'go_router/go_router_example.dart';
import 'navigator_1/navigator_1_example.dart';
import 'navigator_2/navigator_2_example.dart';

void main() {
  runApp(const RoutingSelectorApp());
}

enum RoutingType {
  navigator2('Navigator 2.0', 'Direct implementation using RouterDelegate'),
  navigator1('Navigator 1.0', 'Classic imperative navigation'),
  goRouter('go_router', 'Official declarative routing package');

  final String title;
  final String description;

  const RoutingType(this.title, this.description);
}

class RoutingSelectorApp extends StatelessWidget {
  const RoutingSelectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Declarative Popups Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RoutingSelectorScreen(),
    );
  }
}

class RoutingSelectorScreen extends StatefulWidget {
  const RoutingSelectorScreen({super.key});

  @override
  State<RoutingSelectorScreen> createState() => _RoutingSelectorScreenState();
}

class _RoutingSelectorScreenState extends State<RoutingSelectorScreen> {
  RoutingType _selectedRouting =
      RoutingType.navigator2; // Default to Navigator 2.0

  Widget _buildExample() {
    switch (_selectedRouting) {
      case RoutingType.navigator2:
        return Navigator2Example();
      case RoutingType.navigator1:
        return const Navigator1Example();
      case RoutingType.goRouter:
        return GoRouterExample();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Declarative Popups Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<RoutingType>(
              value: _selectedRouting,
              underline: const SizedBox(),
              dropdownColor: Theme.of(context).colorScheme.primaryContainer,
              items: RoutingType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRouting = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedRouting.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedRouting.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildExample(),
          ),
        ],
      ),
    );
  }
}
