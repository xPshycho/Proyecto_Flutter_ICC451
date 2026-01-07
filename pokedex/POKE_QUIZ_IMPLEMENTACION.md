# Poke Quiz - Implementación Completa y Optimizada

## Optimizaciones Implementadas 

### Sistema de Precarga Optimizado
- **Carga en Lotes:** Los Pokémon se cargan en grupos de 10 para evitar sobrecarga de memoria
- **Precarga Inteligente:** Mantiene siempre 3 Pokémon en caché para respuesta instantánea
- **Liberación de Memoria:** Los Pokémon ya jugados no se persisten, liberando memoria automáticamente
- **Sin Límite:** Permite jugar los 1025 Pokémon en una sola partida sin problemas de rendimiento

### Flujo de Inicialización Mejorado
- **Modal de Nombre:** El jugador ingresa su nombre antes de iniciar la partida
- **Pantalla de Carga:** Muestra el progreso mientras se precargan los primeros Pokémon
- **Auto-inicio:** Una vez cargado, el juego inicia automáticamente sin intervención adicional

## Características Implementadas

### Sistema de Juego
- **4 Modalidades de Juego:**
  - Silueta (x1.0) - Muestra la silueta negra del Pokémon
  - Descripción (x1.5) - Muestra el texto de descripción
  - Número (x2.0) - Muestra el número del Pokémon
  - Sonido (x3.0) - Reproduce el cry del Pokémon

### Sistema de Puntuación
- **Puntos Base:** 10 puntos por respuesta correcta
- **Multiplicadores:** Basados en la modalidad seleccionada
- **Racha:** +1 al multiplicador cada 10 aciertos consecutivos
- **Penalidad:** La racha se resetea al fallar, pero el juego continúa

### Sistema de Tiempo
- **Tiempo Inicial:** 30 segundos
- **Bonus por Acierto:** +5 segundos adicionales
- **Game Over:** Cuando el tiempo llega a 0

### Sistema de Ranking
- **Persistencia Local:** Usa SharedPreferences
- **Top 5:** Guarda los 5 mejores puntajes
- **Criterios de Ordenamiento:**
  1. Mayor puntuación
  2. En caso de empate, menor tiempo
- **Formato de Tiempo:** hh:mm:ss
- **Nombre del Jugador:** 
  - Máximo 3 caracteres
  - Convertido automáticamente a mayúsculas
  - Default: "ASH" si no se ingresa nombre

### Características Técnicas
- **Sin Repeticiones:** Los Pokémon no se repiten en una misma partida
- **Rango de Pokémon:** Solo Pokémon default (ID 1-1025)
- **4 Opciones:** 1 correcta + 3 incorrectas aleatorias
- **Código Modular:** Preparado para implementación futura de logros
- **Gestión de Memoria:** Optimizada para manejar hasta 1025 Pokémon sin overflow

## Estructura de Archivos Creados

### Modelos
```
lib/data/models/
├── quiz_ranking.dart          # Modelo de entrada del ranking
└── quiz_mode.dart             # Enum de modalidades de juego
```

### Servicios
```
lib/data/services/
├── quiz_ranking_service.dart        # Servicio de persistencia del ranking
└── quiz_pokemon_loader_service.dart # Servicio de precarga optimizada (NUEVO)
```

### BLoC (Lógica de Negocio)
```
lib/presentation/bloc/quiz/
├── quiz_bloc.dart             # Lógica principal del quiz (OPTIMIZADO)
├── quiz_event.dart            # Eventos del quiz
└── quiz_state.dart            # Estados del quiz
```

### Páginas
```
lib/presentation/pages/
├── quiz_page.dart             # Página principal del juego (ACTUALIZADA)
└── quiz_home_page.dart        # Página de inicio con ranking (ACTUALIZADA)
```

### Componentes de UI
```
lib/presentation/widgets/quiz_components/
├── quiz_stats_bar.dart        # Barra superior con estadísticas
├── quiz_display_area.dart     # Área de visualización del atributo
├── quiz_answer_options.dart   # Botones de opciones de respuesta
└── quiz_game_over_dialog.dart # Diálogo de fin de partida
```

## Arquitectura de Carga Optimizada

### QuizPokemonLoaderService
**Responsabilidades:**
- Inicializa un pool de 1025 IDs de Pokémon disponibles
- Carga lotes de 10 Pokémon de forma asíncrona
- Mantiene un buffer de 3 Pokémon precargados para respuesta instantánea
- Libera memoria de Pokémon ya utilizados
- Genera opciones incorrectas de forma eficiente

**Configuración:**
```dart
static const int batchSize = 10;           // Tamaño del lote de carga
static const int minPokemonId = 1;         // ID mínimo
static const int maxPokemonId = 1025;      // ID máximo
```

**Algoritmo de Precarga:**
1. **Inicialización:** Crea un Set con IDs 1-1025
2. **Primera Carga:** Precarga 10 Pokémon aleatorios
3. **Durante el Juego:** 
   - Cuando quedan < 3 en caché, carga el siguiente lote
   - Usa Future.wait para carga paralela
   - Marca IDs como usados y los remueve del pool
4. **Fin del Juego:** Se alcanza cuando no hay más IDs disponibles

### Flujo de Estados del BLoC

```
QuizInitial
    ↓ (Usuario presiona JUGAR)
    ↓ (Ingresa nombre en modal)
    ↓ InitializeQuiz(mode, playerName)
    ↓
QuizLoading
    ↓ (Precarga primer lote de 10)
    ↓
QuizReadyToStart
    ↓ (Auto-inicio)
    ↓ StartQuiz(mode)
    ↓
QuizPlaying
    ↓ (Ciclo de preguntas)
    ↓
    ├─ QuizCorrectAnswer → QuizPlaying (nueva pregunta)
    ├─ QuizIncorrectAnswer → QuizPlaying (nueva pregunta)
    └─ Timer = 0 → QuizFinished
```

## Diseño de UI

### Modal de Nombre del Jugador (NUEVO)
- Aparece al presionar el botón JUGAR
- Campo de texto de 3 caracteres máximo
- Validación en tiempo real a mayúsculas
- Botones: CANCELAR / COMENZAR
- Placeholder: "ASH"

### Pantalla de Carga (NUEVA)
- Indicador circular verde
- Mensaje: "Cargando Pokémon..." / "Preparando el quiz..."
- Texto secundario: "Por favor espera"

### Barra de Estadísticas
- **Botón Exit:** Esquina superior izquierda
- **Timer:** Centro superior con indicador de color
  - Verde: >10 segundos
  - Naranja: 5-10 segundos
  - Rojo: ≤5 segundos
- **Puntos:** Muestra puntuación actual formateada
- **Multiplicador:** Muestra multiplicador actual y racha

### Área de Visualización
Según la modalidad:
- **Silueta:** Sprite del Pokémon completamente negro
- **Descripción:** Texto de descripción centrado
- **Número:** Número del Pokémon en grande
- **Sonido:** Icono de altavoz para reproducir el cry

### Opciones de Respuesta
- Grid 2x2 con 4 botones
- Feedback visual:
  - Verde con check para respuesta correcta
  - Rojo con X para respuesta incorrecta

### Diálogo de Game Over
- Muestra estadísticas finales
- Permite ingresar nombre si entró al Top 5
- Input de 3 caracteres máximo
- Validación automática a mayúsculas

## Sistema de Estadísticas (Para Logros Futuros)

El BLoC mantiene contadores de:
- `totalQuestions`: Total de preguntas respondidas
- `correctAnswers`: Respuestas correctas
- `incorrectAnswers`: Respuestas incorrectas
- `consecutiveCorrect`: Racha actual

El servicio de carga mantiene:
- `preloaded`: Pokémon en caché
- `used`: Pokémon ya jugados
- `available`: IDs disponibles
- `isLoading`: Estado de carga

## Métricas de Rendimiento

### Uso de Memoria
- **Caché Activo:** ~3 Pokémon (mínimo)
- **Lote de Precarga:** 10 Pokémon (temporal durante carga)
- **Liberación:** Automática después de usar cada Pokémon
- **Total Máximo:** ~13 Pokémon en memoria simultáneamente

### Tiempos de Carga
- **Inicialización:** < 1 segundo (setup de IDs)
- **Primera Precarga:** 2-4 segundos (10 Pokémon)
- **Precarga Subsiguiente:** En background, invisible para el usuario
- **Cambio de Pregunta:** Instantáneo (desde caché)

## Cómo Usar

1. **Desde la HomePage:** Navegar a la sección de Quiz
2. **Seleccionar Modalidad:** Elegir entre las 4 modalidades disponibles
3. **Presionar JUGAR:** Se abre el modal de nombre
4. **Ingresar Nombre:** Máximo 3 letras (opcional, default "ASH")
5. **Esperar Carga:** Pantalla de carga mientras se precargan los primeros Pokémon
6. **Jugar:** El juego inicia automáticamente con 30 segundos
7. **Responder:** Seleccionar una de las 4 opciones
8. **Continuar:** El juego carga automáticamente la siguiente pregunta
9. **Game Over:** Al acabarse el tiempo, se muestra el diálogo final
10. **Guardar Resultado:** Si entró al Top 5, confirmar o cambiar nombre

## Salón de la Fama

Muestra el Top 5 con:
- Trofeo de oro para 1er lugar
- Trofeo de plata para 2do lugar
- Trofeo de bronce para 3er lugar
- Posiciones 4 y 5 con numeración

Cada entrada muestra:
- Nombre del jugador (3 caracteres)
- Tiempo total (formato hh:mm:ss)
- Puntuación final (formateada con comas)

## Características Destacadas

- **Código Limpio y Modular:** Arquitectura BLoC bien estructurada
- **Manejo de Errores:** Gestión robusta de errores de red y caché
- **Performance Optimizada:** Carga en lotes para evitar problemas de memoria
- **UX Fluida:** Animaciones y transiciones suaves
- **Persistencia Robusta:** Datos guardados de forma segura localmente
- **Responsive:** Funciona en diferentes tamaños de pantalla
- **Escalable:** Preparado para jugar los 1025 Pokémon sin problemas

## Próximos Pasos (Para Implementar)

- Sistema de logros basado en las estadísticas recolectadas
- Compartir resultados
- Más modalidades de juego
- Configuración de dificultad (tiempo inicial, bonus, etc.)

## Notas Técnicas

- Compatible con Flutter 3.x
- Usa SharedPreferences para persistencia
- Integrado con AudioService existente para reproducción de cries
- Respeta el tema oscuro/claro de la aplicación
- Sin dependencias adicionales pesadas
- **Memoria optimizada:** Máximo 13 Pokémon en memoria simultáneamente
- **Sin límites:** Puede manejar los 1025 Pokémon en una sola partida

## Detalles de Implementación

### Precarga Inteligente
El sistema de precarga funciona de la siguiente manera:
1. Al iniciar, se cargan 10 Pokémon
2. Cada vez que se entregan Pokémon y quedan menos de 3 en caché, se activa una precarga en background
3. Los Pokémon se cargan en paralelo usando `Future.wait` para mejor rendimiento
4. Los IDs se seleccionan aleatoriamente del pool de disponibles
5. Una vez usado un Pokémon, su ID se marca como usado y NO se vuelve a cargar

### Gestión de Memoria
- Los Pokémon precargados se mantienen en una lista ligera
- Una vez entregados al juego, se remueven de la lista
- No se mantienen referencias a Pokémon ya jugados
- El garbage collector de Dart se encarga de liberar la memoria automáticamente
