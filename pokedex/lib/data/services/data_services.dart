import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CacheService<T> {
  final Map<dynamic, T> _cache = {};

  T? get(dynamic key) => _cache[key];

  bool containsKey(dynamic key) => _cache.containsKey(key);

  void put(dynamic key, T value) {
    _cache[key] = value;
  }

  void remove(dynamic key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  int get size => _cache.length;

  T getOrPut(dynamic key, T Function() creator) {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    final value = creator();
    _cache[key] = value;
    return value;
  }
}

class GraphQLExecutor {
  final GraphQLClient client;

  GraphQLExecutor(this.client);

  Future<QueryResult> executeQuery({
    required String query,
    required Map<String, dynamic> variables,
    FetchPolicy fetchPolicy = FetchPolicy.networkOnly,
    ErrorPolicy errorPolicy = ErrorPolicy.all,
    int timeoutSeconds = 10,
  }) async {
    final options = QueryOptions(
      document: gql(query),
      variables: variables,
      fetchPolicy: fetchPolicy,
      errorPolicy: errorPolicy,
    );

    try {
      final result = await client
          .query(options)
          .timeout(Duration(seconds: timeoutSeconds));

      return result;
    } on TimeoutException catch (e) {
      debugPrint('GraphQL timeout for query: $e');
      rethrow;
    } catch (e) {
      debugPrint('GraphQL error: $e');
      rethrow;
    }
  }

  Future<QueryResult?> executeQueryWithFallback({
    required String query,
    required Map<String, dynamic> variables,
    int retries = 1,
  }) async {
    try {
      return await executeQuery(query: query, variables: variables);
    } catch (e) {
      if (retries > 0) {
        debugPrint('Retrying query (retries left: $retries)...');
        await Future.delayed(const Duration(milliseconds: 500));
        return executeQueryWithFallback(
          query: query,
          variables: variables,
          retries: retries - 1,
        );
      }
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      client.cache.store.reset();
      debugPrint('GraphQL cache cleared successfully');
    } catch (e) {
      debugPrint('Error clearing GraphQL cache: $e');
    }
  }

  bool isCacheRelatedError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('cachemiss') ||
        errorString.contains('cache.readquery') ||
        errorString.contains('round trip cache');
  }
}

class PokemonFilterService {
  const PokemonFilterService._();

  static List<T> filterByTypes<T>(
    List<T> items,
    List<String> types,
    List<String> Function(T) typeExtractor,
  ) {
    if (types.isEmpty) return items;

    final lowerTypes = types.map((t) => t.toLowerCase()).toSet();

    return items.where((item) {
      final itemTypes = typeExtractor(item).map((t) => t.toLowerCase());
      return itemTypes.any((t) => lowerTypes.contains(t));
    }).toList();
  }

  static List<T> filterByRegions<T>(
    List<T> items,
    List<List<int>> regionRanges,
    int Function(T) idExtractor,
  ) {
    if (regionRanges.isEmpty) return items;

    return items.where((item) {
      final id = idExtractor(item);
      return regionRanges.any((range) => id >= range[0] && id <= range[1]);
    }).toList();
  }

  static List<T> filterByGenerationIds<T>(
    List<T> items,
    List<int> generationIds,
    int? Function(T) generationIdExtractor,
  ) {
    if (generationIds.isEmpty) return items;

    return items.where((item) {
      final generationId = generationIdExtractor(item);
      return generationId != null && generationIds.contains(generationId);
    }).toList();
  }

  static List<T> filterByQuery<T>(
    List<T> items,
    String query,
    String Function(T) nameExtractor,
  ) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();

    return items.where((item) {
      final name = nameExtractor(item).toLowerCase();
      return name.contains(lowerQuery);
    }).toList();
  }

  static List<T> sort<T>(
    List<T> items,
    String? sortBy,
    bool ascending,
    String Function(T) nameExtractor,
    int Function(T) idExtractor,
  ) {
    if (sortBy == null) return items;

    final sorted = List<T>.from(items);

    if (sortBy == 'name') {
      sorted.sort((a, b) {
        final comparison = nameExtractor(a).compareTo(nameExtractor(b));
        return ascending ? comparison : -comparison;
      });
    } else if (sortBy == 'id') {
      sorted.sort((a, b) {
        final comparison = idExtractor(a).compareTo(idExtractor(b));
        return ascending ? comparison : -comparison;
      });
    }

    return sorted;
  }

  static List<T> paginate<T>(List<T> items, int offset, int limit) {
    if (offset >= items.length) return [];

    final start = offset;
    final end = (offset + limit).clamp(0, items.length);

    return items.sublist(start, end);
  }
}

