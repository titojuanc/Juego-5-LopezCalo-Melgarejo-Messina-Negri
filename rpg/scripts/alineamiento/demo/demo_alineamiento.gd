extends Node2D

@export var buena_accion: RecursoAccionMoral

@export var mala_accion: RecursoAccionMoral

@onready var label_alineamiento: Label = $Hud/LabelAlineamiento

func _ready() -> void:
	Alineamiento.alineamiento_cambiado.connect(_on_alineamiento_cambiado)
	_actualizar_hud()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1:
			Alineamiento.establecer(1.0, 1.0)
		KEY_2:
			Alineamiento.establecer(0.0, 0.0)
		KEY_3:
			Alineamiento.establecer(-1.0, -1.0)
		KEY_Q:
			Alineamiento.aplicar_accion(buena_accion)
		KEY_E:
			Alineamiento.aplicar_accion(mala_accion)

func _on_alineamiento_cambiado(_ley: float, _bien: float) -> void:
	_actualizar_hud()

func _actualizar_hud() -> void:
	label_alineamiento.text = "Alineamiento: " + Alineamiento.nombre_actual()
