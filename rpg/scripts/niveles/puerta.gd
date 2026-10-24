extends Node2D

enum DireccionLlegada { PERSONALIZADA, NORTE, SUR, ESTE, OESTE }

@export_file("*.tscn") var escena_destino: String = ""
@export var identificador: StringName = &""
@export var puerta_destino: StringName = &""
@export var direccion_llegada: DireccionLlegada = DireccionLlegada.PERSONALIZADA
@export_range(0.0, 1024.0, 1.0, "or_greater", "suffix:px") var distancia_llegada: float = 64.0

var _jugador_en_llegada: CharacterBody2D = null

@onready var _area: Area2D = $Area2D
@onready var _punto_llegada: Marker2D = $PuntoLlegada


func _ready() -> void:
	add_to_group("Puertas")
	_area.body_entered.connect(_al_entrar)
	_area.body_exited.connect(_al_salir)


func _al_entrar(cuerpo: Node2D) -> void:
	if cuerpo == _jugador_en_llegada:
		return
	if cuerpo.is_in_group("Jugador") and not Transiciones.en_curso:
		Transiciones.cambiar_escena(escena_destino, puerta_destino)


func _al_salir(cuerpo: Node2D) -> void:
	if cuerpo == _jugador_en_llegada:
		_jugador_en_llegada = null


func obtener_posicion_llegada() -> Vector2:
	var direccion: Vector2
	match direccion_llegada:
		DireccionLlegada.NORTE:
			direccion = Vector2.UP
		DireccionLlegada.SUR:
			direccion = Vector2.DOWN
		DireccionLlegada.ESTE:
			direccion = Vector2.RIGHT
		DireccionLlegada.OESTE:
			direccion = Vector2.LEFT
		_:
			return _punto_llegada.global_position
	return to_global(direccion * distancia_llegada)


func colocar_jugador(jugador: CharacterBody2D) -> void:
	_jugador_en_llegada = jugador
	jugador.global_position = obtener_posicion_llegada()
	jugador.velocity = Vector2.ZERO
	jugador.reset_physics_interpolation()
	for _paso in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame
	if not _area.overlaps_body(jugador):
		_jugador_en_llegada = null