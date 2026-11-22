extends "res://scripts/niveles/puerta.gd"

enum Piso { LABORATORIO, PRIMER_PISO, SUBSUELO, RECEPCION }

const FLAG_PRIMER_PISO := &"ascensor_piso_1"
const FLAG_SUBSUELO := &"ascensor_subsuelo"
const FLAG_RECEPCION := &"ascensor_recepcion"
const FLAG_TECLA_SUBSUELO := &"ascensor_tecla_subsuelo_encontrada"
const FLAG_SUBSUELO_HABILITADO := &"ascensor_tecla_subsuelo_instalada"
const FLAG_TECLA_RECEPCION := &"ascensor_tecla_recepcion_encontrada"
const FLAG_RECEPCION_HABILITADA := &"ascensor_tecla_recepcion_instalada"

@export_group("Laboratorio")
@export_file("*.tscn") var escena_planta_baja: String = ""
@export var puerta_planta_baja: StringName = &""

@export_group("Primer piso")
@export_file("*.tscn") var escena_piso_1: String = ""
@export var puerta_piso_1: StringName = &""

@export_group("Subsuelo")
@export_file("*.tscn") var escena_subsuelo: String = ""
@export var puerta_subsuelo: StringName = &""

@export_group("Recepción")
@export_file("*.tscn") var escena_recepcion: String = ""
@export var puerta_recepcion: StringName = &""


func _ready() -> void:
	super()
	GestorEventos.flag_cambiado.connect(_al_cambiar_flag)
	_actualizar_destino()


func _al_cambiar_flag(nombre: StringName, _valor: bool) -> void:
	if nombre in [FLAG_PRIMER_PISO, FLAG_SUBSUELO, FLAG_RECEPCION]:
		_actualizar_destino()


func piso_actual() -> Piso:
	if GestorEventos.obtener_flag(FLAG_RECEPCION):
		return Piso.RECEPCION
	if GestorEventos.obtener_flag(FLAG_SUBSUELO):
		return Piso.SUBSUELO
	if GestorEventos.obtener_flag(FLAG_PRIMER_PISO):
		return Piso.PRIMER_PISO
	return Piso.LABORATORIO


func piso_disponible(piso: Piso) -> bool:
	match piso:
		Piso.SUBSUELO:
			return GestorEventos.obtener_flag(FLAG_SUBSUELO_HABILITADO)
		Piso.RECEPCION:
			return GestorEventos.obtener_flag(FLAG_RECEPCION_HABILITADA)
	return true


func elegir_piso(piso: Piso) -> void:
	if not piso_disponible(piso):
		push_warning("El ascensor no tiene instalada la tecla de ese piso")
		return
	GestorEventos.cambiar_flag(FLAG_PRIMER_PISO, piso == Piso.PRIMER_PISO)
	GestorEventos.cambiar_flag(FLAG_SUBSUELO, piso == Piso.SUBSUELO)
	GestorEventos.cambiar_flag(FLAG_RECEPCION, piso == Piso.RECEPCION)


func _actualizar_destino() -> void:
	match piso_actual():
		Piso.RECEPCION:
			escena_destino = escena_recepcion
			puerta_destino = puerta_recepcion
		Piso.SUBSUELO:
			escena_destino = escena_subsuelo
			puerta_destino = puerta_subsuelo
		Piso.PRIMER_PISO:
			escena_destino = escena_piso_1
			puerta_destino = puerta_piso_1
		Piso.LABORATORIO:
			escena_destino = escena_planta_baja
			puerta_destino = puerta_planta_baja
