# Guía de corrección

Documento orientativo para la corrección del proyecto. Lista las escenas, demos y scripts
más relevantes, ordenados por sistema, indicando qué hay que mirar en cada uno.

> **Proyecto Godot:** `rpg/project.godot` (Godot 4.7, Forward+)
> **Escena principal:** `rpg/scenes/main_menu.tscn`

---

## 0. Punto de entrada y Autoloads

| Elemento | Ruta | Qué revisar |
|---|---|---|
| Menú principal | `rpg/scenes/main_menu.tscn` + `scripts/menus/menu_principal.gd` | Escena inicial del juego |
| Menú de opciones | `rpg/scenes/menus/menu_opciones.tscn` + `scripts/menus/menu_opciones.gd` | Guardado de configuración |
| `Global` | `rpg/scripts/global.gd` | Estado global compartido entre escenas |
| `Configuracion` | `rpg/scripts/configuracion.gd` | Persistencia de ajustes |
| `MotorDialogo` | `rpg/scripts/motor_dialogo.gd` + `scenes/HUD/MotorDialogo.tscn` | Sistema de diálogos (104 líneas) |
| `Transiciones` | `rpg/scripts/transiciones.gd` + `scenes/HUD/Transiciones.tscn` | Fundidos y cambio de escena |
| `Alineamiento` | `rpg/scripts/alineamiento/gestor_alineamiento.gd` | Singleton del sistema moral |
| `Equipo` | `rpg/scripts/party/gestor_equipo.gd` | Singleton de la party |

---

## 1. Escenas demo (recomendadas para probar rápido)

Son escenas aisladas pensadas para testear cada sistema sin recorrer el juego entero.

| Demo | Escena | Script | Sistema que demuestra |
|---|---|---|---|
| Alineamiento | `rpg/scenes/alineamiento/demo/demo_alineamiento.tscn` | `scripts/alineamiento/demo/demo_alineamiento.gd` | Acciones morales modifican el perfil del jugador en tiempo real |
| NPC de prueba | `rpg/scenes/alineamiento/demo/npc_prueba.tscn` | `scripts/alineamiento/demo/npc_prueba.gd` | Reacción de un NPC según reputación/alineamiento |
| NPCs / diálogos | `rpg/scenes/npcs/demo/demo_npcs.tscn` | `scripts/npcs/demo/demo_npcs.gd` | Interacción, diálogo y movimiento autónomo de NPCs |
| Arena de combate | `rpg/scenes/battle_arena.tscn` | `scripts/combate/battle_manager.gd` | Combate por turnos completo con minijuegos |

---

## 2. Mapas / niveles

| Mapa | Ruta | Notas |
|---|---|---|
| Juego (contenedor) | `rpg/scenes/game.tscn` | Escena que arma el overworld |
| Laboratorio 01 | `rpg/scenes/niveles/zona_01/lab_01.tscn` | Primer mapa jugable, TileMap + puertas |
| Laboratorio 02 | `rpg/scenes/niveles/zona_01/lab_02.tscn` | Segundo mapa, conectado por puertas |
| Puerta | `rpg/scenes/niveles/puerta.tscn` + `scripts/niveles/puerta.gd` | Transición entre mapas con punto de aparición |
| Interactuable | `rpg/scenes/niveles/interactuable.tscn` + `scripts/niveles/interactuable.gd` | Clase base de objetos con los que se interactúa (tecla `interactuar` = Z) |

Tilesets usados: `rpg/assets/tiles_entorno/` (`pisos_y_paredes.png`, `props_general.png`, `props_general_2.png`).
Capas de física configuradas: `1 Jugador`, `2 Enemigos`, `3 Paredes`, `4 Objetos`.

---

## 3. Sistema de combate (lo más complejo)

### Escenas
- `rpg/scenes/battle_arena.tscn` — arena de batalla, punto de entrada del combate.
- `rpg/scenes/combate/personajes/personaje_combate.tscn` — aliado en combate.
- `rpg/scenes/combate/enemigos/personaje_enemigo.tscn` — enemigo en combate.
- `rpg/scenes/combate/UI/ui_combate.tscn`, `ui_estado.tscn`, `ui_estado_party.tscn` — interfaz de turnos y barras de estado.

### Scripts clave
| Script | Líneas | Responsabilidad |
|---|---|---|
| `scripts/combate/battle_manager.gd` | 109 | **Núcleo del combate:** orden de turnos, flujo de ronda, condiciones de victoria/derrota |
| `scripts/combate/ui_combate.gd` | 196 | **Script más grande del proyecto:** menús de acción, selección de objetivo, items |
| `scripts/combate/personaje_combate.gd` | — | Stats, acciones y estado de un aliado |
| `scripts/combate/personaje_enemigo.gd` | — | IA básica de decisión del enemigo |
| `scripts/combate/salud.gd` | 42 | Componente de vida reutilizable (señales de daño/muerte) |
| `scripts/combate/inventario.gd` | — | Uso de items en batalla |
| `scripts/combate/animaciones.gd` | 56 | Sincronización de animaciones con el flujo de turnos |
| `scripts/combate/camara_combate.gd` | 40 | Encuadre dinámico de la cámara |

### Minijuegos de ataque (mecánica destacada)
Cada tipo de daño tiene su propio minijuego de timing/precisión que modifica el daño final.

- Base: `scripts/combate/minijuegos/minijuego_ataque.gd` (clase abstracta)
- Contenedor: `scripts/combate/minijuegos/ventana_minijuego.gd` + `scenes/combate/minijuegos/ventana_minijuego.tscn`
- Variantes:
  - **Cortante** — `minijuego_cortante.gd` (89 líneas, el más elaborado) + `minijuego_cortante.tscn`
  - **Perforante** — `minijuego_perforante.gd` + `minijuego_perforante.tscn`
  - **Contundente** — `minijuego_contundente.gd` + `minijuego_contundente.tscn`

### Recursos custom (`Resource`) — datos del combate
Definiciones en `rpg/scripts/recursos/`: `recurso_arma.gd`, `recurso_ataque_especial.gd`,
`recurso_enemigo.gd`, `recurso_item.gd`, `recurso_personaje_combate.gd`, `recurso_npc.gd`.

Instancias `.tres` de ejemplo en:
- Armas: `scenes/combate/armas/Arma_prueba1..3.tres`
- Ataques especiales: `scenes/combate/ataques_especiales/` (cortante, perforante, cura)
- Items: `scenes/combate/items/` (HP, buffs y debuffs de ATK/DEF)
- Enemigos: `scenes/combate/enemigos/test_enemigo1..4.tres`
- Personajes: `scenes/combate/personajes/PJ_prueba1..3.tres`

---

## 4. Sistema de alineamiento moral

Sistema de ejes tipo D&D (legal/caótico × bueno/malvado) que afecta la reacción de los NPCs.

| Script | Responsabilidad |
|---|---|
| `scripts/alineamiento/gestor_alineamiento.gd` | Autoload: registra acciones y expone el alineamiento actual |
| `scripts/alineamiento/calculo_alineamiento.gd` | **Lógica de cálculo:** mapea puntajes a un perfil concreto |
| `scripts/alineamiento/componente_reputacion.gd` | Componente acoplable a NPCs/facciones |
| `scripts/alineamiento/recurso_accion_moral.gd` | Recurso que define el peso moral de una acción |
| `scripts/alineamiento/recurso_perfil_alineamiento.gd` | Recurso de perfil resultante |
| `scripts/alineamiento/recurso_config_alineamiento.gd` | Umbrales y configuración global |

Datos: `scenes/alineamiento/config_alineamiento.tres`, `scenes/alineamiento/acciones/*.tres`
y los 9 perfiles en `scenes/alineamiento/perfiles/`.

---

## 5. NPCs y diálogos

- `rpg/scenes/npcs/npc.tscn` + `scripts/npcs/npc.gd` (115 líneas) — interacción, diálogo y enlace con alineamiento.
- `scripts/npcs/movimiento_npc.gd` (72) — patrullaje / movimiento autónomo.
- Datos de NPC: `scenes/npcs/datos/curandera.tres`, `guardia.tres`, `maton.tres`.
- `scripts/motor_dialogo.gd` (104) — autoload del motor de diálogos.

---

## 6. Party y exploración

| Elemento | Ruta | Notas |
|---|---|---|
| Party | `rpg/scenes/party/party.tscn` + `scripts/party/party.gd` | Grupo jugable |
| Seguidor | `rpg/scenes/party/seguidor.tscn` + `scripts/party/seguidor.gd` | Seguimiento del líder con buffer de posiciones |
| Gestor de equipo | `scripts/party/gestor_equipo.gd` | Autoload: miembros activos, puente overworld ↔ combate |
| Jugador | `rpg/scenes/main_character.tscn` + `scripts/movimiento_jugador.gd` | Movimiento top-down |
| Explorador | `scripts/personaje_explorador.gd` | Base común de personajes en overworld |
| Enemigo overworld | `rpg/scenes/enemigo_overworld.tscn` | Encuentro que dispara el combate |

---

## 7. Orden sugerido de corrección

1. Abrir el proyecto y correr la escena principal (`main_menu.tscn`).
2. Probar las **demos** de la sección 1 (cada sistema aislado).
3. Recorrer `lab_01.tscn` → `lab_02.tscn` para ver mapas, puertas e interactuables.
4. Entrar a `battle_arena.tscn` y probar los tres minijuegos de ataque.
5. Revisar en código: `battle_manager.gd`, `ui_combate.gd`, `minijuego_cortante.gd`,
   `calculo_alineamiento.gd` y `npc.gd` (son los que concentran la lógica no trivial).

---

## 8. Controles

| Acción | Tecla |
|---|---|
| Movimiento | Flechas / WASD |
| Interactuar | `Z` |
| Confirmar / minijuegos | Ver indicaciones en pantalla de cada minijuego |
