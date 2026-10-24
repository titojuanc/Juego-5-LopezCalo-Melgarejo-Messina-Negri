extends CharacterBody2D

@export var velocidad: float = 300.0

func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * velocidad
	move_and_slide()
