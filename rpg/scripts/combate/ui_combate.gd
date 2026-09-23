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

func _ready() -> void:
	boton_atacar.pressed.connect(_on_atacar_presionado)
	boton_especial.pressed.connect(_on_especial_presionado)
	boton_defender.pressed.connect(_on_defender_presionado)
	#Global.new_personaje.connect(añadirPersonaje)
	#Global.new_enemigo.connect(añadirEnemigo)
	boton_item.pressed.connect(_on_item_presionado)
	

	if battle_manager:
		actualizar_turno(battle_manager.personaje_actual())
		var cantidad := clampi(battle_manager.equipo.size(), 1, 3)
		
		for i in cantidad:

			añadirPersonaje(battle_manager.equipo[i])
		cantidad = clampi(battle_manager.enemigos.size(), 1, 4)
		for i in cantidad:
			añadirEnemigo(battle_manager.enemigos[i])


## Conectar desde BattleManager (señal "turno_cambio") por Inspector, Node -> Signals.
func actualizar_turno(actor: Node3D) -> void:
	_actor_actual = actor
	_cerrar_submenu()
	label_turno.text = "Turno: %s" % (actor.name if actor else "-")
	var es_aliado := actor is PersonajeCombate
	boton_atacar.disabled = not es_aliado
	boton_especial.disabled = not es_aliado
	boton_defender.disabled = not es_aliado
	boton_item.disabled = not es_aliado

func _on_atacar_presionado() -> void:
	if _actor_actual == null or battle_manager.enemigo == null:
		return
	_actor_actual.combate.atacar(battle_manager.enemigo.salud)
	battle_manager.avanzar_turno()

func _on_defender_presionado() -> void:
	if _actor_actual == null:
		return
	_actor_actual.salud.defender()
	battle_manager.avanzar_turno()

func _on_especial_presionado() -> void:
	if _actor_actual == null:
		return
	_abrir_submenu(_actor_actual.datos.ataques_especiales, _usar_especial)

func _usar_especial(indice: int) -> void:
	_actor_actual.combate.usar_ataque_especial(indice, battle_manager.enemigo.salud)
	battle_manager.avanzar_turno()

func _on_item_presionado() -> void:
	if _actor_actual == null:
		return
	_abrir_submenu(_actor_actual.inventario.items, _usar_item)

func _usar_item(indice: int) -> void:
	_actor_actual.inventario.usar_item(indice, _actor_actual.salud, _actor_actual.combate)
	battle_manager.avanzar_turno()

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
	submenu.visible = false
	for hijo in submenu.get_children():
		hijo.queue_free()
		
func añadirPersonaje(personaje):
	var Healthbar:UiEstadoP=PartyHealthbar.instantiate()
	Healthbar.datosP=personaje
	$Control/ContainerEstadoParty.add_child(Healthbar)
func añadirEnemigo(enemigo):
	var Healthbar:UiEstado=EnemyHealthbar.instantiate()
	Healthbar.datos=enemigo
	$Control/ContainerEstadoFoes.add_child(Healthbar)
