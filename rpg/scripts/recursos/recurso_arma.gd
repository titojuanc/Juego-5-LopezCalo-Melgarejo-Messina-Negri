extends Resource
class_name RecursoArma

enum TipoAtaque {CONTUNDENTE, PERFORANTE, CORTANTE}

@export var nombre: String
@export var daño: int = 0
@export var descripcion: String
@export var tipo_ataque: TipoAtaque = TipoAtaque.CONTUNDENTE
