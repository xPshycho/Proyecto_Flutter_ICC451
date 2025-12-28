# Sistema de Internacionalización (i18n) para Poke Quiz

## Resumen de Implementación

Se ha implementado un sistema completo de internacionalización para el Poke Quiz que permite cambiar entre **Español** e **Inglés** de manera dinámica. El sistema utiliza los códigos de idioma oficiales de la PokéAPI para cargar datos traducidos.

## Códigos de Idioma de la PokéAPI

Según la documentación oficial de PokéAPI (https://pokeapi.co/docs/v2#languages), los códigos de idioma utilizados son:

- **Español:** `language_id = 7`
- **Inglés:** `language_id = 9`

Estos IDs se utilizan en las queries GraphQL para obtener nombres traducidos de:
- Nombres de Pokémon (pokemon_v2_pokemonspeciesnames)
- Habilidades (pokemon_v2_abilitynames)
- Descripciones (pokemon_v2_pokemonspeciesflavortexts)

## Archivos Creados

### 1. Servicio de Idiomas
**Ruta:** `lib/data/services/language_service.dart`

Este servicio gestiona el idioma actual de la aplicación:
- Persiste la selección usando SharedPreferences
- Proporciona el `languageId` correspondiente para las queries
- Extiende ChangeNotifier para reactividad con Provider
- Método `toggleLanguage()` para alternar entre idiomas

**Características:**
```dart
- currentLanguage: 'es' | 'en'
- languageId: 7 (español) | 9 (inglés)
- toggleLanguage(): Alterna entre idiomas
- initialize(): Carga el idioma guardado
```

### 2. Archivo de Traducciones
**Ruta:** `lib/core/constants/translations.dart`

Contiene todas las traducciones del Quiz en español e inglés:

**Secciones de Traducciones:**
- Página de inicio del Quiz (títulos, botones, etc.)
- Pantallas de juego (temporizador, puntos, etc.)
- Diálogos (game over, confirmaciones)
- Página de logros (nombres y descripciones)
- Nombres de logros traducidos

**Uso:**
```dart
final tr = AppTranslations.forLanguage('es');
Text(tr.play); // "JUGAR" en español, "PLAY" en inglés
```

## Modificaciones a Archivos Existentes

### 1. GraphQL Query Service
**Archivo:** `lib/data/services/graphql_query_service.dart`

**Cambios:**
- Las queries `byIds` y `detailsByIds` ahora reciben `languageId` como parámetro
- Se agregaron filtros `where: {language_id: {_eq: $languageId}}` en:
  - `pokemon_v2_pokemonspeciesnames` (nombres de Pokémon)
  - `pokemon_v2_abilitynames` (nombres de habilidades)

**Ejemplo de Query Actualizada:**
```graphql
query getByIds($ids: [Int!]) {
  pokemon_v2_pokemon(where: {id: {_in: $ids}}) {
    id
    name
    pokemon_v2_pokemonspecy { 
      pokemon_v2_pokemonspeciesnames(where: {language_id: {_eq: 7}}, limit: 1) {
        name
      }
    }
  }
}
```

### 2. Pokemon Mapper Service
**Archivo:** `lib/data/services/pokemon_mapper_service.dart`

**Cambios:**
- Método `mapBasic` ahora acepta parámetro opcional `translatedName`
- Nuevo método `_extractTranslatedName()` para extraer nombres traducidos
- Los nombres traducidos tienen prioridad sobre los nombres en inglés

### 3. Quiz Pokemon Loader Service
**Archivo:** `lib/data/services/quiz_pokemon_loader_service.dart`

**Cambios:**
- Constructor ahora recibe `languageId` como parámetro
- El servicio se inicializa con el idioma correcto desde el inicio
- Los Pokémon cargados ya vienen con nombres traducidos

### 4. Quiz BLoC
**Archivo:** `lib/presentation/bloc/quiz/quiz_bloc.dart`

**Cambios:**
- Agregado `LanguageService` como dependencia
- El `QuizPokemonLoaderService` se inicializa con `languageService.languageId`
- Los Pokémon se cargan automáticamente en el idioma seleccionado

### 5. Main.dart
**Archivo:** `lib/main.dart`

**Cambios:**
- Inicialización del `LanguageService` en el main
- Agregado como Provider global para toda la app
- Se inicializa antes de ejecutar la aplicación

**Código:**
```dart
final languageService = LanguageService();
await languageService.initialize();

// ...

ChangeNotifierProvider<LanguageService>.value(value: languageService),
```

### 6. Quiz Home Page
**Archivo:** `lib/presentation/pages/quiz_home_page.dart`

**Cambios Principales:**
- Uso de `Consumer<LanguageService>` para reactividad
- Botón de cambio de idioma (ícono de globo) en la barra superior
- Todas las cadenas de texto usan traducciones
- Modal de nombre de jugador con textos traducidos
- Los modos de juego se actualizan al cambiar de idioma

**Botón de Idioma:**
```dart
IconButton(
  onPressed: () async {
    await languageService.toggleLanguage();
    _updateSelectedMode(languageService.currentLanguage);
  },
  icon: const Icon(Icons.language),
  tooltip: languageService.currentLanguage == 'es' ? 'English' : 'Español',
)
```

## Flujo de Funcionamiento

### 1. Inicialización
```
main() 
  → LanguageService.initialize() 
  → Carga idioma guardado (default: 'es')
  → Provider disponible globalmente
```

### 2. Cambio de Idioma
```
Usuario presiona botón de idioma
  → languageService.toggleLanguage()
  → Guarda en SharedPreferences
  → notifyListeners()
  → Consumer se reconstruye
  → UI actualiza con nuevas traducciones
```

### 3. Carga de Pokémon
```
InitializeQuiz
  → QuizBloc recibe LanguageService
  → Crea QuizPokemonLoaderService(repository, languageId)
  → Queries GraphQL usan el languageId correcto
  → Pokémon cargados con nombres traducidos
```

## Componentes del Quiz (Pendientes de Actualizar)

Los siguientes componentes aún necesitan integrar las traducciones:

1. **quiz_display_area.dart** - Textos de "Escucha el sonido", etc.
2. **quiz_stats_bar.dart** - Labels de "PUNTOS", "racha"
3. **quiz_game_over_dialog.dart** - Todos los textos del diálogo final
4. **quiz_answer_options.dart** - (No requiere cambios, solo muestra nombres)
5. **achievements_page.dart** - Títulos y descripciones de logros

**Patrón para Actualizar:**
```dart
// Obtener traducciones
final languageService = context.read<LanguageService>();
final tr = AppTranslations.forLanguage(languageService.currentLanguage);

// Usar en UI
Text(tr.points)  // "PUNTOS" o "POINTS"
```

## Ejemplo de Integración en un Widget

```dart
import 'package:provider/provider.dart';
import '../../core/constants/translations.dart';
import '../../data/services/language_service.dart';

class MiWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        final tr = AppTranslations.forLanguage(languageService.currentLanguage);
        
        return Column(
          children: [
            Text(tr.quizTitle),
            ElevatedButton(
              onPressed: () {},
              child: Text(tr.play),
            ),
          ],
        );
      },
    );
  }
}
```

## Testing

Para probar el sistema:

1. **Ejecutar la aplicación**
2. **Navegar al Quiz Home**
3. **Presionar el botón de idioma (globo terráqueo)** en la esquina superior derecha
4. **Verificar que:**
   - Los textos de la UI cambian inmediatamente
   - Los nombres de los modos se traducen
   - Al iniciar una partida, los nombres de Pokémon están en el idioma seleccionado
   - El idioma se persiste entre sesiones

## Próximos Pasos

1. **Completar la integración** en los componentes restantes del quiz
2. **Agregar más idiomas** si se desea (francés, alemán, japonés, etc.)
3. **Crear tests unitarios** para el LanguageService
4. **Documentar logros** con traducciones completas

## Ventajas de esta Implementación

✅ **Reactivo:** Usa Provider para actualización automática  
✅ **Persistente:** Guarda la preferencia del usuario  
✅ **Escalable:** Fácil agregar más idiomas  
✅ **Tipado:** Helper class para acceso seguro a traducciones  
✅ **Compatible con PokeAPI:** Usa los IDs oficiales de idiomas  
✅ **Sin dependencias adicionales:** Solo usa Provider (ya incluido)  

## Notas Técnicas

- Los nombres de Pokémon se cargan directamente desde la API en el idioma seleccionado
- El sistema funciona sin necesidad de reiniciar la aplicación
- SharedPreferences asegura que la preferencia persista
- El patrón Consumer evita rebuild innecesarios del árbol de widgets
- Los códigos de idioma (7 y 9) son los estándares de PokéAPI v2

## Recursos Adicionales

- [PokéAPI Language Documentation](https://pokeapi.co/docs/v2#languages)
- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [Provider Package](https://pub.dev/packages/provider)

