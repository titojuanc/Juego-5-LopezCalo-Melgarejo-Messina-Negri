extends Node2D

# Al elegir piso en el panel, sacude la "camara" cuando se cierra el dialogo,
# como si el ascensor se estuviera moviendo. Como el juego no usa Camera2D,
# la vibracion desplaza el canvas_transform del viewport.

@export var flag_piso: StringName = &"ascensor_piso_1"
@export_range(0.1, 5.0, 0.05, "suffix:s") var duracion_vibracion: float = 2.0
@export_range(0.5, 64.0, 0.5, "suffix:px") var intensidad_vibracion: float = 2.0
@export_range(1.0, 30.0, 0.5, "suffix:Hz") var frecuencia_vibracion: float = 8.0

var _vibracion_pendiente: bool = false
var _tiempo_restante: float = 0.0
var _origen_base: Vector2 = Vector2.ZERO


func _ready() -> void:
	GestorEventos.flag_cambiado.connect(_al_cambiar_flag)
	MotorDialogo.dialogo_finalizado.connect(_al_finalizar_dialogo)


func _al_cambiar_flag(nombre: StringName, _valor: bool) -> void:
	if nombre == flag_piso:
		_vibracion_pendiente = true


func _al_finalizar_dialogo() -> void:
	if _vibracion_pendiente:
		_vibracion_pendiente = false
		_origen_base = get_viewport().canvas_transform.origin
		_tiempo_restante = duracion_vibracion


func _process(delta: float) -> void:
	if _tiempo_restante <= 0.0:
		return
	_tiempo_restante = maxf(_tiempo_restante - delta, 0.0)
	if _tiempo_restante == 0.0:
		_restaurar_camara()
		return
	# Fuerza constante casi todo el tiempo; solo decae al final para terminar suave.
	var fuerza: float = intensidad_vibracion * minf(_tiempo_restante / (duracion_vibracion * 0.15), 1.0)
	# Oscilacion senoidal solo horizontal: un vaiven lateral parejo, sin saltos aleatorios.
	var transcurrido: float = duracion_vibracion - _tiempo_restante
	var desplazamiento := Vector2(sin(transcurrido * TAU * frecuencia_vibracion) * fuerza, 0.0)
	get_viewport().canvas_transform = Transform2D(0.0, _origen_base + desplazamiento)


func _restaurar_camara() -> void:
	get_viewport().canvas_transform = Transform2D(0.0, _origen_base)


func _exit_tree() -> void:
	if _tiempo_restante > 0.0:
		_tiempo_restante = 0.0
		_restaurar_camara()
