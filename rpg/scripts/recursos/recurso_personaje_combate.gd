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
@export var retrato: Texture2D
@export var perfil: RecursoPerfilAlineamiento
@export var vida_por_nivel: int = 10
@export var ataque_por_nivel: int = 2
@export var energia_por_nivel: int = 5
