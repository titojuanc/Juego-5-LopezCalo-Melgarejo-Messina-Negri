extends Node2D

enum LadoIndicador { PERSONALIZADO, NORTE, SUR, ESTE, OESTE }

@export var nombre: String
@export_multiline var lineas: Array[String] = []
@export var textura: Texture2D
@export var lado_indicador: LadoIndicador = LadoIndicador.NORTE
@export_range(0.0, 1024.0, 1.0, "or_greater", "suffix:px") var distancia_indicador: float = 40.0
var _jugadores: Array[Node2D] = []
var _escala_indicador: Vector2

@onready var _area: Area2D = $Area2D
@onready var _indicador: Sprite2D = $IndicadorInteraccion


func _ready() -> void:
	_area.area_entered.connect(_al_entrar)
	_area.area_exited.connect(_al_salir)
	if textura != null:
		$Sprite2D.texture = textura
	_escala_indicador = _indicador.scale
	_posicionar_indicador()
	_indicador.hide()


# Compensa la escala global del interactuable para que el simbolo y su distancia se midan en pantalla.
func _posicionar_indicador() -> void:
	var escala: Vector2 = global_scale.abs()
	_indicador.scale = _escala_indicador / escala
	var direccion: Vector2
	match lado_indicador:
		LadoIndicador.NORTE:
			direccion = Vector2.UP
		LadoIndicador.SUR:
			direccion = Vector2.DOWN
		LadoIndicador.ESTE:
			direccion = Vector2.RIGHT
		LadoIndicador.OESTE:
			direccion = Vector2.LEFT
		_:
			return
	_indicador.position = direccion * distancia_indicador / escala


func _process(_delta: float) -> void:
	_indicador.visible = distancia_al_jugador() < INF and tiene_dialogo() and not MotorDialogo.activo


func _al_entrar(area: Area2D) -> void:
	if area.is_in_group("InteraccionJugador") and not _jugadores.has(area):
		_jugadores.append(area)
		MotorDialogo.registrar(self)


func _al_salir(area: Area2D) -> void:
	_jugadores.erase(area)
	if _jugadores.is_empty():
		MotorDialogo.desregistrar(self)


func distancia_al_jugador() -> float:
	var distancia: float = INF
	for jugador in _jugadores:
		if is_instance_valid(jugador):
			distancia = minf(distancia, global_position.distance_squared_to(jugador.global_position))
	return distancia


func tiene_dialogo() -> bool:
	for linea in lineas:
		if not linea.strip_edges().is_empty():
			return true
	return false


func _exit_tree() -> void:
	if is_instance_valid(MotorDialogo):
		MotorDialogo.desregistrar(self)
