extends PanelContainer
class_name UiEstadoP
@onready var barraEnergia=$Contenido/Barras/BarraEnergia

@export var datosP : RecursoPersonajeCombate

@onready var barraVida = $Contenido/Barras/BarraVida

@onready var retrato = $Contenido/Retrato

func _ready() -> void:
	print(datosP)
	configurarP(datosP)
	
func configurarP(nuevos_datos: RecursoPersonajeCombate) -> void:
	barraVida.max_value=nuevos_datos.vida_max
	if nuevos_datos.textura:
		retrato.texture = nuevos_datos.textura
	datosExtra(nuevos_datos)

func datosExtra(nuevos_datos: RecursoPersonajeCombate) -> void:
	barraEnergia.max_value=nuevos_datos.energia_max
