import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../state/author_list_notifier.dart';
import '../widgets/state_views.dart';

class AuthorDetailScreen extends StatefulWidget {
  const AuthorDetailScreen({super.key, required this.id});

  final int id;

  @override
  State<AuthorDetailScreen> createState() => _AuthorDetailScreenState();
}

class _AuthorDetailScreenState extends State<AuthorDetailScreen> {
  late Future<Author?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AuthorListNotifier>().findById(widget.id);
  }

  void _retry() {
    setState(() {
      _future = context.read<AuthorListNotifier>().findById(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Author?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: 'Не удалось загрузить автора: ${snapshot.error}',
            onRetry: _retry,
          );
        }
        final author = snapshot.data;
        if (author == null) {
          return const EmptyView(text: 'Автор не найден');
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author.fullName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (author.isDeleted)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Chip(label: Text('Удалён')),
                          ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Год рождения'),
                          subtitle: Text('${author.birthYear}'),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Страна'),
                          subtitle: Text(author.country),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => context.go('/authors'),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('К списку авторов'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
