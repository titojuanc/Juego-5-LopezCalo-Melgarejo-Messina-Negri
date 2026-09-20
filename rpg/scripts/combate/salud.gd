extends Node
class_name Salud

signal vida_cambiada(actual: int, maximo: int)
signal murio

var vida_max: int = 1
var vida_actual: int = 1
var bonus_defensa: float = 1.0
var bloqueando: bool = false

func inicializar(max_vida: int) -> void:
	vida_max = max_vida
	vida_actual = max_vida
	vida_cambiada.emit(vida_actual, vida_max)

func defender() -> void:
	bloqueando = true

func recibir_dano(cantidad: int) -> void:
	if bloqueando:
		bloqueando = false
		return
	var dano_final := roundi(cantidad * bonus_defensa)
	vida_actual = clampi(vida_actual - dano_final, 0, vida_max)
	vida_cambiada.emit(vida_actual, vida_max)
	if vida_actual <= 0:
		murio.emit()

func curar(cantidad: int) -> void:
	vida_actual = clampi(vida_actual + cantidad, 0, vida_max)
	vida_cambiada.emit(vida_actual, vida_max)

func esta_viva() -> bool:
	return vida_actual > 0
