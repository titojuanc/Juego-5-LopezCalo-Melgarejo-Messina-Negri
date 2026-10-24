extends Resource
class_name RecursoItem

enum TipoItem {HP, ATK_UP, DEF_UP, DEF_DOWN, ATK_DOWN}

@export var nombre: String
@export var tipo: TipoItem = TipoItem.HP
@export var valor: int = 0
@export var descripcion: String
