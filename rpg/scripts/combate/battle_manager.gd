extends Node
class_name BattleManager

signal turno_cambio(actor: Node3D)

@export var escena_personaje: PackedScene

@export var escena_enemigo: PackedScene

@export var equipo: Array[RecursoPersonajeCombate] = []

@export var camara: CamaraCombate

@export var posiciones_equipo: Array[Vector3] = []

@export var posiciones_enemigos: Array[Vector3] = []

@export var enemigos: Array[RecursoEnemigo] = []

@export var demora_turno_enemigo: float = 1.0

@onready var contenedor_equipo: Node3D = $Equipo

@onready var contenedor_enemigos: Node3D = $Enemigos


var _combatientes: Array = []
var _turno_actual: int = -1

func _ready() -> void:
	_generar_equipos()
	_combatientes = contenedor_equipo.get_children()
	_combatientes.append_array(contenedor_enemigos.get_children())
	avanzar_turno.call_deferred()

func _generar_equipos() -> void:
	if escena_personaje == null:
		return
	var cantidad := clampi(equipo.size(), 1, 3)
	for i in cantidad:
		var personaje: PersonajeCombate = escena_personaje.instantiate()
		personaje.datos = equipo[i]
		contenedor_equipo.add_child(personaje)
		if i < posiciones_equipo.size():
			personaje.position = posiciones_equipo[i]
	cantidad = clampi(enemigos.size(), 1, 4)
	for i in cantidad:
		var enemigo: PersonajeEnemigo = escena_enemigo.instantiate()
		enemigo.datos = enemigos[i]
		contenedor_enemigos.add_child(enemigo)
		if i < posiciones_enemigos.size():
			enemigo.position = posiciones_enemigos[i]


func personaje_actual() -> Node3D:
	if _turno_actual < 0 or _turno_actual >= _combatientes.size():
		return null
	return _combatientes[_turno_actual]

func avanzar_turno() -> void:
	if _combatientes.is_empty():
		return
	var intentos := 0
	while intentos < _combatientes.size():
		_turno_actual = (_turno_actual + 1) % _combatientes.size()
		if _combatientes[_turno_actual].salud.esta_viva():
			break
		intentos += 1
	var actor := personaje_actual()
	turno_cambio.emit(actor)
	_mover_camara_a(actor)
	if contenedor_enemigos.get_children().has(actor):
		_turno_enemigo(actor)

func _mover_camara_a(actor: Node3D) -> void:
	if camara == null or actor == null:
		return
	if contenedor_enemigos.get_children().has(actor):
		camara.enfocar_enemigo()
	else:
		var indice := contenedor_equipo.get_children().find(actor)
		if indice != -1:
			camara.enfocar_aliado(indice)

func _turno_enemigo(enemigo: PersonajeEnemigo) -> void:
	var vivos: Array = contenedor_equipo.get_children().filter(func(p): return p.salud.esta_viva())
	if not vivos.is_empty():
		var objetivo = vivos[randi() % vivos.size()]
		enemigo.atacar(objetivo.salud)
	await get_tree().create_timer(demora_turno_enemigo).timeout
	avanzar_turno()
