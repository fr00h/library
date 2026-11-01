import 'package:go_router/go_router.dart';

import 'models/author_query.dart';
import 'models/book_query.dart';
import 'screens/author_detail_screen.dart';
import 'screens/author_list_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/book_list_screen.dart';
import 'screens/not_found_screen.dart';
import 'widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/books',
  errorBuilder: (context, state) =>
      NotFoundScreen(location: state.uri.toString()),
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/books'),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/books',
          builder: (context, state) => BookListScreen(
            query: BookQuery.fromParams(state.uri.queryParameters),
          ),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => BookDetailScreen(
                id: int.tryParse(state.pathParameters['id']!) ?? 0,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/authors',
          builder: (context, state) => AuthorListScreen(
            query: AuthorQuery.fromParams(state.uri.queryParameters),
          ),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => AuthorDetailScreen(
                id: int.tryParse(state.pathParameters['id']!) ?? 0,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
