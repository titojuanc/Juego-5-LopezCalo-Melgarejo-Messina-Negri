extends Node
class_name BattleManager

signal turno_cambio(actor: Node3D)
signal combate_terminado(gano: bool)



@export var escena_personaje: PackedScene

@export var escena_enemigo: PackedScene

@export var equipo: Array[RecursoPersonajeCombate] = []

@export var camara: CamaraCombate

@export var posiciones_equipo: Array[Vector3] = []

@export var posiciones_enemigos: Array[Vector3] = []

@export var enemigos: Array[RecursoEnemigo] = []

@export var demora_turno_enemigo: float = 1.0

@export var demora_entre_turnos: float = 1.0

@export var escena_resultado: PackedScene = preload("res://scenes/combate/UI/resultado_combate.tscn")

@onready var contenedor_equipo: Node3D = $Equipo

@onready var contenedor_enemigos: Node3D = $Enemigos




var _combatientes: Array = []
var _turno_actual: int = -1
var _terminado := false
var _hay_ayuda := false

const VIDA_DEBILITADO := 0.7
const CURACION_AYUDA := 8

func _ready() -> void:
	if not Equipo.miembros.is_empty():
		equipo = Equipo.miembros
	if not Encuentros.enemigos.is_empty():
		enemigos = Encuentros.enemigos
	_generar_equipos()
	_aplicar_flags()
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
			Global.new_personaje.emit(personaje)

	cantidad = clampi(enemigos.size(), 1, 4)
	for i in cantidad:
		var enemigo: PersonajeEnemigo = escena_enemigo.instantiate()
		enemigo.datos = enemigos[i]
		contenedor_enemigos.add_child(enemigo)
		if i < posiciones_enemigos.size():
			enemigo.position = posiciones_enemigos[i]
			Global.new_enemigo.emit(enemigo)


func _aplicar_flags() -> void:
	for enemigo in contenedor_enemigos.get_children():
		var debilitado: StringName = enemigo.datos.flag_debilitado
		if not debilitado.is_empty() and GestorEventos.obtener_flag(debilitado):
			enemigo.salud.inicializar(enemigo.salud.vida_max, roundi(enemigo.salud.vida_max * VIDA_DEBILITADO))
		var ayuda: StringName = enemigo.datos.flag_ayuda
		if not ayuda.is_empty() and GestorEventos.obtener_flag(ayuda):
			_hay_ayuda = true

func personaje_actual() -> Node3D:
	if _turno_actual < 0 or _turno_actual >= _combatientes.size():
		return null
	return _combatientes[_turno_actual]

func avanzar_turno() -> void:
	if _combatientes.is_empty() or _terminado:
		return
	if _vivos(contenedor_enemigos).is_empty():
		_terminar(true)
		return
	if _vivos(contenedor_equipo).is_empty():
		_terminar(false)
		return
	var intentos := 0
	while intentos < _combatientes.size():
		_turno_actual = (_turno_actual + 1) % _combatientes.size()
		if _combatientes[_turno_actual].salud.esta_viva():
			break
		intentos += 1
	var actor := personaje_actual()
	if _hay_ayuda and contenedor_equipo.get_children().has(actor):
		actor.salud.curar(CURACION_AYUDA)
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

func terminar_turno() -> void:
	await get_tree().create_timer(demora_entre_turnos).timeout
	avanzar_turno()

func _vivos(contenedor: Node3D) -> Array:
	return contenedor.get_children().filter(func(p): return p.salud.esta_viva())

func _terminar(gano: bool) -> void:
	_terminado = true
	var resultado = escena_resultado.instantiate()
	add_child(resultado)
	var datos_enemigos = contenedor_enemigos.get_children().map(func(e): return e.datos)
	if gano:
		var miembros_vivos = _vivos(contenedor_equipo).map(func(p): return p.datos)
		for personaje in contenedor_equipo.get_children():
			Equipo.fijar_vida(personaje.datos, maxi(personaje.salud.vida_actual, 1))
		resultado.mostrar_victoria(Encuentros.cobrar(datos_enemigos, miembros_vivos))
	else:
		var jefe = datos_enemigos.any(func(d): return d.es_jefe)
		resultado.mostrar_derrota(Encuentros.perder(jefe), jefe)
	combate_terminado.emit(gano)

func _turno_enemigo(enemigo: PersonajeEnemigo) -> void:
	await get_tree().create_timer(demora_turno_enemigo).timeout
	var vivos: Array = _vivos(contenedor_equipo)
	if not vivos.is_empty():
		var objetivo = vivos[randi() % vivos.size()]
		enemigo.atacar(objetivo.salud)
	terminar_turno()
