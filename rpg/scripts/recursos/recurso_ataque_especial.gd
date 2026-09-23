extends Resource
class_name RecursoAtaqueEspecial
enum TipoSpell {DAÑO, CURA}

@export var nombre: String
@export var tipoSpell: TipoSpell
@export var daño: int = 0
@export var costo_energia: int = 0
@export var descripcion: String
