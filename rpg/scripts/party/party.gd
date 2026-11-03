extends Node2D
class_name Party

@export var lider: CharacterBody2D

@export var escena_seguidor: PackedScene

@export var equipo_inicial: Array[RecursoPersonajeCombate] = []

@export var espaciado: float = 96.0

@export var distancia_teletransporte: float = 64.0

var _rastro: Array[Vector2] = []
var _instancias: Array = []
var _ultima_posicion: Vector2

func _ready() -> void:
	if lider == null:
		lider = get_tree().get_first_node_in_group("Jugador")
	if Equipo.miembros.is_empty():
		Equipo.establecer(equipo_inicial)
	Equipo.equipo_cambiado.connect(_generar_seguidores)
	_generar_seguidores()

func _generar_seguidores() -> void:
	for seguidor in _instancias:
		seguidor.queue_free()
	_instancias.clear()
	if lider == null or escena_seguidor == null:
		return
	for datos in Equipo.seguidores():
		var seguidor: Seguidor = escena_seguidor.instantiate()
		seguidor.datos = datos
		add_child(seguidor)
		move_child(seguidor, 0)
		_instancias.append(seguidor)
	_reiniciar()

func _physics_process(delta: float) -> void:
	if lider == null or _instancias.is_empty():
		return
	var posicion = lider.global_position
	if posicion.distance_to(_ultima_posicion) > distancia_teletransporte:
		_reiniciar()
		return
	_ultima_posicion = posicion
	if posicion.distance_to(_rastro[0]) < 2.0:
		for seguidor in _instancias:
			seguidor.quieto()
		return
	_rastro.push_front(posicion)
	for i in _instancias.size():
		_instancias[i].mover_a(_punto_en_rastro(espaciado * (i + 1)), delta)
	var maximo = ceili(espaciado * _instancias.size() / 2.0) + 2
	if _rastro.size() > maximo:
		_rastro.resize(maximo)

func _reiniciar() -> void:
	_ultima_posicion = lider.global_position
	_rastro = [_ultima_posicion]
	for seguidor in _instancias:
		seguidor.global_position = _ultima_posicion
		seguidor.velocity = Vector2.ZERO
		seguidor.quieto()

func _punto_en_rastro(distancia: float) -> Vector2:
	var recorrido := 0.0
	for i in range(1, _rastro.size()):
		var tramo = _rastro[i - 1].distance_to(_rastro[i])
		if recorrido + tramo >= distancia:
			return _rastro[i - 1].lerp(_rastro[i], (distancia - recorrido) / tramo)
		recorrido += tramo
	return _rastro[-1]
