extends Node
class_name ComponenteReputacion

signal estado_cambiado(anterior: CalculoAlineamiento.Estado, nuevo: CalculoAlineamiento.Estado)
signal afinidad_cambiada(afinidad: float)

@export var perfil: RecursoPerfilAlineamiento:
	set(valor):
		perfil = valor
		if is_inside_tree():
			recalcular()

var resultado: Dictionary = {}
var afinidad: float = 0.0
var estado := CalculoAlineamiento.Estado.INDIFERENTE

func _ready() -> void:
	add_to_group("reputacion")
	Alineamiento.alineamiento_cambiado.connect(_on_alineamiento_cambiado)
	recalcular()

func _on_alineamiento_cambiado(_ley: float, _bien: float) -> void:
	recalcular()

func recalcular() -> void:
	if perfil == null:
		return
	resultado = Alineamiento.calcular(perfil)
	var anterior = estado
	afinidad = resultado.afinidad
	estado = resultado.estado
	afinidad_cambiada.emit(afinidad)
	if estado != anterior:
		estado_cambiado.emit(anterior, estado)
