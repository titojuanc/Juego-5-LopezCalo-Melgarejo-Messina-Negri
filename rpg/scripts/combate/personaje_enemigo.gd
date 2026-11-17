extends Node3D
class_name PersonajeEnemigo

@export var datos: RecursoEnemigo

@export var altura_visual: float = 1.28

@onready var visual: Sprite3D = $Visual
@onready var salud: Salud = $Salud
@onready var combate: Combate = $Combate
@onready var animaciones: Animaciones = $Animaciones

func _ready() -> void:
	if datos:
		configurar(datos)

func configurar(nuevos_datos: RecursoEnemigo) -> void:
	datos = nuevos_datos
	name = datos.nombre
	salud.inicializar(datos.vida_max)
	if datos.textura:
		visual.texture = datos.textura
		visual.pixel_size = altura_visual / datos.textura.get_height()
		visual.position.y = altura_visual / 2
		if datos.textura.get_height() < 128:
			visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

func atacar(objetivo: Salud) -> void:
	if datos == null:
		return
	combate.atacar_enemigo(objetivo, datos.ataque)
