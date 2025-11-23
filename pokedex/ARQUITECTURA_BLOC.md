# Arquitectura BLoC - Pokédex

## 📋 Resumen

Este proyecto ha sido migrado a **BLoC (Business Logic Component)** como patrón de gestión de estado, reemplazando el uso anterior de Provider y setState. La arquitectura sigue principios de **Clean Architecture** con separación clara de responsabilidades.

## 🏗️ Estructura del Proyecto

```
lib/
├── core/                       # Constantes y utilidades compartidas
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── pokemon_constants.dart
│   └── utils/
│       ├── filter_utils.dart
│       └── responsive_utils.dart
│
├── data/                       # Capa de datos
│   ├── models/                 # Modelos de datos
│   │   ├── pokemon.dart
│   │   ├── pokemon_form.dart
│   │   └── pokemon_move.dart
│   ├── repositories/           # Repositorios
│   │   └── pokemon_repository.dart
│   ├── services/               # Servicios de datos
│   │   └── data_services.dart
│   ├── graphql/                # Cliente GraphQL
│   │   └── graphql_client.dart
│   └── favorites_service.dart  # Servicio de favoritos
│
├── domain/                     # Capa de dominio
│   └── models/
│       └── pokemon_filters.dart
│
└── presentation/               # Capa de presentación
    ├── bloc/                   # BLoCs (Lógica de negocio)
    │   ├── pokemon/           
    │   │   ├── pokemon_bloc.dart
    │   │   ├── pokemon_event.dart
    │   │   └── pokemon_state.dart
    │   ├── pokemon_detail/
    │   │   ├── pokemon_detail_bloc.dart
    │   │   ├── pokemon_detail_event.dart
    │   │   └── pokemon_detail_state.dart
    │   └── favorites/
    │       ├── favorites_bloc.dart
    │       ├── favorites_event.dart
    │       └── favorites_state.dart
    │
    ├── pages/                  # Páginas/Screens
    │   ├── home_page.dart
    │   └── pokemon_detail_page.dart
    │
    └── widgets/                # Widgets reutilizables
        ├── common/             # Widgets comunes
        ├── detail_components/  # Componentes de detalle
        └── FilterBoxes/        # Componentes de filtros
```

## 🔄 Flujo de Datos con BLoC

### 1. **PokemonBloc** - Lista de Pokémon
Gestiona la lista principal de Pokémon con paginación, búsqueda y filtros.

**Eventos:**
- `LoadPokemonList` - Carga inicial/recarga
- `LoadMorePokemons` - Paginación
- `SearchPokemon` - Búsqueda por nombre
- `ApplyFilters` - Aplicar filtros (tipos, regiones, categorías)
- `ApplySort` - Ordenamiento
- `ClearFilters` - Limpiar filtros
- `RefreshPokemonList` - Refrescar lista

**Estados:**
- `PokemonInitial` - Estado inicial
- `PokemonLoading` - Cargando
- `PokemonLoadingMore` - Cargando más (paginación)
- `PokemonLoaded` - Datos cargados exitosamente
- `PokemonError` - Error

**Ejemplo de uso:**
```dart
// Disparar evento
context.read<PokemonBloc>().add(const LoadPokemonList());

// Escuchar estado
BlocBuilder<PokemonBloc, PokemonState>(
  builder: (context, state) {
    if (state is PokemonLoaded) {
      return ListView.builder(...);
    }
    return CircularProgressIndicator();
  },
)
```

### 2. **PokemonDetailBloc** - Detalle de Pokémon
Gestiona la carga de detalles de un Pokémon individual.

**Eventos:**
- `LoadPokemonDetail` - Cargar detalles
- `NavigateToEvolution` - Navegar a evolución
- `RetryLoadPokemonDetail` - Reintentar carga

**Estados:**
- `PokemonDetailInitial`
- `PokemonDetailLoading`
- `PokemonDetailLoaded`
- `PokemonDetailError`

### 3. **FavoritesBloc** - Gestión de Favoritos
Gestiona los Pokémon marcados como favoritos.

**Eventos:**
- `LoadFavorites` - Cargar lista de favoritos
- `ToggleFavorite` - Alternar estado de favorito

**Estados:**
- `FavoritesInitial`
- `FavoritesLoaded` - Contiene lista de IDs favoritos

## 🎯 Ventajas de la Implementación

### 1. **Separación de Responsabilidades**
- UI: Solo se encarga de renderizar
- BLoC: Maneja toda la lógica de negocio
- Repository: Gestiona el acceso a datos

### 2. **Testabilidad**
Los BLoCs son fácilmente testeables sin necesidad de widgets:
```dart
test('PokemonBloc emite PokemonLoaded al cargar Pokémon', () async {
  final bloc = PokemonBloc(repository: mockRepository);
  
  bloc.add(const LoadPokemonList());
  
  await expectLater(
    bloc.stream,
    emitsInOrder([
      isA<PokemonLoading>(),
      isA<PokemonLoaded>(),
    ]),
  );
});
```

### 3. **Estado Predecible**
Cada cambio de estado es explícito y rastreable:
- Los eventos son la única forma de cambiar el estado
- Los estados son inmutables (usando Equatable)
- Fácil debugging con BlocObserver

### 4. **Manejo de Concurrencia**
Uso de `bloc_concurrency` para manejar eventos concurrentes:
```dart
on<LoadPokemonList>(_onLoadPokemonList, transformer: restartable());
```

### 5. **Caché y Optimización**
- Mantiene estado entre navegaciones
- No recarga datos innecesariamente
- Paginación eficiente

## 📱 Widgets BLoC Principales

### BlocBuilder
Reconstruye la UI cuando cambia el estado:
```dart
BlocBuilder<PokemonBloc, PokemonState>(
  builder: (context, state) {
    // Renderiza según el estado
  },
)
```

### BlocListener
Ejecuta acciones en respuesta a cambios de estado (sin reconstruir):
```dart
BlocListener<PokemonBloc, PokemonState>(
  listener: (context, state) {
    if (state is PokemonError) {
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  },
  child: ...,
)
```

### BlocConsumer
Combina BlocBuilder y BlocListener:
```dart
BlocConsumer<PokemonBloc, PokemonState>(
  listener: (context, state) { /* side effects */ },
  builder: (context, state) { /* UI */ },
)
```

### BlocProvider
Provee un BLoC a su árbol de widgets:
```dart
BlocProvider(
  create: (_) => PokemonBloc(repository: repository),
  child: HomePage(),
)
```

## 🔧 Configuración en main.dart

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => PokemonBloc(
        repository: repository,
        favoritesService: favoritesService,
      )..add(const LoadPokemonList()),
    ),
    BlocProvider(
      create: (_) => FavoritesBloc(
        favoritesService: favoritesService,
      ),
    ),
  ],
  child: MaterialApp(...),
)
```

## 🧪 Testing

Para testear los BLoCs:

```dart
// pokemon_bloc_test.dart
void main() {
  late PokemonBloc pokemonBloc;
  late MockPokemonRepository mockRepository;

  setUp(() {
    mockRepository = MockPokemonRepository();
    pokemonBloc = PokemonBloc(
      repository: mockRepository,
      favoritesService: MockFavoritesService(),
    );
  });

  tearDown(() {
    pokemonBloc.close();
  });

  test('estado inicial es PokemonInitial', () {
    expect(pokemonBloc.state, isA<PokemonInitial>());
  });

  blocTest<PokemonBloc, PokemonState>(
    'emite [PokemonLoading, PokemonLoaded] cuando LoadPokemonList es exitoso',
    build: () => pokemonBloc,
    act: (bloc) => bloc.add(const LoadPokemonList()),
    expect: () => [
      isA<PokemonLoading>(),
      isA<PokemonLoaded>(),
    ],
  );
}
```

## 📚 Dependencias

```yaml
dependencies:
  flutter_bloc: ^8.1.6      # BLoC pattern
  equatable: ^2.0.5         # Comparación de estados
  bloc_concurrency: ^0.2.5  # Manejo de concurrencia
```

## 🚀 Próximos Pasos

1. **Agregar persistencia**: Usar Hydrated BLoC para persistir estado
2. **Implementar BlocObserver**: Para logging y debugging
3. **Crear más tests**: Ampliar cobertura de tests unitarios
4. **Optimizar renderizado**: Usar `buildWhen` en BlocBuilder
5. **Implementar retry logic**: Mejorar manejo de errores

## 📖 Recursos

- [flutter_bloc Documentation](https://bloclibrary.dev/)
- [BLoC Architecture](https://bloclibrary.dev/#/architecture)
- [Testing BLoCs](https://bloclibrary.dev/#/testing)
- [BLoC Best Practices](https://bloclibrary.dev/#/bestpractices)

---

**Fecha de migración:** Noviembre 2024  
**Versión:** 1.0.0

