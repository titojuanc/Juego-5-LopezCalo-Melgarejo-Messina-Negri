extends Node
class_name MovimientoNpc

enum Modo {PATRULLA, DEAMBULAR}

@export var modo: Modo = Modo.DEAMBULAR

@export var velocidad: float = 120.0

@export var puntos: Array[Vector2] = []

@export var radio: float = 150.0

@export var espera: float = 1.5

@onready var npc: Npc = get_parent()

var _origen: Vector2
var _destino: Vector2
var _indice: int = 0
var _esperando: float = 0.0

func _ready() -> void:
	_origen = npc.global_position
	_destino = _origen
	_esperando = espera

func _physics_process(delta: float) -> void:
	if MotorDialogo.activo or Transiciones.en_curso or npc.atacando:
		_quieto()
		return
	if _esperando > 0.0:
		_esperando -= delta
		_quieto()
		if _esperando <= 0.0:
			_siguiente_destino()
		return
	if npc.global_position.distance_to(_destino) <= velocidad * delta:
		npc.global_position = _destino
		_esperando = espera
		_quieto()
		return
	var direccion = npc.global_position.direction_to(_destino)
	npc.velocity = direccion * velocidad
	npc.move_and_slide()
	_animar(direccion)
	if npc.get_real_velocity().length() < velocidad * 0.1:
		_esperando = espera

func _siguiente_destino() -> void:
	match modo:
		Modo.PATRULLA:
			if puntos.is_empty():
				_destino = _origen
				return
			_destino = _origen + puntos[_indice]
			_indice = (_indice + 1) % puntos.size()
		Modo.DEAMBULAR:
			_destino = _origen + Vector2.from_angle(randf() * TAU) * randf() * radio

func _animar(direccion: Vector2) -> void:
	if npc.sprite.sprite_frames.has_animation("Walk"):
		npc.sprite.play("Walk")
	if direccion.x < -0.1:
		npc.sprite.flip_h = true
	elif direccion.x > 0.1:
		npc.sprite.flip_h = false

func _quieto() -> void:
	npc.velocity = Vector2.ZERO
	if npc.sprite.sprite_frames.has_animation("Idle"):
		npc.sprite.play("Idle")
