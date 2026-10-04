extends Resource
class_name RecursoAtaqueEspecial
enum TipoSpell {DAÑO, CURA}
enum TipoAtaque {CONTUNDENTE, PERFORANTE, CORTANTE}

@export var nombre: String
@export var tipoSpell: TipoSpell
@export var tipo_ataque: TipoAtaque
@export var daño: int = 0
@export var costo_energia: int = 0
@export var descripcion: String
