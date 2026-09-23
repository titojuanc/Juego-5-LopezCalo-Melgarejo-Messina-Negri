extends Resource
class_name RecursoPerfilAlineamiento

@export var nombre: String

@export var afinidad_base: float = 2.0

@export_group("Ley-Caos")
@export_range(-1.0, 1.0, 0.01) var posicion_ley: float = 0.0
@export_range(0.0, 2.0, 0.01) var umbral_ley: float = 0.0
@export var peso_ley: float = 1.0

@export_group("Bien-Mal")
@export_range(-1.0, 1.0, 0.01) var posicion_bien: float = 0.0
@export_range(0.0, 2.0, 0.01) var umbral_bien: float = 0.0
@export var peso_bien: float = 1.0
