extends Resource
class_name RecursoEnemigo

@export var nombre: String
@export var vida_max: int = 100
@export var descripcion: String
@export var ataque: int = 0
@export var textura: Texture2D
@export var debilidades: Array[RecursoAtaqueEspecial.TipoAtaque] = []
@export var resistencias: Array[RecursoAtaqueEspecial.TipoAtaque] = []
@export var multiplicador_debilidad: float = 1.5
@export var multiplicador_resistencia: float = 0.5
@export var experiencia: int = 20
@export var oro: int = 10
@export var item_drop: RecursoItem
@export_range(0.0, 1.0, 0.05) var probabilidad_drop: float = 0.5
@export var es_jefe: bool = false
@export var arma_drop: RecursoArma
@export var flag_debilitado: StringName = &""
@export var flag_ayuda: StringName = &""

func multiplicador_contra(tipo: RecursoAtaqueEspecial.TipoAtaque) -> float:
	if debilidades.has(tipo):
		return multiplicador_debilidad
	if resistencias.has(tipo):
		return multiplicador_resistencia
	return 1.0
