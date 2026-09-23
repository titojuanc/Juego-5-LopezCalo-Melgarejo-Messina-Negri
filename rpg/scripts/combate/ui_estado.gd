extends PanelContainer
class_name UiEstado

@export var datos : RecursoEnemigo

@onready var barraVida = $Contenido/Barras/BarraVida

@onready var retrato = $Contenido/Retrato

func _ready() -> void:
	print(datos)
	configurar(datos)

func configurar(datos : RecursoEnemigo) -> void:
	barraVida.max_value=datos.vida_max
	barraVida.value=datos.vida_max
	if datos.textura:
		retrato.texture = datos.textura
	datosExtra(datos)

func datosExtra(datos):
	pass
