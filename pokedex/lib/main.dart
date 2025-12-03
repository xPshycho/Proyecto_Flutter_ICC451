import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'theme/light_theme.dart';
import 'theme/dark_theme.dart';
import 'data/graphql/graphql_client.dart';
import 'data/repositories/pokemon_repository.dart';
import 'data/favorites_service.dart';
import 'presentation/bloc/pokemon/pokemon_bloc.dart';
import 'presentation/bloc/pokemon/pokemon_event.dart';
import 'presentation/bloc/favorites/favorites_bloc.dart';
import 'presentation/bloc/moves/moves_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  final clientNotifier = GraphQLService.initClient();
  runApp(MyApp(clientNotifier: clientNotifier));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> clientNotifier;
  const MyApp({super.key, required this.clientNotifier});

  @override
  Widget build(BuildContext context) {
    final repository = PokemonRepository(clientNotifier.value);
    final favoritesService = FavoritesService();

    return GraphQLProvider(
      client: clientNotifier,
      child: CacheProvider(
        child: MultiProvider(
          providers: [
            RepositoryProvider<PokemonRepository>.value(value: repository),
            ChangeNotifierProvider<FavoritesService>.value(value: favoritesService),
          ],
          child: MultiBlocProvider(
            providers: [
              // BLoC para la lista de Pokémon
              BlocProvider(
                create: (_) => PokemonBloc(
                  repository: repository,
                  favoritesService: favoritesService,
                )..add(const LoadPokemonList()),
              ),
              // BLoC para favoritos
              BlocProvider(
                create: (_) => FavoritesBloc(
                  favoritesService: favoritesService,
                ),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ThemeMode.system,
              home: const SplashScreen(),
            ),
          ),
        ),
      ),
    );
  }
}

