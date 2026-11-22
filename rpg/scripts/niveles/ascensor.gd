extends Node2D

# Al elegir piso en el panel, sacude la "camara" cuando se cierra el dialogo,
# como si el ascensor se estuviera moviendo. Como el juego no usa Camera2D,
# la vibracion desplaza el canvas_transform del viewport.

const PuertaAscensor = preload("res://scripts/niveles/puerta_ascensor.gd")
const Interactuable = preload("res://scripts/niveles/interactuable.gd")
const PISOS_POR_OPCION := {
	&"ascensor_laboratorio": PuertaAscensor.Piso.LABORATORIO,
	&"ascensor_primer_piso": PuertaAscensor.Piso.PRIMER_PISO,
	&"ascensor_subsuelo": PuertaAscensor.Piso.SUBSUELO,
	&"ascensor_recepcion": PuertaAscensor.Piso.RECEPCION,
}
const TECLAS_POR_OPCION := {
	&"ascensor_instalar_subsuelo": [PuertaAscensor.FLAG_TECLA_SUBSUELO, PuertaAscensor.FLAG_SUBSUELO_HABILITADO],
	&"ascensor_instalar_recepcion": [PuertaAscensor.FLAG_TECLA_RECEPCION, PuertaAscensor.FLAG_RECEPCION_HABILITADA],
}

@export_range(0.1, 5.0, 0.05, "suffix:s") var duracion_vibracion: float = 2.0
@export_range(0.5, 64.0, 0.5, "suffix:px") var intensidad_vibracion: float = 2.0
@export_range(1.0, 30.0, 0.5, "suffix:Hz") var frecuencia_vibracion: float = 8.0

var _vibracion_pendiente: bool = false
var _tiempo_restante: float = 0.0
var _origen_base: Vector2 = Vector2.ZERO

@onready var _puerta: PuertaAscensor = $Puerta
@onready var _panel: Interactuable = $PanelAscensor
@onready var _opciones_panel: Array[RecursoOpcionDialogo] = _panel.opciones.duplicate()


func _ready() -> void:
	MotorDialogo.opcion_elegida.connect(_al_elegir_opcion)
	MotorDialogo.dialogo_finalizado.connect(_al_finalizar_dialogo)
	GestorEventos.flag_cambiado.connect(_al_cambiar_flag)
	_actualizar_opciones()


func _al_elegir_opcion(opcion: RecursoOpcionDialogo) -> void:
	if not _panel.opciones.has(opcion):
		return
	if TECLAS_POR_OPCION.has(opcion.id):
		var tecla: Array = TECLAS_POR_OPCION[opcion.id]
		if GestorEventos.obtener_flag(tecla[0]) and not GestorEventos.obtener_flag(tecla[1]):
			GestorEventos.cambiar_flag(tecla[1], true)
		return
	if not PISOS_POR_OPCION.has(opcion.id):
		return
	var piso: PuertaAscensor.Piso = PISOS_POR_OPCION[opcion.id]
	if not _puerta.piso_disponible(piso):
		return
	_puerta.elegir_piso(piso)
	_actualizar_opciones()
	_vibracion_pendiente = true


func _actualizar_opciones() -> void:
	var piso := _puerta.piso_actual()
	_panel.lineas.assign(["* Un panel con los botones del ascensor."])
	if not GestorEventos.obtener_flag(PuertaAscensor.FLAG_SUBSUELO_HABILITADO):
		_panel.lineas.append("* Falta la tecla de subsuelo.")
	if not GestorEventos.obtener_flag(PuertaAscensor.FLAG_RECEPCION_HABILITADA):
		_panel.lineas.append("* Falta la tecla de recepción.")
	_panel.lineas.append("¿Qué querés hacer?")
	_panel.opciones = _opciones_panel.filter(func(opcion: RecursoOpcionDialogo) -> bool:
		if PISOS_POR_OPCION.has(opcion.id):
			var destino: PuertaAscensor.Piso = PISOS_POR_OPCION[opcion.id]
			return destino != piso and _puerta.piso_disponible(destino)
		if TECLAS_POR_OPCION.has(opcion.id):
			var tecla: Array = TECLAS_POR_OPCION[opcion.id]
			return GestorEventos.obtener_flag(tecla[0]) and not GestorEventos.obtener_flag(tecla[1])
		return true
	)


func _al_cambiar_flag(_nombre: StringName, _valor: bool) -> void:
	_actualizar_opciones()


func _al_finalizar_dialogo() -> void:
	if _vibracion_pendiente:
		_vibracion_pendiente = false
		if _tiempo_restante <= 0.0:
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
