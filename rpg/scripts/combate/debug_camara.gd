extends Node

@export var camara: CamaraCombate

func _unhandled_input(event: InputEvent) -> void:
	if camara == null or not event is InputEventKey or not event.pressed:
		return
	match event.keycode:
		KEY_1:
			camara.enfocar_aliado(0)
		KEY_2:
			camara.enfocar_aliado(1)
		KEY_3:
			camara.enfocar_aliado(2)
		KEY_0:
			camara.enfocar_enemigo()
