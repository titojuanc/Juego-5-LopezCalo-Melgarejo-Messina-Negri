extends Node3D
class_name PersonajeEnemigo

@export var datos: RecursoEnemigo

@export var altura_visual: float = 1.28

var factor: float = 1.0

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
	factor = 1.0 if datos.es_jefe else Encuentros.multiplicador_piso()
	salud.inicializar(roundi(datos.vida_max * factor))
	if datos.textura:
		visual.texture = datos.textura
		visual.pixel_size = altura_visual / datos.textura.get_height()
		visual.position.y = altura_visual / 2
		if datos.textura.get_height() < 128:
			visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

func atacar(objetivo: Salud) -> void:
	if datos == null:
		return
	combate.atacar_enemigo(objetivo, roundi(datos.ataque * factor))
