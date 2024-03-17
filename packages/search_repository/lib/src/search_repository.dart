// ignore_for_file: prefer_constructors_over_static_methods

import 'package:database_client/database_client.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

/// {@template search_repository}
/// A package that manages search result data flow.
/// {@endtemplate}
class SearchRepository {
  /// {@macro search_repository}
  SearchRepository({required DatabaseClient client}) : _client = client;

  final DatabaseClient _client;

  final _usersHashedQueryResults = <String, Future<List<User>>>{};

  /// Generates a specific hash for each query and if hash already exists in the
  /// cache, returns the cached result. Otherwise queries for users and caches
  /// the result.
  Future<List<User>> searchUsers({
    required String query,
    int limit = 8,
    int offset = 0,
    String? excludeUserIds,
  }) async {
    final hash = generateHash([query, limit, offset]);
    if (_usersHashedQueryResults.containsKey(hash)) {
      logD('Return hashed results');
      if (query.trim().isEmpty) return <User>[];
      return _usersHashedQueryResults[hash]!;
    }

    logD("Didn't found hashed results, querying for users...");

    final users = _client.searchUsers(
      userId: _client.currentUserId!,
      limit: limit,
      offset: offset,
      query: query,
    );

    _usersHashedQueryResults[hash] = users;
    return users;
  }
}
