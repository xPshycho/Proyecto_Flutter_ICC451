// Servicio que inicializa el cliente GraphQL para PokeAPI
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static ValueNotifier<GraphQLClient> initClient() {
    final HttpLink httpLink = HttpLink(
      'https://beta.pokeapi.co/graphql/v1beta',
      defaultHeaders: {
        'Content-Type': 'application/json',
      },
    );

    // Política de reintentos para manejar fallos de red
    final Link link = httpLink;

    final GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.cacheAndNetwork,
          error: ErrorPolicy.all,
          cacheRereadPolicy: CacheRereadPolicy.mergeOptimistic,
        ),
        mutate: Policies(
          fetch: FetchPolicy.networkOnly,
          error: ErrorPolicy.all,
        ),
      ),
    );

    return ValueNotifier(client);
  }
}

