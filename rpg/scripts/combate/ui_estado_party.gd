extends UiEstado
class_name UiEstadoP

@onready var barraEnergia = $Contenido/Barras/BarraEnergia

func datosExtra(personaje) -> void:
	barraEnergia.max_value = personaje.combate.energia_max
	barraEnergia.value = personaje.combate.energia_actual
	personaje.combate.energia_cambiada.connect(_on_energia_cambiada)

func _on_energia_cambiada(actual: int, maximo: int) -> void:
	barraEnergia.max_value = maximo
	barraEnergia.value = actual
