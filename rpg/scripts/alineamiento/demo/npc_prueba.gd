extends Node2D

@export var perfil: RecursoPerfilAlineamiento

@export var escena_combate: String = "res://scenes/battle_arena.tscn"

@export var demora_combate: float = 1.0

@onready var reputacion: ComponenteReputacion = $ComponenteReputacion
@onready var visual: Sprite2D = $Visual
@onready var zona: Area2D = $Zona
@onready var label_nombre: Label = $Nombre
@onready var label_estado: Label = $Estado
@onready var label_reaccion: Label = $Reaccion

var _jugador_cerca := false
var _yendo_a_combate := false

func _ready() -> void:
	reputacion.perfil = perfil
	reputacion.estado_cambiado.connect(_on_estado_cambiado)
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)
	label_reaccion.text = ""
	if perfil:
		label_nombre.text = perfil.nombre
		visual.modulate = _color_alineamiento()
	_actualizar_estado()

func _color_alineamiento() -> Color:
	match CalculoAlineamiento.casilla(perfil.posicion_bien, Alineamiento.config):
		1:
			return Color(0.45, 0.7, 1.0)
		-1:
			return Color(1.0, 0.35, 0.35)
	return Color(0.8, 0.8, 0.8)

func _actualizar_estado() -> void:
	match reputacion.estado:
		CalculoAlineamiento.Estado.AMISTOSO:
			label_estado.text = "Amistoso"
			label_estado.modulate = Color.LIME_GREEN
		CalculoAlineamiento.Estado.HOSTIL:
			label_estado.text = "Hostil"
			label_estado.modulate = Color.RED
		_:
			label_estado.text = "Indiferente"
			label_estado.modulate = Color.LIGHT_GRAY

func _on_estado_cambiado(_anterior, _nuevo) -> void:
	_actualizar_estado()
	if _jugador_cerca:
		_reaccionar()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jugador"):
		return
	_jugador_cerca = true
	_reaccionar()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		_jugador_cerca = false
		label_reaccion.text = ""

func _reaccionar() -> void:
	match reputacion.estado:
		CalculoAlineamiento.Estado.AMISTOSO:
			label_reaccion.text = "¡Qué bueno verte!"
		CalculoAlineamiento.Estado.HOSTIL:
			label_reaccion.text = "¡No te quiero cerca!\n" + _motivo()
			_ir_a_combate()
		_:
			label_reaccion.text = "Mmm...\n" + _motivo()

func _motivo() -> String:
	match reputacion.resultado.get("eje"):
		CalculoAlineamiento.Eje.LEY:
			return "Desconfía de tus métodos"
		CalculoAlineamiento.Eje.BIEN:
			return "Le repugnan tus actos"
		CalculoAlineamiento.Eje.AMBOS:
			return "Desconfía de vos y de tus actos"
	return ""

func _ir_a_combate() -> void:
	if _yendo_a_combate:
		return
	_yendo_a_combate = true
	await get_tree().create_timer(demora_combate).timeout
	get_tree().change_scene_to_file(escena_combate)
