extends Node2D

@export var nombre: String
@export_multiline var lineas: Array[String] = []
@export var textura: Texture2D
var _jugadores: Array[Node2D] = []

@onready var _area: Area2D = $Area2D
@onready var _indicador: Sprite2D = $IndicadorInteraccion


func _ready() -> void:
	_area.area_entered.connect(_al_entrar)
	_area.area_exited.connect(_al_salir)
	if textura != null:
		$Sprite2D.texture = textura
	_indicador.hide()


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
