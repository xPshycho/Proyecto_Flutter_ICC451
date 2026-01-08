# Pokédex Flutter + GraphQL

[![Flutter](https://img.shields.io/badge/Flutter-stable-0175C2?logo=flutter)](https://flutter.dev)
[![GraphQL](https://img.shields.io/badge/GraphQL-API-E10098?logo=graphql)](https://graphql.org)

Resumen
-------
Aplicación móvil multiplataforma desarrollada con Flutter y GraphQL que actúa como una Pokédex moderna. Incluye UI/UX avanzado, consumo de API GraphQL, persistencia local, accesibilidad y características gamificadas.

Tabla de contenidos
-------------------
- [Características principales](#características-principales)
- [Tecnologías](#tecnologías)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Arquitectura](#arquitectura)
- [Uso de GraphQL](#uso-de-graphql)
- [Gestión de estado](#gestión-de-estado)
- [Pruebas](#pruebas)
- [Contribuir](#contribuir)
- [Licencia](#licencia)
- [Contacto](#contacto)

Características principales
--------------------------
- Lista de Pokémon con búsqueda, filtro y paginación.
- Pantalla de detalle con estadísticas, evoluciones, movimientos, variantes y type matchups.
- Favoritos persistentes y modo offline parcial con caché local.
- Animaciones y microinteracciones (Hero, Lottie, transiciones).
- Modo trivia gamificado con ranking local y logros.
- Mapa interactivo por regiones usando `flutter_map`.
- Accesibilidad e internacionalización (ES / EN).

Tecnologías
-----------
- Flutter (Dart)
- GraphQL (graphql_flutter)
- BLoC + Riverpod (gestión de estado)
- Hive / SharedPreferences (persistencia local)
- fl_chart, Lottie, flutter_svg, flutter_map, share_plus, screenshot

Requisitos
----------
- Flutter >= 3.9.2
- Dart >= 3.9.2
- Android API 21+ / iOS 11.0+
- Android Studio / Xcode (opcional)

Instalación
----------
1. Clonar:
   git clone https://github.com/xPshycho/Proyecto_Flutter_ICC451.git
2. Entrar en el proyecto:
   cd Proyecto_Flutter_ICC451
3. Instalar dependencias:
   flutter pub get
4. Generar localización (si aplica):
   flutter gen-l10n

Uso
---
- Ejecutar en emulador/dispositivo:
  flutter run
- Build release:
  flutter build apk --release
  flutter build appbundle --release
  flutter build ios --release

Arquitectura
------------
Patrón: Clean Architecture (data / domain / presentation) con BLoC + Riverpod.

Estructura recomendada:
- lib/
  - core/ (constantes, errores, utilidades)
  - data/ (datasources, models, repositories)
  - domain/ (entidades, casos de uso, contratos)
  - presentation/ (pages, widgets, bloc, theme)
  - main.dart

Flujo: UI -> BLoC -> Repositorios -> Data Sources (GraphQL / Local) -> API / DB

Uso de GraphQL
--------------
- Endpoint principal: https://graphql.pokeapi.co/v1beta2/
- Paginación basada en cursor e infinite scroll.
- Consultas optimizadas para reducir payload.
- Caché gestionado por el cliente GraphQL y sincronización con almacenamiento local para offline.
- Manejo de errores: timeouts, retries con backoff, fallback a datos locales.

Ejemplo de query optimizada:
```graphql
query GetPokemonList($limit: Int!, $offset: Int!) {
  pokemon_v2_pokemon(limit: $limit, offset: $offset) {
    id
    name
    pokemon_v2_pokemontypes { pokemon_v2_type { name } }
    pokemon_v2_pokemonsprites { sprites }
  }
}
```

Gestión de estado
-----------------
- BLoC para la lógica de negocio y eventos/estados.
- Riverpod para inyección de dependencias y providers compartidos.
- Principales BLoC: PokemonListBloc, PokemonDetailBloc, FavoritesBloc, TriviaBloc.

Pruebas
-------
- Ejecutar tests:
  flutter test
- Añadir tests unitarios y de widgets para BLoCs y componentes críticos.
- Integración con CI (GitHub Actions) para ejecutar tests en cada PR.

Contribuir
----------
1. Fork del repositorio y crear una rama con prefijo feature/ o fix/.
2. Mantener commits claros; incluir tests cuando corresponda.
3. Abrir PR describiendo los cambios y pruebas realizadas.

Contacto
-------
Para dudas o contribuciones abre un issue en el repositorio o contacta al mantenedor.
