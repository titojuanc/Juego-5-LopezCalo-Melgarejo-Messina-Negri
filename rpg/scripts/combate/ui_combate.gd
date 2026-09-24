extends CanvasLayer
class_name UiCombate

@export var battle_manager: BattleManager
@export var PartyHealthbar :PackedScene
@export var EnemyHealthbar :PackedScene


@onready var label_turno: Label = $Control/Menu/Turno
@onready var boton_atacar: Button = $Control/Menu/Botones/BotonAtacar
@onready var boton_especial: Button = $Control/Menu/Botones/BotonEspecial
@onready var boton_defender: Button = $Control/Menu/Botones/BotonDefender
@onready var boton_item: Button = $Control/Menu/Botones/BotonItem
@onready var submenu: VBoxContainer = $Control/Menu/SubMenu

var _actor_actual: Node3D
var _paneles = {}
var _objetivos: Array = []
var _indice_objetivo: int = 0
var _al_elegir: Callable

func _ready() -> void:
	boton_atacar.pressed.connect(_on_atacar_presionado)
	boton_especial.pressed.connect(_on_especial_presionado)
	boton_defender.pressed.connect(_on_defender_presionado)
	#Global.new_personaje.connect(añadirPersonaje)
	#Global.new_enemigo.connect(añadirEnemigo)
	boton_item.pressed.connect(_on_item_presionado)


	if battle_manager:
		for personaje in _aliados():
			añadirPersonaje(personaje)
		for enemigo in _enemigos():
			añadirEnemigo(enemigo)
		actualizar_turno(battle_manager.personaje_actual())


## Conectar desde BattleManager (señal "turno_cambio") por Inspector, Node -> Signals.
func actualizar_turno(actor: Node3D) -> void:
	_actor_actual = actor
	_cerrar_submenu()
	label_turno.text = "Turno: %s" % (actor.name if actor else "-")
	_habilitar_botones(actor is PersonajeCombate)

func _habilitar_botones(activo: bool) -> void:
	boton_atacar.disabled = not activo
	boton_especial.disabled = not activo
	boton_defender.disabled = not activo
	boton_item.disabled = not activo

func _terminar_turno() -> void:
	_habilitar_botones(false)
	battle_manager.terminar_turno()

func _on_atacar_presionado() -> void:
	if _actor_actual == null:
		return
	_elegir_objetivo(_enemigos(), func(objetivo): _actor_actual.combate.atacar(objetivo.salud))

func _on_defender_presionado() -> void:
	if _actor_actual == null:
		return
	_cerrar_submenu()
	_actor_actual.salud.defender()
	_terminar_turno()

func _on_especial_presionado() -> void:
	if _actor_actual == null:
		return
	_abrir_submenu(_actor_actual.datos.ataques_especiales, _usar_especial)

func _usar_especial(indice: int) -> void:
	var especial: RecursoAtaqueEspecial = _actor_actual.combate.ataques_especiales[indice]
	if especial.costo_energia > _actor_actual.combate.energia_actual:
		return
	var candidatos = _enemigos()
	if especial.tipoSpell == RecursoAtaqueEspecial.TipoSpell.CURA:
		candidatos = _aliados()
	_elegir_objetivo(candidatos, func(objetivo): _actor_actual.combate.usar_ataque_especial(indice, objetivo.salud))

func _on_item_presionado() -> void:
	if _actor_actual == null:
		return
	_abrir_submenu(_actor_actual.inventario.items, _usar_item)

func _usar_item(indice: int) -> void:
	var item: RecursoItem = _actor_actual.inventario.items[indice]
	var candidatos = _aliados()
	if item.tipo == RecursoItem.TipoItem.ATK_DOWN or item.tipo == RecursoItem.TipoItem.DEF_DOWN:
		candidatos = _enemigos()
	_elegir_objetivo(candidatos, func(objetivo): _actor_actual.inventario.usar_item(indice, objetivo.salud, objetivo.combate))

func _abrir_submenu(opciones: Array, callback: Callable) -> void:
	_cerrar_submenu()
	if opciones.is_empty():
		return
	for i in opciones.size():
		var boton := Button.new()
		boton.text = opciones[i].nombre
		boton.pressed.connect(callback.bind(i))
		submenu.add_child(boton)
	submenu.visible = true

func _cerrar_submenu() -> void:
	_cancelar_seleccion()
	submenu.visible = false
	for hijo in submenu.get_children():
		hijo.queue_free()

func _elegir_objetivo(candidatos: Array, callback: Callable) -> void:
	_cerrar_submenu()
	_objetivos = candidatos.filter(func(p): return p.salud.esta_viva())
	if _objetivos.is_empty():
		return
	_al_elegir = callback
	_indice_objetivo = 0
	label_turno.text = "Turno: %s - elegí objetivo" % _actor_actual.name
	_paneles[_objetivos[0]].resaltar(true)

func _mover_seleccion(direccion: int) -> void:
	_seleccionar(wrapi(_indice_objetivo + direccion, 0, _objetivos.size()))

func _seleccionar(indice: int) -> void:
	_paneles[_objetivos[_indice_objetivo]].resaltar(false)
	_indice_objetivo = indice
	_paneles[_objetivos[_indice_objetivo]].resaltar(true)

func _cancelar_seleccion() -> void:
	if _objetivos.is_empty():
		return
	for objetivo in _objetivos:
		_paneles[objetivo].resaltar(false)
	_objetivos = []
	if _actor_actual:
		label_turno.text = "Turno: %s" % _actor_actual.name

func _confirmar(objetivo: Node3D) -> void:
	var callback := _al_elegir
	_cancelar_seleccion()
	callback.call(objetivo)
	_terminar_turno()

func _on_panel_elegido(personaje: Node3D) -> void:
	if _objetivos.has(personaje):
		_confirmar(personaje)

func _on_panel_apuntado(personaje: Node3D) -> void:
	if _objetivos.has(personaje):
		_seleccionar(_objetivos.find(personaje))

func _input(event: InputEvent) -> void:
	if _objetivos.is_empty():
		return
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
		_mover_seleccion(1)
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
		_mover_seleccion(-1)
	elif event.is_action_pressed("ui_accept"):
		_confirmar(_objetivos[_indice_objetivo])
	elif event.is_action_pressed("ui_cancel"):
		_cancelar_seleccion()
	else:
		return
	get_viewport().set_input_as_handled()

func _aliados() -> Array:
	return battle_manager.contenedor_equipo.get_children()

func _enemigos() -> Array:
	return battle_manager.contenedor_enemigos.get_children()

func añadirPersonaje(personaje):
	var Healthbar:UiEstadoP=PartyHealthbar.instantiate()
	Healthbar.personaje=personaje
	$Control/ContainerEstadoParty.add_child(Healthbar)
	Healthbar.elegido.connect(_on_panel_elegido)
	Healthbar.apuntado.connect(_on_panel_apuntado)
	_paneles[personaje]=Healthbar
func añadirEnemigo(enemigo):
	var Healthbar:UiEstado=EnemyHealthbar.instantiate()
	Healthbar.personaje=enemigo
	$Control/ContainerEstadoFoes.add_child(Healthbar)
	Healthbar.elegido.connect(_on_panel_elegido)
	Healthbar.apuntado.connect(_on_panel_apuntado)
	_paneles[enemigo]=Healthbar
