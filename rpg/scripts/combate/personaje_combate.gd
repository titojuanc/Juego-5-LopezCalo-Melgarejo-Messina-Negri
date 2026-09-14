extends Node3D
class_name PersonajeCombate

@export var datos: RecursoPersonajeCombate

@onready var visual: AnimatedSprite3D = $Visual
@onready var salud: Salud = $Salud
@onready var combate: Combate = $Combate
@onready var inventario: Inventario = $Inventario

func _ready() -> void:
	if datos:
		configurar(datos)

func configurar(nuevos_datos: RecursoPersonajeCombate) -> void:
	datos = nuevos_datos
	name = datos.nombre
	salud.inicializar(datos.vida_max)
	combate.inicializar(datos)
	inventario.inicializar(datos)
	if datos.sprite_frames:
		visual.sprite_frames = datos.sprite_frames
		visual.play("default")
