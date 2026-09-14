extends Node
class_name BattleManager

@export var escena_personaje: PackedScene
## Entre 1 y 3 personajes: el equipo que entra a este combate.
@export var equipo: Array[RecursoPersonajeCombate] = []

@onready var contenedor_equipo: Node3D = $Equipo

func _ready() -> void:
	_generar_equipo()

func _generar_equipo() -> void:
	if escena_personaje == null:
		return
	var cantidad := clampi(equipo.size(), 1, 3)
	for i in cantidad:
		var personaje: PersonajeCombate = escena_personaje.instantiate()
		personaje.datos = equipo[i]
		contenedor_equipo.add_child(personaje)
