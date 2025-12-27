# Mejoras en el Sistema de Filtros de la Pokédex

## Fecha de Implementación
2025-12-27

## Resumen de Cambios

Se han implementado mejoras significativas en el sistema de filtros de la Pokédex para proporcionar una experiencia más precisa y controlada al usuario.

## 1. Filtro de Tipo - Máximo 2 Tipos con Búsqueda de Ambos Tipos

### Comportamiento Implementado:

#### 1 Tipo Seleccionado:
- **Búsqueda**: Todos los Pokémon que tengan ese tipo
- **Ejemplo**: Si se selecciona "Fuego", se mostrarán todos los Pokémon que tengan tipo Fuego (Charizard, Charmander, Flareon, Houndoom, etc.)
- **Incluye**: Pokémon de tipo puro (solo Fuego) y tipo dual (Fuego/Volador, Fuego/Lucha, etc.)

#### 2 Tipos Seleccionados:
- **Búsqueda**: Pokémon que tengan **AMBOS tipos seleccionados**
- **Ejemplo**: Si se seleccionan "Fuego" y "Volador", se mostrarán Pokémon que tengan ambos tipos como Charizard, Moltres, Talonflame, Ho-Oh
- **Nota**: No importa si tienen tipos adicionales, solo deben tener ambos tipos seleccionados
- **Incluye**: Pokémon con exactamente esos 2 tipos (Fuego/Volador) o más tipos que incluyan ambos

#### Validación:
- Límite máximo de 2 tipos seleccionados
- Mensaje de advertencia si se intenta seleccionar más de 2 tipos
- SnackBar con mensaje: "Solo puedes seleccionar máximo 2 tipos"

### Archivos Modificados:

#### `lib/presentation/widgets/FilterBoxes/type_filter_box.dart`
```dart
static const int maxTypeSelection = 2;

void _toggleOption(String option) {
  final List<String> newSelection = List.from(widget.selectedOptions);
  if (newSelection.contains(option)) {
    newSelection.remove(option);
  } else {
    if (newSelection.length < maxTypeSelection) {
      newSelection.add(option);
    } else {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(...);
      return;
    }
  }
  widget.onSelectionChanged(newSelection);
}
```

#### `lib/data/services/data_services.dart`
```dart
static List<T> filterByTypes<T>(
  List<T> items,
  List<String> types,
  List<String> Function(T) typeExtractor,
) {
  if (types.isEmpty) return items;

  final lowerTypes = types.map((t) => t.toLowerCase()).toSet();

  // 1 tipo: buscar todos los que lo tengan
  if (lowerTypes.length == 1) {
    return items.where((item) {
      final itemTypes = typeExtractor(item).map((t) => t.toLowerCase()).toSet();
      return itemTypes.contains(lowerTypes.first);
    }).toList();
  }

  // 2 tipos: buscar los que tengan AMBOS tipos
  if (lowerTypes.length == 2) {
    return items.where((item) {
      final itemTypes = typeExtractor(item).map((t) => t.toLowerCase()).toSet();
      // Verificar que tenga ambos tipos seleccionados
      return itemTypes.containsAll(lowerTypes);
    }).toList();
  }

  return items;
}
```

## 2. Filtro de Región - Selección Única

### Comportamiento Implementado:
- Solo se puede seleccionar **una región a la vez**
- Seleccionar una nueva región reemplaza automáticamente la anterior
- Clic en la región seleccionada la deselecciona
- Se muestra el nombre de la región seleccionada cuando el filtro está colapsado

### Regiones Disponibles:
- Kanto
- Johto
- Hoenn
- Sinnoh
- Teselia
- Kalos
- Alola
- Galar
- Paldea

## 3. Filtro de Categoría - Selección Única

### Comportamiento Implementado:
- Solo se puede seleccionar **una categoría a la vez**
- Seleccionar una nueva categoría reemplaza automáticamente la anterior
- Clic en la categoría seleccionada la deselecciona
- Se muestra el nombre de la categoría seleccionada cuando el filtro está colapsado

### Categorías Disponibles:
- Starter
- Mega
- Gigantamax
- Legendario
- Mítico

## 4. Nuevo Componente: SingleSelectFilterBox

Se creó un nuevo componente reutilizable para filtros de selección única:

### Archivo: `lib/presentation/widgets/FilterBoxes/single_select_filter_box.dart`

**Características:**
- ✅ Selección única (radio button behavior)
- ✅ Interfaz expandible/colapsable
- ✅ Botón "Clear" para deseleccionar
- ✅ Muestra la opción seleccionada cuando está colapsado
- ✅ Animaciones suaves
- ✅ Estilo consistente con los demás filtros

**API:**
```dart
SingleSelectFilterBox(
  title: 'Título del Filtro',
  options: ['Opción 1', 'Opción 2', 'Opción 3'],
  selectedOption: _opcionSeleccionada,
  onSelectionChanged: (selected) {
    setState(() => _opcionSeleccionada = selected);
  },
)
```

## 5. Actualización del BottomFilterMenu

### Cambios en `lib/presentation/widgets/bottom_filter_menu.dart`:

**Estado del Componente:**
```dart
bool _favoritos = false;
bool _noFavoritos = false;
String? _categoriaSeleccionada;        // Ahora es String? (único)
List<String> _tiposSeleccionados = []; // Máximo 2
String? _regionSeleccionada;           // Ahora es String? (único)
```

**Implementación de Filtros:**
- Categoría: Usa `SingleSelectFilterBox`
- Tipo: Usa `TypeFilterBox` con límite de 2
- Región: Usa `SingleSelectFilterBox`

## Ventajas de la Implementación

### 1. Experiencia de Usuario Mejorada
- ✅ Más intuitivo: un filtro = una opción
- ✅ Búsquedas más precisas con combinaciones de tipos
- ✅ Menos confusión al aplicar múltiples filtros

### 2. Consistencia
- ✅ Comportamiento predecible
- ✅ Interfaz uniforme entre filtros
- ✅ Validaciones claras

### 3. Performance
- ✅ Filtros más eficientes (menos combinaciones)
- ✅ Resultados más rápidos
- ✅ Menos carga en el servidor

### 4. Mantenibilidad
- ✅ Componente reutilizable (`SingleSelectFilterBox`)
- ✅ Código más limpio y organizado
- ✅ Fácil de extender

## Ejemplos de Uso

### Caso 1: Buscar Pokémon Fuego de Kanto
**Filtros:**
- Tipo: Fuego ✓
- Región: Kanto ✓

**Resultado:** Charizard, Charmander, Charmeleon, Arcanine, Ninetales, Rapidash, Flareon, Moltres

### Caso 2: Buscar Pokémon que tengan Agua Y Volador
**Filtros:**
- Tipo: Agua ✓, Volador ✓

**Resultado:** Gyarados, Mantine, Pelipper, Ducklett, Swanna, Cramorant (todos los que tengan AMBOS tipos)

### Caso 3: Buscar Legendarios de Sinnoh
**Filtros:**
- Categoría: Legendario ✓
- Región: Sinnoh ✓

**Resultado:** Dialga, Palkia, Giratina, Uxie, Mesprit, Azelf, Heatran, Regigigas, Cresselia

### Caso 4: Buscar Starters de tipo Planta
**Filtros:**
- Categoría: Starter ✓
- Tipo: Planta ✓

**Resultado:** Bulbasaur, Ivysaur, Venusaur, Chikorita, Bayleef, Meganium, Treecko, Grovyle, Sceptile, etc.

### Caso 5: Buscar Pokémon Dragón Y Volador
**Filtros:**
- Tipo: Dragón ✓, Volador ✓

**Resultado:** Dragonite, Altaria, Salamence, Rayquaza, Noivern, etc. (todos los que tengan ambos tipos)

## Testing Recomendado

### 1. Filtro de Tipo
- [ ] Seleccionar 1 tipo y verificar resultados
- [ ] Seleccionar 2 tipos y verificar que se muestren Pokémon con ambos tipos
- [ ] Intentar seleccionar 3 tipos (debe mostrar error)
- [ ] Deseleccionar tipos individualmente

### 2. Filtro de Región
- [ ] Seleccionar una región
- [ ] Cambiar a otra región (debe reemplazar)
- [ ] Deseleccionar región

### 3. Filtro de Categoría
- [ ] Seleccionar una categoría
- [ ] Cambiar a otra categoría (debe reemplazar)
- [ ] Deseleccionar categoría

### 4. Combinaciones
- [ ] Tipo + Región
- [ ] Tipo + Categoría
- [ ] Región + Categoría
- [ ] Todos los filtros juntos
- [ ] Con búsqueda activa

## Notas Técnicas

### Conversión de Tipos
Los tipos se convierten automáticamente de español a inglés para la API:
```dart
PokemonConstants.toApiTypes(['Fuego', 'Agua'])
// Resultado: ['fire', 'water']
```

### Filtrado en Memoria vs GraphQL
- **Con tipos**: Se aplica filtrado en memoria con `PokemonFilterService.filterByTypes()`
- **Con región**: Se usa la query GraphQL `listByGenerationIds`
- **Con categoría**: Se aplica filtrado en memoria con caché completo

## Archivos Creados/Modificados

### Creados:
1. ✅ `lib/presentation/widgets/FilterBoxes/single_select_filter_box.dart`

### Modificados:
1. ✅ `lib/presentation/widgets/FilterBoxes/type_filter_box.dart`
2. ✅ `lib/presentation/widgets/bottom_filter_menu.dart`
3. ✅ `lib/data/services/data_services.dart`

## Compatibilidad

- ✅ Compatible con el sistema de favoritos existente
- ✅ Compatible con la búsqueda por nombre
- ✅ Compatible con el ordenamiento
- ✅ Compatible con el filtro `isDefault` implementado anteriormente

## Conclusión

Las mejoras implementadas proporcionan un sistema de filtros más robusto, intuitivo y eficiente. Los usuarios ahora pueden realizar búsquedas más precisas con una interfaz más clara y un comportamiento predecible.
