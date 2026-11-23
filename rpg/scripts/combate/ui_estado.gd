extends PanelContainer
class_name UiEstado

signal elegido(personaje: Node3D)
signal apuntado(personaje: Node3D)

var personaje: Node3D

@onready var barraVida = $Contenido/Barras/BarraVida

@onready var retrato = $Contenido/Retrato

@onready var nombre = $Contenido/Barras/Nombre

func _ready() -> void:
	mouse_entered.connect(func(): apuntado.emit(personaje))
	configurar(personaje)

func configurar(nuevo: Node3D) -> void:
	personaje = nuevo
	nombre.text = personaje.datos.nombre
	barraVida.max_value = personaje.salud.vida_max
	barraVida.value = personaje.salud.vida_actual
	personaje.salud.vida_cambiada.connect(_on_vida_cambiada)
	if personaje.datos.textura:
		retrato.texture = personaje.datos.textura
	datosExtra(personaje)

func datosExtra(personaje):
	pass

func _on_vida_cambiada(actual: int, maximo: int) -> void:
	barraVida.max_value = maximo
	barraVida.value = actual
	if actual <= 0:
		modulate = Color(1, 1, 1, 0.35)
	else:
		modulate = Color.WHITE

func resaltar(activo: bool) -> void:
	if activo:
		add_theme_stylebox_override("panel", get_theme_stylebox("panel_resaltado"))
	else:
		remove_theme_stylebox_override("panel")
	personaje.animaciones.resaltar(activo)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		elegido.emit(personaje)
