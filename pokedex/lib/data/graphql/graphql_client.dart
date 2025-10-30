// Servicio que inicializa el cliente GraphQL para PokeAPI
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static ValueNotifier<GraphQLClient> initClient() {
    final HttpLink httpLink = HttpLink('https://beta.pokeapi.co/graphql/v1beta');

    final GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
    );

    return ValueNotifier(client);
  }
}

