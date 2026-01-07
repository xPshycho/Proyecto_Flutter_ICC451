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
import 'data/services/language_service.dart';
import 'presentation/bloc/pokemon/pokemon_bloc.dart';
import 'presentation/bloc/pokemon/pokemon_event.dart';
import 'presentation/bloc/favorites/favorites_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  // Inicializar el servicio de idioma
  final languageService = LanguageService();
  await languageService.initialize();

  final clientNotifier = GraphQLService.initClient();
  runApp(MyApp(
    clientNotifier: clientNotifier,
    languageService: languageService,
  ));
}

class MyApp extends StatefulWidget {
  final ValueNotifier<GraphQLClient> clientNotifier;
  final LanguageService languageService;

  const MyApp({
    super.key,
    required this.clientNotifier,
    required this.languageService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PokemonRepository _repository;
  late FavoritesService _favoritesService;

  @override
  void initState() {
    super.initState();
    _favoritesService = FavoritesService();
    _repository = PokemonRepository(
      widget.clientNotifier.value,
      languageId: widget.languageService.languageId,
    );

    // Escuchar cambios de idioma para recrear el repositorio
    widget.languageService.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    setState(() {
      _repository = PokemonRepository(
        widget.clientNotifier.value,
        languageId: widget.languageService.languageId,
      );
    });
  }

  @override
  void dispose() {
    widget.languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: widget.clientNotifier,
      child: CacheProvider(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<LanguageService>.value(
              value: widget.languageService,
            ),
            RepositoryProvider<PokemonRepository>.value(value: _repository),
            ChangeNotifierProvider<FavoritesService>.value(
              value: _favoritesService,
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              // BLoC para la lista de Pokémon
              BlocProvider(
                create: (_) => PokemonBloc(
                  repository: _repository,
                  favoritesService: _favoritesService,
                )..add(const LoadPokemonList()),
              ),
              // BLoC para favoritos
              BlocProvider(
                create: (_) => FavoritesBloc(
                  favoritesService: _favoritesService,
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
