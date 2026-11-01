class AuthorQuery {
  final String search;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const AuthorQuery({
    this.search = '',
    this.sortField = 'fullName',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  AuthorQuery copyWith({
    String? search,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return AuthorQuery(
      search: search ?? this.search,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  factory AuthorQuery.fromParams(Map<String, String> p) {
    final sort = (p['sort'] ?? 'fullName,asc').split(',');
    return AuthorQuery(
      search: p['search'] ?? '',
      sortField: sort.first,
      sortAscending: sort.length < 2 || sort[1] != 'desc',
      page: int.tryParse(p['page'] ?? '') ?? 1,
      size: int.tryParse(p['size'] ?? '') ?? 10,
      includeDeleted: p['includeDeleted'] == 'true',
    );
  }

  Map<String, String> toParams() => {
        if (search.isNotEmpty) 'search': search,
        if (sortField != 'fullName' || !sortAscending)
          'sort': '$sortField,${sortAscending ? 'asc' : 'desc'}',
        if (page != 1) 'page': '$page',
        if (size != 10) 'size': '$size',
        if (includeDeleted) 'includeDeleted': 'true',
      };

  String get location {
    final params = toParams();
    if (params.isEmpty) return '/authors';
    final query = params.entries
        .map((e) =>
            '${e.key}=${Uri.encodeComponent(e.value).replaceAll('%2C', ',')}')
        .join('&');
    return '/authors?$query';
  }
}
