extends Node

var character_body: CharacterBody2D
var animated_sprite: AnimatedSprite2D

# Velocidad y movimiento
var velocity: Vector2 = Vector2.ZERO
var speed: float = 300.0


func _ready() -> void:
	character_body = get_parent()
	animated_sprite = character_body.get_node("AnimatedSprite2D")


func _physics_process(delta: float) -> void:
	var input_velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		input_velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		input_velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		input_velocity.y -= 1
	
	if input_velocity != Vector2.ZERO:
		input_velocity = input_velocity.normalized()
		velocity = input_velocity * speed
		animated_sprite.play("Walk")
		
		# Girar el sprite según la dirección horizontal
		if input_velocity.x < 0:
			animated_sprite.flip_h = true
		elif input_velocity.x > 0:
			animated_sprite.flip_h = false
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("Idle")
	
	character_body.velocity = velocity
	character_body.move_and_slide()
