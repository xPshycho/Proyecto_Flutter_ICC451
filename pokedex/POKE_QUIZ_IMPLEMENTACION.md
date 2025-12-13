# Poke Quiz - Implementación Completa

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
└── quiz_ranking_service.dart  # Servicio de persistencia del ranking
```

### BLoC (Lógica de Negocio)
```
lib/presentation/bloc/quiz/
├── quiz_bloc.dart             # Lógica principal del quiz
├── quiz_event.dart            # Eventos del quiz
└── quiz_state.dart            # Estados del quiz
```

### Páginas
```
lib/presentation/pages/
├── quiz_page.dart             # Página principal del juego
└── quiz_home_page.dart        # Página de inicio con ranking (actualizada)
```

### Componentes de UI
```
lib/presentation/widgets/quiz_components/
├── quiz_stats_bar.dart        # Barra superior con estadísticas
├── quiz_display_area.dart     # Área de visualización del atributo
├── quiz_answer_options.dart   # Botones de opciones de respuesta
└── quiz_game_over_dialog.dart # Diálogo de fin de partida
```

## Diseño de UI

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
- `usedPokemonIds`: IDs de Pokémon ya mostrados

## Cómo Usar

1. **Desde la HomePage:** Navegar a la sección de Quiz
2. **Seleccionar Modalidad:** Elegir entre las 4 modalidades disponibles
3. **Presionar JUGAR:** Inicia el quiz con 30 segundos
4. **Responder:** Seleccionar una de las 4 opciones
5. **Continuar:** El juego carga automáticamente la siguiente pregunta
6. **Game Over:** Al acabarse el tiempo, se muestra el diálogo final
7. **Guardar Resultado:** Si entró al Top 5, ingresar nombre de 3 letras

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
- **Performance:** Caché de Pokémon para evitar peticiones redundantes
- **UX Fluida:** Animaciones y transiciones suaves
- **Persistencia Robusta:** Datos guardados de forma segura localmente
- **Responsive:** Funciona en diferentes tamaños de pantalla

## Próximos Pasos (Para Implementar)

- Sistema de logros basado en las estadísticas recolectadas
- Compartir resultados
- Más modalidades de juego

## Notas Técnicas

- Compatible con Flutter 3.x
- Usa SharedPreferences para persistencia
- Integrado con AudioService existente para reproducción de cries
- Respeta el tema oscuro/claro de la aplicación
- Sin dependencias adicionales pesadas


