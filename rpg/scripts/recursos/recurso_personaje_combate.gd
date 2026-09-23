extends Resource
class_name RecursoPersonajeCombate

enum TipoEnergia {BALAS, ENERGIA, MANA}

@export var nombre: String
@export var vida_max: int = 100
@export var arma: RecursoArma
@export var ataques_especiales: Array[RecursoAtaqueEspecial] = []
@export var tipo_energia: TipoEnergia = TipoEnergia.ENERGIA
@export var energia_max: int = 100
@export var inventario: Array[RecursoItem] = []
@export var textura: Texture2D
