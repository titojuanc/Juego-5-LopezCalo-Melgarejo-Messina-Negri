extends Node3D
class_name PersonajeEnemigo

@export var datos: RecursoEnemigo

@onready var visual: Sprite3D = $Visual
@onready var salud: Salud = $Salud
@onready var combate: Combate = $Combate

func _ready() -> void:
	if datos:
		configurar(datos)

func configurar(nuevos_datos: RecursoEnemigo) -> void:
	datos = nuevos_datos
	name = datos.nombre
	salud.inicializar(datos.vida_max)
	if datos.textura:
		visual.texture = datos.textura

func atacar(objetivo: Salud) -> void:
	if datos == null:
		return
	combate.atacar_enemigo(objetivo, datos.ataque)
