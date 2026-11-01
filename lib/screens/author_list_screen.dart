import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/author_query.dart';
import '../state/author_list_notifier.dart';
import '../state/book_list_notifier.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/debounced_field.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/state_views.dart';

class AuthorListScreen extends StatefulWidget {
  const AuthorListScreen({super.key, required this.query});

  final AuthorQuery query;

  @override
  State<AuthorListScreen> createState() => _AuthorListScreenState();
}

class _AuthorListScreenState extends State<AuthorListScreen> {
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant AuthorListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = context.read<AuthorListNotifier>();
      if (notifier.status == LoadStatus.idle ||
          notifier.query.location != widget.query.location) {
        notifier.applyQuery(widget.query);
      }
    });
  }

  void _go(AuthorQuery query) => context.go(query.location);

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AuthorListNotifier>();
    final q = widget.query;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DebouncedField(
                label: 'Фамилия или страна',
                value: q.search,
                width: 260,
                onChanged: (v) => _go(q.copyWith(search: v)),
              ),
              FilterChip(
                label: const Text('Удалённые'),
                selected: q.includeDeleted,
                onSelected: (v) => _go(q.copyWith(includeDeleted: v)),
              ),
              TextButton(
                onPressed: () => context.go('/authors'),
                child: const Text('Сбросить'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Выбрано: ${notifier.selected.length}'),
              const SizedBox(width: 16),
              FilledButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Удалить выбранные'),
                onPressed: !notifier.hasSelection
                    ? null
                    : () async {
                        final count = notifier.selected.length;
                        if (await confirm(context, 'Удалить выбранных авторов ($count)?')) {
                          notifier.deleteSelected();
                        }
                      },
              ),
            ],
          ),
        ),
        Expanded(child: _buildContent(context, notifier)),
        if (notifier.status == LoadStatus.success && notifier.result.total > 0)
          PaginationBar(
            page: notifier.result.page,
            totalPages: notifier.result.totalPages,
            total: notifier.result.total,
            size: q.size,
            onPage: (p) => _go(q.copyWith(page: p)),
            onSize: (s) => _go(q.copyWith(size: s)),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, AuthorListNotifier notifier) {
    final q = widget.query;

    return switch (notifier.status) {
      LoadStatus.idle || LoadStatus.loading => const LoadingView(),
      LoadStatus.error => ErrorView(
          message: notifier.error ?? 'Ошибка',
          onRetry: notifier.load,
        ),
      LoadStatus.success when notifier.result.items.isEmpty =>
        const EmptyView(text: 'Авторы не найдены'),
      LoadStatus.success => EntityTable<Author>(
          items: notifier.result.items,
          idOf: (a) => a.id,
          selected: notifier.selected,
          onToggleSelect: notifier.toggleSelection,
          sortField: q.sortField,
          sortAscending: q.sortAscending,
          onSort: (field) => _go(
            q.copyWith(
              sortField: field,
              sortAscending: field == q.sortField ? !q.sortAscending : true,
            ),
          ),
          columns: [
            TableColumnSpec(
              label: 'ФИО',
              sortField: 'fullName',
              build: (a) => Text(a.fullName),
            ),
            TableColumnSpec(
              label: 'Год рождения',
              sortField: 'birthYear',
              numeric: true,
              build: (a) => Text('${a.birthYear}'),
            ),
            TableColumnSpec(
              label: 'Страна',
              sortField: 'country',
              build: (a) => Text(a.country),
            ),
          ],
          actions: (a) => _actions(context, notifier, a),
        ),
    };
  }

  List<Widget> _actions(
    BuildContext context,
    AuthorListNotifier notifier,
    Author a,
  ) {
    return [
      IconButton(
        tooltip: 'Открыть',
        icon: const Icon(Icons.info_outline),
        onPressed: () => context.go('/authors/${a.id}'),
      ),
      if (a.isDeleted)
        IconButton(
          tooltip: 'Восстановить',
          icon: const Icon(Icons.restore),
          onPressed: () => notifier.restore(a.id),
        )
      else
        IconButton(
          tooltip: 'Удалить',
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            if (await confirm(context, 'Удалить автора «${a.fullName}»?')) {
              notifier.softDelete(a.id);
            }
          },
        ),
      IconButton(
        tooltip: 'Удалить навсегда',
        icon: const Icon(Icons.delete_forever),
        onPressed: () async {
          if (await confirm(
            context,
            'Удалить автора «${a.fullName}» навсегда? Восстановить его будет нельзя.',
          )) {
            notifier.hardDelete(a.id);
          }
        },
      ),
    ];
  }
}
