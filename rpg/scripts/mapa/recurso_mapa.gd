extends Resource
class_name RecursoMapa

@export var nombre: String

@export var salas: Array[RecursoSalaMapa] = []

func sala_de(escena: String) -> RecursoSalaMapa:
	for sala in salas:
		if sala.escena == escena:
			return sala
	return null
