extends Resource
class_name RecursoAccionMoral

@export var nombre: String

@export var desplazamiento_ley: float = 0.0

@export var desplazamiento_bien: float = 0.0

@export_range(0.0, 1.0, 0.05) var notoriedad: float = 0.5
