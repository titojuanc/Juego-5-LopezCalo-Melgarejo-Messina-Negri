extends Control

@onready var _boton_menu: Button = $Centro/Contenido/BotonMenu


func _ready() -> void:
	_boton_menu.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_action_pressed("interactuar"):
		return
	if _boton_menu.has_focus():
		get_viewport().set_input_as_handled()
		_boton_menu.pressed.emit()


func _volver_al_menu() -> void:
	Transiciones.cambiar_escena("res://scenes/main_menu.tscn")
