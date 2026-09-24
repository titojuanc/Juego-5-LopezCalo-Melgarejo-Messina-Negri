extends Node
class_name Combate

signal ataque_realizado(atacante: Node3D, objetivo: Salud, dano: int)
signal energia_cambiada(actual: int, maximo: int)
signal modificado(positivo: bool)

@onready var propietario: Node3D = get_parent()

var arma: RecursoArma
var ataques_especiales: Array[RecursoAtaqueEspecial] = []
var energia_max: int = 0
var energia_actual: int = 0
var bonus_ataque: float = 1.0

func inicializar(datos: RecursoPersonajeCombate) -> void:
	arma = datos.arma
	ataques_especiales = datos.ataques_especiales
	energia_max = datos.energia_max
	energia_actual = datos.energia_max

func atacar(objetivo: Salud) -> void:
	if arma == null or objetivo == null:
		return
	var dano := roundi(arma.daño * bonus_ataque)
	objetivo.recibir_dano(dano)
	ataque_realizado.emit(propietario, objetivo, dano)

func atacar_enemigo(objetivo: Salud, ataque: int) -> void:
	if objetivo == null:
		return
	var dano := roundi(ataque * bonus_ataque)
	objetivo.recibir_dano(dano)
	ataque_realizado.emit(propietario, objetivo, dano)

func usar_ataque_especial(indice: int, objetivo: Salud) -> void:
	if indice < 0 or indice >= ataques_especiales.size() or objetivo == null:
		return
	var especial := ataques_especiales[indice]
	if especial.costo_energia > energia_actual:
		return
	energia_actual -= especial.costo_energia
	energia_cambiada.emit(energia_actual, energia_max)
	var dano := roundi(especial.daño * bonus_ataque)
	if(especial.tipoSpell == especial.TipoSpell.DAÑO ):
		objetivo.recibir_dano(dano)
		ataque_realizado.emit(propietario, objetivo, dano)

	else:
		objetivo.curar(dano)
