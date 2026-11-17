extends Node3D
class_name PersonajeCombate

@export var datos: RecursoPersonajeCombate
@export var altura_visual: float = 1.28

@onready var visual: Sprite3D = $Visual
@onready var salud: Salud = $Salud
@onready var combate: Combate = $Combate
@onready var inventario: Inventario = $Inventario
@onready var animaciones: Animaciones = $Animaciones

func _ready() -> void:
	if datos:
		configurar(datos)

func configurar(nuevos_datos: RecursoPersonajeCombate) -> void:
	datos = nuevos_datos
	name = datos.nombre
	salud.inicializar(Equipo.vida_max_de(datos), Equipo.vida_actual_de(datos))
	combate.inicializar(datos)
	inventario.inicializar(datos)
	if datos.textura:
		visual.texture = datos.textura
		visual.pixel_size = altura_visual / datos.textura.get_height()
		visual.position.y = altura_visual / 2
		if datos.textura.get_height() < 128:
			visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
