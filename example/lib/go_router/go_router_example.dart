import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

class GoRouterExample extends StatelessWidget {
  GoRouterExample({super.key});

  final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
    );
  }
}
