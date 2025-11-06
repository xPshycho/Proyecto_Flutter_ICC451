# Pokédex App con Flutter

Este es el avance del proyecto flutter de la materia Desarrollo de Aplicaciones Móviles. Se trata de una aplicación Pokédex desarrollada en Flutter. La aplicación permite a los usuarios explorar, buscar, filtrar y ver detalles de Pokémon, utilizando la API de [PokeAPI](https://pokeapi.co/) a través de su endpoint de GraphQL.

## Funcionalidades Principales

La aplicación cuenta con una interfaz de usuario moderna y responsive, que incluye:

- **Pantalla de Inicio Dinámica**: Muestra una lista infinita de Pokémon que se carga a medida que el usuario se desplaza.
- **Búsqueda en Tiempo Real**: Permite buscar Pokémon por nombre.
- **Sistema de Filtrado Avanzado**: Los usuarios pueden filtrar la lista de Pokémon por:
  - **Tipo** (ej. Fuego, Agua, Planta).
  - **Región/Generación** (ej. Kanto, Johto).
  - **Categorías especiales** (Legendario, Mítico, Mega, etc.).
  - **Favoritos**: Muestra solo los Pokémon marcados como favoritos.
- **Ordenamiento**: La lista se puede ordenar por número de Pokédex, nombre o tipo, en orden ascendente o descendente.
- **Página de Detalles del Pokémon**: Una vista completa con información detallada que incluye:
  - **Estadísticas base** (PS, Ataque, Defensa, etc.).
  - **Habilidades**.
  - **Debilidades** calculadas según sus tipos.
  - **Cadena evolutiva**.
  - **Formas alternativas** (Megaevoluciones, formas regionales como Alola o Galar, etc.).
  - **Lista de movimientos** (Moveset).
- **Sistema de Favoritos**: Los usuarios pueden marcar y desmarcar Pokémon como favoritos. El estado se gestiona de forma centralizada y notifica a la UI de los cambios en tiempo real. La base para la persistencia con Hive está configurada, aunque el servicio actualmente los gestiona en memoria.
- **Diseño Responsivo**: La interfaz se adapta a diferentes tamaños de pantalla, desde teléfonos pequeños hasta tabletas.
- **Tema Claro y Oscuro**: La aplicación soporta ambos modos para una mejor experiencia de usuario.

## Implementación Técnica

### Arquitectura del Proyecto

El proyecto sigue una arquitectura limpia, separando las responsabilidades en las siguientes capas dentro del directorio `lib/`:

- `data`: Contiene los modelos de datos (`Pokemon`, `PokemonMove`), el repositorio (`PokemonRepository`) que gestiona la obtención de datos, y los servicios de comunicación con la API.
- `presentation`: Incluye todas las vistas (páginas) y widgets de la interfaz de usuario.
- `domain`: Almacena la lógica de negocio y modelos de dominio, como `PokemonFilters`.
- `core`: Contiene utilidades, constantes y lógica transversal (ej. `responsive_utils`, `filter_utils`).
- `theme`: Define los temas claro y oscuro de la aplicación.

### Gestión de Estado

La gestión de estado se realiza principalmente con el paquete `provider`.

- `ChangeNotifierProvider` y `ChangeNotifier`: Se utiliza para servicios como `FavoritesService`, que notifica a los widgets cuando la lista de favoritos cambia.
- `Provider`: Se usa para inyectar dependencias como `PokemonRepository` en el árbol de widgets, haciéndolo accesible a las páginas que lo necesitan.

### Comunicación con la API (GraphQL)

Una de las partes más importantes del proyecto es cómo consume los datos de la PokeAPI. En lugar de usar la API REST tradicional, se utiliza el endpoint de **GraphQL (`https://beta.pokeapi.co/graphql/v1beta`)**, lo que ofrece varias ventajas:

1.  **Consultas Precisas**: Con GraphQL, la aplicación solicita exactamente los datos que necesita. Esto evita tanto el "over-fetching" (recibir datos de más) como el "under-fetching" (necesitar hacer múltiples peticiones para obtener toda la información).
2.  **Menos Peticiones de Red**: Se pueden obtener datos complejos, como un Pokémon con sus evoluciones y formas, en una sola petición, en lugar de encadenar múltiples llamadas a endpoints REST.

La implementación de GraphQL se estructura de la siguiente manera:

- **Paquete `graphql_flutter`**: Es el núcleo de la comunicación. Proporciona el `GraphQLClient` y widgets como `GraphQLProvider` para conectar la UI con la API.

- **`GraphQLService` (`lib/data/graphql/graphql_client.dart`)**: Esta clase se encarga de inicializar el `GraphQLClient`. Configura el `HttpLink` (la URL del endpoint) y una caché en memoria (`InMemoryStore`) para mejorar el rendimiento.

- **`GraphQLQueryService` (`lib/data/services/graphql_query_service.dart`)**: Para mantener el código limpio y organizado, todas las consultas de GraphQL están definidas como constantes estáticas en esta clase. Esto evita tener strings de queries esparcidos por todo el código del repositorio. Hay queries específicas para diferentes necesidades:
  - `list`: Para la lista paginada de la pantalla principal.
  - `detail`: Para obtener todos los detalles de un Pokémon.
  - `evolutionChain`: Para la cadena evolutiva.
  - `formsByPokemonIds`: Para obtener las formas alternativas.
  - `searchByName`: Para la funcionalidad de búsqueda.

- **`PokemonRepository` (`lib/data/repositories/pokemon_repository.dart`)**: Actúa como una capa de abstracción entre la UI y la fuente de datos. La UI nunca interactúa directamente con el cliente de GraphQL. En su lugar, llama a métodos del repositorio como `fetchPokemons` o `fetchPokemonDetail`.
  - Este repositorio utiliza un `GraphQLExecutor` para realizar las peticiones.
  - Implementa un sistema de **caché en memoria** (`CacheService`) para evitar hacer peticiones repetidas para datos que no cambian frecuentemente, como los detalles de un Pokémon o su cadena evolutiva.

### Modelos de Datos

- **`Pokemon` (`lib/data/models/pokemon.dart`)**: Es el modelo principal. Representa la entidad base de un Pokémon.
- **`PokemonForm` (`lib/data/models/pokemon_form.dart`)**: Un aspecto clave del modelado es que las variantes (Mega, Alola, etc.) no se tratan como Pokémon separados. Son `PokemonForm`, que contienen datos específicos de esa variante (como el sprite), manteniendo al `Pokemon` base como la fuente de verdad para estadísticas y atributos comunes.
- **`PokemonMove` (`lib/data/models/pokemon_move.dart`)**: Representa un movimiento, con su nombre, tipo, poder, etc.

## Cómo Empezar

Para ejecutar este proyecto, necesitarás tener Flutter instalado.

1.  **Clona el repositorio:**
    ```bash
    git clone <URL_DEL_REPOSITORIO>
    cd pokedex
    ```

2.  **Instala las dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Ejecuta la aplicación:**
    ```bash
    flutter run
    ```

Puedes ejecutar la aplicación en un emulador de Android, un simulador de iOS o un dispositivo físico.
