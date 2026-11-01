import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Библиотека'),
        actions: [
          _NavButton(
            label: 'Книги',
            active: path.startsWith('/books'),
            onPressed: () => context.go('/books'),
          ),
          _NavButton(
            label: 'Авторы',
            active: path.startsWith('/authors'),
            onPressed: () => context.go('/authors'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: child,
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
