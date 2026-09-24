extends Node
class_name Animaciones

@export var duracion: float = 1.0

@export var color_ataque: Color = Color(1, 1, 0.2)

@export var color_dano: Color = Color(1, 0.15, 0.15)

@export var color_cura: Color = Color(0.2, 1, 0.3)

@export var color_buff: Color = Color(0.3, 0.6, 1)

@export var color_debuff: Color = Color(0.7, 0.3, 1)

@export var color_defensa: Color = Color(0.15, 0.3, 1)

@export var color_muerto: Color = Color(0.35, 0.35, 0.35)

@export var escala_resaltado: float = 1.2

@onready var visual: Sprite3D = $"../Visual"

@onready var salud: Salud = $"../Salud"

@onready var combate: Combate = $"../Combate"

var _tween: Tween
var _escala_original: Vector3

func _ready() -> void:
	_escala_original = visual.scale
	combate.ataque_realizado.connect(func(atacante, objetivo, dano): destellar(color_ataque))
	combate.modificado.connect(func(positivo): destellar(color_buff if positivo else color_debuff))
	salud.herido.connect(func(cantidad): destellar(color_dano))
	salud.curado.connect(func(cantidad): destellar(color_cura))
	salud.defendio.connect(func(): destellar(color_defensa))

func destellar(color: Color) -> void:
	if _tween:
		_tween.kill()
	visual.modulate = color
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_property(visual, "modulate", _color_base(), duracion)

func resaltar(activo: bool) -> void:
	if activo:
		visual.scale = _escala_original * escala_resaltado
	else:
		visual.scale = _escala_original

func _color_base() -> Color:
	if salud.esta_viva():
		return Color.WHITE
	return color_muerto
