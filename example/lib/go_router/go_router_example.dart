import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

class GoRouterExample extends StatefulWidget {
  const GoRouterExample({super.key});

  @override
  State<GoRouterExample> createState() => _GoRouterExampleState();
}

class _GoRouterExampleState extends State<GoRouterExample> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
    );
  }
}
