extends Node2D

@export var accion_buena: RecursoAccionMoral

@export var accion_mala: RecursoAccionMoral

@onready var label_alineamiento: Label = $Hud/LabelAlineamiento

func _ready() -> void:
	Alineamiento.alineamiento_cambiado.connect(_on_alineamiento_cambiado)
	_actualizar_hud()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_Q:
		Alineamiento.aplicar_accion(accion_mala)
		return
	if event.keycode == KEY_E:
		Alineamiento.aplicar_accion(accion_buena)
		return
	var indice = event.keycode - KEY_1
	if indice < 0 or indice > 8:
		return
	Alineamiento.establecer(1.0 - indice % 3, 1.0 - floori(indice / 3.0))

func _on_alineamiento_cambiado(_ley: float, _bien: float) -> void:
	_actualizar_hud()

func _actualizar_hud() -> void:
	label_alineamiento.text = "Alineamiento: " + Alineamiento.nombre_actual()
