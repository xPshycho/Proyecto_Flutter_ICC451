# Implementación del Filtro isDefault en la Pokédex

## Resumen
Se ha implementado el filtro `isDefault` para garantizar que en la página de Pokédex solo se muestren los 1025 Pokémon principales cuando no hay búsqueda activa ni filtros aplicados.

## Cambios Realizados

### 1. Modelo de Datos (`pokemon.dart`)
- **Agregado campo**: `final bool? isDefault`
- Este campo indica si un Pokémon es uno de los 1025 principales
- Se agregó al constructor y al método `copyWith`
- Se agregó al método `fromJson` para soportar deserialización

### 2. Queries GraphQL (`graphql_query_service.dart`)
Se agregó el campo `is_default` a todas las queries principales:
- `byIds`: Query básica por IDs
- `detailsByIds`: Query de detalles por IDs
- `list`: Query de lista paginada
- `listWithSpecies`: Query de lista con especies (ya tenía filtro `is_default: {_eq: true}`)
- `detail`: Query de detalle individual
- `searchByName`: Query de búsqueda por nombre
- `listByTypes`: Query con filtro por tipos
- `listByTypesAndGenerations`: Query con filtros combinados
- `listByGenerationIds`: Query por IDs de generación

### 3. Mapper Service (`pokemon_mapper_service.dart`)
- Modificado `mapBasic()`: Extrae y mapea el campo `is_default` desde la API
- Modificado `mapDetailed()`: Extrae y mapea el campo `is_default` desde la API

### 4. Repositorio (`pokemon_repository.dart`)
#### Lógica Implementada:
```dart
// Determinar si hay filtros activos
final hasActiveFilters = (types != null && types.isNotEmpty) ||
    (regions != null && regions.isNotEmpty) ||
    normalizedCategories.isNotEmpty;

// Flujo normal paginado
return _fetchPaginated(
  // ... otros parámetros
  onlyDefault: !hasActiveFilters, // Solo default cuando no hay filtros
);
```

#### Método `_fetchPaginated`:
- Nuevo parámetro: `bool onlyDefault = false`
- Cuando `onlyDefault = true`, filtra los resultados:
  ```dart
  if (onlyDefault) {
    result = result.where((pokemon) => pokemon.isDefault == true).toList();
  }
  ```

#### Query `listWithSpecies`:
- Ya incluye el filtro `where: {is_default: {_eq: true}}` en la query GraphQL
- Esta query se usa cuando NO hay filtros activos (tipos, regiones, categorías)

## Comportamiento Esperado

### Escenario 1: Sin búsqueda ni filtros
- ✅ Se aplica `isDefault = true`
- ✅ Solo se muestran los 1025 Pokémon principales
- Query usada: `listWithSpecies` (con filtro en GraphQL)

### Escenario 2: Con búsqueda activa
- ✅ NO se aplica filtro `isDefault`
- ✅ Se muestran todos los resultados que coincidan con la búsqueda
- Query usada: `searchByName` (sin filtro isDefault)

### Escenario 3: Con filtros aplicados (tipos, regiones, categorías)
- ✅ NO se aplica filtro `isDefault`
- ✅ Se muestran todos los Pokémon que cumplan con los filtros
- Queries usadas: `listByTypes`, `listByGenerationIds`, etc. (sin filtro isDefault adicional)

## Ventajas de la Implementación

1. **Eficiencia**: El filtro `isDefault` se aplica directamente en la query GraphQL cuando no hay otros filtros, reduciendo la cantidad de datos transferidos

2. **Flexibilidad**: Cuando hay filtros o búsqueda activa, se permite ver todos los Pokémon (incluyendo formas regionales, megas, etc.)

3. **Claridad**: La lógica es explícita y fácil de entender: 
   - Sin filtros → Solo los 1025 principales
   - Con filtros/búsqueda → Todos los que cumplan los criterios

4. **Caché optimizado**: La query `listWithSpecies` ya incluye el filtro, por lo que el caché solo almacena los Pokémon por defecto en ese caso

## Archivos Modificados

1. ✅ `lib/data/models/pokemon.dart`
2. ✅ `lib/data/services/graphql_query_service.dart`
3. ✅ `lib/data/services/pokemon_mapper_service.dart`
4. ✅ `lib/data/repositories/pokemon_repository.dart`

## Testing Recomendado

1. **Caso 1**: Abrir la Pokédex sin filtros
   - Verificar que solo se muestren Pokémon con ID ≤ 1025
   - Verificar que no aparezcan formas regionales como "pikachu-alola"

2. **Caso 2**: Usar el buscador
   - Buscar "pikachu"
   - Verificar que aparezcan todas las formas (pikachu, pikachu-alola, etc.)

3. **Caso 3**: Aplicar filtros
   - Filtrar por tipo "Eléctrico" y región "Kanto"
   - Verificar que se muestren todos los Pokémon que cumplan estos criterios

4. **Caso 4**: Limpiar filtros
   - Verificar que al limpiar vuelva a mostrar solo los 1025 principales

## Notas Técnicas

- El campo `isDefault` en la API PokeAPI v2 GraphQL indica si un Pokémon es la forma "por defecto" de una especie
- Los 1025 Pokémon principales tienen `is_default = true`
- Las formas alternativas (regionales, megas, gigantamax) tienen `is_default = false`
- El filtro se aplica **después** de obtener los resultados cuando se usa en memoria, o **durante** la query cuando está en el WHERE clause de GraphQL

