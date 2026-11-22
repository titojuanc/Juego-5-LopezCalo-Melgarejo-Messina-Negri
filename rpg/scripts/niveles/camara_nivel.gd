extends Node2D

# Camara estilo Undertale para niveles largos: sigue al jugador solo cuando se
# acerca a los margenes de la pantalla y nunca muestra nada fuera del area de
# limites.

@onready var _camara: Camera2D = $Camara
@onready var _forma_limites: CollisionShape2D = $Limites/CollisionShape2D


func _ready() -> void:
	_aplicar_limites()
	_camara.make_current()
	GestorJugador.jugador_acoplado.connect(_al_acoplar_jugador)
	_centrar_en_jugador()
	_camara.reset_smoothing()


func _physics_process(_delta: float) -> void:
	_centrar_en_jugador()


func _centrar_en_jugador() -> void:
	var cuerpo: CharacterBody2D = GestorJugador.cuerpo
	if is_instance_valid(cuerpo) and cuerpo.is_inside_tree():
		_camara.global_position = cuerpo.global_position


# Cuando el jugador aparece en el nivel, la vista arranca centrada en el.
func _al_acoplar_jugador(_jugador: Node2D) -> void:
	_centrar_en_jugador()
	_camara.align()


# Convierte el rectangulo de la caja Limites en los limites de la camara.
func _aplicar_limites() -> void:
	var forma: RectangleShape2D = _forma_limites.shape as RectangleShape2D
	var centro: Vector2 = _forma_limites.global_position
	var mitad: Vector2 = forma.size * _forma_limites.global_scale.abs() * 0.5
	_camara.limit_left = int(centro.x - mitad.x)
	_camara.limit_top = int(centro.y - mitad.y)
	_camara.limit_right = int(centro.x + mitad.x)
	_camara.limit_bottom = int(centro.y + mitad.y)

func _exit_tree() -> void:
	if GestorJugador.jugador_acoplado.is_connected(_al_acoplar_jugador):
		GestorJugador.jugador_acoplado.disconnect(_al_acoplar_jugador)
	if _camara != null and _camara.is_current():
		get_viewport().canvas_transform = Transform2D()
